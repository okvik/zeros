// Implementation of the ament resource index:
// https://github.com/ament/ament_cmake/blob/master/ament_cmake_core/doc/resource_index.md

// This file must remain usable from build.zig

const std = @import("std");
const ArrayList = std.ArrayList;

pub const Error = error {
    AmentPrefixPathNotSet,
    NonExistentPath,
    NonDirectory,

    ResourceTypeInvalid,
    ResourceNameInvalid,
    ResourcePrefixInvalid,

    ResourceNotFound,
};

pub fn parseSearchPath(allocator: std.mem.Allocator, str: []const u8) !ArrayList([]const u8) {
    var paths = ArrayList([]const u8).init(allocator);
    errdefer paths.deinit();

    var iter = std.mem.splitScalar(u8, str, ':');
    while (iter.next()) |path| {
        if (path.len == 0)
            continue;
        const stat = std.fs.cwd().statFile(path) catch
            return Error.NonExistentPath;
        if (stat.kind != .directory)
            return Error.NonDirectory;
        try paths.append(path);
    }
    return paths;
}

// Returns a list of search paths listed in the AMENT_PREFIX_PATH environment variable.
// The returned ArrayList stores slices pointing into the process environment, meaning
// the list becomes invalid once the environment is modified through some means.
pub fn getSearchPaths(allocator: std.mem.Allocator) !ArrayList([]const u8) {
    const ament_prefix_path = brk: {
        if (std.posix.getenv("AMENT_PREFIX_PATH")) |path| {
            break :brk path;
        } else {
            return Error.AmentPrefixPathNotSet;
        }
    };
    return parseSearchPath(allocator, ament_prefix_path);
}

extern fn unsetenv(string: [*:0]const u8) c_int;

// Can't test this because modifying the environment screws it up for other
// tests that depend on it existing.
test getSearchPaths {
    // _ = unsetenv("AMENT_PREFIX_PATH".ptr);
    // const paths = getSearchPaths(std.testing.allocator);
    // try std.testing.expectError(Error.AmentPrefixPathNotSet, prefixes);
}

test parseSearchPath {
    {
        // Normal case
        const prefixes  = try parseSearchPath(std.testing.allocator, "/dev:/var");
        defer prefixes.deinit();
        try std.testing.expectEqual(2, prefixes.items.len);
        try std.testing.expectEqualStrings("/dev", prefixes.items[0]);
        try std.testing.expectEqualStrings("/var", prefixes.items[1]);
    }
    {
        // Non-existent path case; also tests for memory leak when erroring
        const prefixes  = parseSearchPath(std.testing.allocator, "/dev:/nah");
        try std.testing.expectError(Error.NonExistentPath, prefixes);
    }
    {
        // Not-a-directory case; ditto
        const prefixes  = parseSearchPath(std.testing.allocator, "/dev:/dev/fd/0");
        try std.testing.expectError(Error.NonDirectory, prefixes);
    }
}

pub const Resource = struct {
    name: ?[]const u8 = null,
    prefix: ?[]const u8 = null,
    content: ?[]const u8 = null,

    pub fn deinit(self: *Resource, allocator: std.mem.Allocator) void {
        if (self.name) |p| {
            allocator.free(p);
        }
        if (self.prefix) |p| {
            allocator.free(p);
        }
        if (self.content) |p| {
            allocator.free(p);
        }
    }
};

pub const ResourceOpts = struct {
    name: bool = false,
    prefix: bool = false,
    data: bool = false,
    all: bool = false,
};

// Gets a resource of a given type.
// The options argument determines which fields of a returned Resource struct will be populated.
pub fn get(allocator: std.mem.Allocator, resource_type: []const u8, resource_name: []const u8, opts: ResourceOpts) !Resource {
    if (resource_type.len == 0)
        return Error.ResourceTypeInvalid;
    if (resource_name.len == 0)
        return Error.ResourceNameInvalid;

    const paths = try getSearchPaths(allocator);
    defer paths.deinit();

    for (paths.items) |path| {
        const resource_path = try std.fmt.allocPrint(allocator,
                                                     "{s}/share/ament_index/resource_index/{s}/{s}",
                                                     .{path, resource_type, resource_name});
        defer allocator.free(resource_path);

        _ = std.fs.cwd().statFile(resource_path) catch
            continue;

        var resource = Resource{};
        if (opts.all or opts.name) {
            resource.name = try allocator.dupe(u8, resource_name);
            errdefer allocator.free(resource.name.?);
        }
        if (opts.all or opts.prefix) {
            resource.prefix = try allocator.dupe(u8, path);
            errdefer allocator.free(resource.prefix.?);
        }
        if (opts.all or opts.data) {
            resource.content = try std.fs.cwd().readFileAlloc(allocator,
                                                           resource_path,
                                                           std.math.maxInt(usize));
            errdefer allocator.free(resource.content.?);
        }

        return resource;
    }
    return Error.ResourceNotFound;
}

test get {
    {
        var resource = try get(std.testing.allocator, "packages", "rcl", .{});
        defer resource.deinit(std.testing.allocator);
        try std.testing.expectEqual(resource.name, null);
        try std.testing.expectEqual(resource.prefix, null);
        try std.testing.expectEqual(resource.content, null);
    }
    {
        var resource = try get(std.testing.allocator, "packages", "rcl", .{ .all = true });
        defer resource.deinit(std.testing.allocator);
        try std.testing.expectEqualStrings(resource.name.?, "rcl");
        try std.testing.expect(resource.prefix.?.len > 0);
        try std.testing.expect(resource.content.?.len == 0);
    }
    {
        const err = get(std.testing.allocator, "packages", "std_nope", .{});
        try std.testing.expectError(error.ResourceNotFound, err);
    }
}

pub const Resources = struct {
    map: std.StringHashMapUnmanaged(Resource),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Resources {
        return .{
            .map = std.StringHashMapUnmanaged(Resource).empty,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Resources) void {
        var iter = self.map.iterator();
        while (iter.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            entry.value_ptr.deinit(self.allocator);
        }
        self.map.deinit(self.allocator);
    }
};

// Returns a map of all resources of a given type found in the search path.
pub fn getAll(allocator: std.mem.Allocator, resource_type: []const u8, opts: ResourceOpts) !Resources {
    if (resource_type.len == 0)
        return Error.ResourceTypeInvalid;

    const paths = try getSearchPaths(allocator);
    defer paths.deinit();

    var resources = Resources.init(allocator);
    errdefer resources.deinit();

    var found_some = false;
    for (paths.items) |path| {
        const resource_dir_path = try std.fmt.allocPrint(allocator,
                                            "{s}/share/ament_index/resource_index/{s}",
                                            .{path, resource_type});
        defer allocator.free(resource_dir_path);

        _ = std.fs.cwd().statFile(resource_dir_path)
            catch continue;

        const dir = std.fs.cwd().openDir(resource_dir_path, .{ .iterate = true })
            catch continue;

        found_some = true;

        var iter = dir.iterate();
        while (try iter.next()) |dentry| {
            if (dentry.kind != .file and dentry.kind != .sym_link)
                continue;
            if (dentry.name[0] == '.')
                continue;

            const name = try allocator.dupe(u8, dentry.name);

            const entry = try resources.map.getOrPut(allocator, name);
            if (entry.found_existing) {
                continue;
            }

            var resource = Resource{};
            if (opts.all or opts.name) {
                resource.name = try allocator.dupe(u8, name);
                errdefer allocator.free(resource.name.?);
            }
            if (opts.all or opts.prefix) {
                resource.prefix = try allocator.dupe(u8, path);
                errdefer allocator.free(resource.prefix.?);
            }
            if (opts.all or opts.data) {
                resource.content = try dir.readFileAlloc(allocator, name, std.math.maxInt(usize));
                errdefer allocator.free(resource.content.?);
            }

            entry.value_ptr.* = resource;
        }
    }
    if (found_some) {
        // Zero or more resources were found
        return resources;
    } else {
        // No resource type found in the index at all
        return Error.ResourceNotFound;
    }
}

test getAll {
    {
        var packages = try getAll(std.testing.allocator, "packages", .{ .all = true });
        defer packages.deinit();

        try std.testing.expect(packages.map.count() > 0);

        const entry = packages.map.get("rcl");
        try std.testing.expect(entry != null);

        const resource = entry.?;
        try std.testing.expect(resource.name != null);
        try std.testing.expectEqualStrings(resource.name.?, "rcl");
        try std.testing.expect(resource.prefix != null);
        try std.testing.expect(resource.content != null);
    }
    {
        const err = getAll(std.testing.allocator, "nope", .{ .all = true });
        try std.testing.expectError(Error.ResourceNotFound, err);
    }
}

pub fn getAllPackages(allocator: std.mem.Allocator) !Resources {
    return getAll(allocator, "packages", .{ .prefix = true });
}

// Returns absolute path to a directory belonging to a given package.
// Caller owns the returned slice.
pub fn getPackageDir(allocator: std.mem.Allocator, package_name: []const u8, dir: []const u8) ![]u8 {
    var package = try get(allocator, "packages", package_name, .{ .prefix = true });
    defer package.deinit(allocator);

    return try std.fmt.allocPrint(allocator, "{s}/{s}/{s}", .{package.prefix.?, dir, package_name});
}

test getPackageDir {
    const share = try getPackageDir(std.testing.allocator, "rcl", "share");
    defer std.testing.allocator.free(share);
    try std.testing.expect(std.mem.endsWith(u8, share, "/share/rcl"));
}

// Registers a resource of a given type, named .name, under .prefix, containing .content.
pub fn registerResource(allocator: std.mem.Allocator, resource_type: []const u8, resource: *const Resource) !void {
    if (resource_type.len == 0)
        return Error.ResourceTypeInvalid;
    if (resource.prefix == null)
        return Error.ResourcePrefixInvalid;
    if (resource.name == null)
        return Error.ResourceNameInvalid;

    const resource_dir = try std.fmt.allocPrint(allocator,
                                                 "{s}/share/ament_index/resource_index/{s}",
                                                 .{resource.prefix.?, resource_type});
    defer allocator.free(resource_dir);

    var dir = try std.fs.cwd().makeOpenPath(resource_dir, .{});
    defer dir.close();

    const file = try dir.createFile(resource.name.?, .{ .truncate = true });
    defer file.close();

    if (resource.content) |content| {
        try file.writeAll(content);
    }
}

// Register a package resource
pub fn registerPackage(allocator: std.mem.Allocator, prefix: []const u8, name: []const u8) !void {
    try registerResource(allocator, "packages", &.{
        .prefix = prefix,
        .name = name,
    });
}

test registerPackage {
    var tmpdir = std.testing.tmpDir(.{});
    defer tmpdir.cleanup();

    const prefix = try tmpdir.dir.realpathAlloc(std.testing.allocator, ".");
    defer std.testing.allocator.free(prefix);

    try registerPackage(std.testing.allocator, prefix, "zeros");

    try tmpdir.dir.access("share/ament_index/resource_index/packages/zeros", .{});
}

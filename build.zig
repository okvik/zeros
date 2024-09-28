const std = @import("std");
const resource_index = @import("src/resource_index.zig");

const Ros = enum {
    humble,
    iron,
    rolling,
};

const Rmw = enum {
    rmw_fastrtps_cpp,
    rmw_cyclonedds_cpp,
};

// Adds the include search path of a given ROS package to the module.
fn addRosIncludePath(arena: std.mem.Allocator, module: *std.Build.Module, package: []const u8) !void {
    const resource = try resource_index.get(arena, "packages", package, .{ .prefix = true });
    const prefix = resource.prefix.?;

    const include_path = try std.fmt.allocPrint(arena, "{s}/include/{s}", .{ prefix, package });
    module.addIncludePath(.{ .cwd_relative = include_path });
}

// Adds library search paths from the ROS prefix to the module.
fn addRosCommonLibraryPaths(arena: std.mem.Allocator, module: *std.Build.Module) !void {
    const prefix = try resource_index.getSearchPaths(arena);
    for (prefix.items) |path| {
        const library_path = try std.fmt.allocPrint(arena, "{s}/lib", .{path});
        module.addLibraryPath(.{ .cwd_relative = library_path });
    }
}

fn linkRosLibrary(module: *std.Build.Module, library: []const u8) !void {
    module.link_libc = true;
    module.linkSystemLibrary(library, .{
        .use_pkg_config = .no,
        .preferred_link_mode = .dynamic, // not preffered but neccessary for now
    });
}

fn addRosMessageLibrary(arena: std.mem.Allocator, module: *std.Build.Module, package: []const u8) !void {
    try addRosIncludePath(arena, module, package);
    try addRosIncludePath(arena, module, "rosidl_runtime_c");
    try addRosIncludePath(arena, module, "rosidl_typesupport_interface");

    const typesupport_lib = try std.fmt.allocPrint(arena, "{s}__rosidl_typesupport_c", .{package});
    const generator_lib = try std.fmt.allocPrint(arena, "{s}__rosidl_generator_c", .{package});

    try linkRosLibrary(module, typesupport_lib);
    try linkRosLibrary(module, generator_lib);
}

fn linkRos(arena: std.mem.Allocator, module: *std.Build.Module, _: Ros, _: Rmw) !void {
    try addRosIncludePath(arena, module, "rcutils");
    try addRosIncludePath(arena, module, "rmw");
    try addRosIncludePath(arena, module, "rcl");
    try addRosIncludePath(arena, module, "rcl_action");
    try addRosIncludePath(arena, module, "rcl_yaml_param_parser");
    try addRosIncludePath(arena, module, "rclc");

    try addRosIncludePath(arena, module, "rosidl_runtime_c");
    try addRosIncludePath(arena, module, "rosidl_typesupport_interface");
    try addRosIncludePath(arena, module, "builtin_interfaces");
    try addRosIncludePath(arena, module, "unique_identifier_msgs");
    try addRosIncludePath(arena, module, "action_msgs");

    try addRosCommonLibraryPaths(arena, module);
    try linkRosLibrary(module, "rcutils");
    try linkRosLibrary(module, "rmw");
    try linkRosLibrary(module, "rmw_cyclonedds_cpp");
    try linkRosLibrary(module, "rcl");
    try linkRosLibrary(module, "rclc");
}

pub fn build(b: *std.Build) !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ros = b.option(Ros, "ros", "ROS 2 distribution") orelse .humble;
    const rmw = b.option(Rmw, "rmw", "ROS 2 middleware implementation") orelse .rmw_cyclonedds_cpp;

    ////////////////////////////////////////////////////////////////////////////////

    const zeros = b.addModule("zeros", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    try linkRos(arena, zeros, ros, rmw);

    const zeros_docs = b.addStaticLibrary(.{
        .name = "zeros",
        .root_source_file = zeros.root_source_file.?,
        .target = target,
        .optimize = optimize,
    });

    var install_docs = b.addInstallDirectory(.{
        .source_dir = zeros_docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });

    const zeros_tests = b.addTest(.{
        .root_source_file = zeros.root_source_file.?,
        .target = target,
        .optimize = optimize,
    });
    try linkRos(arena, &zeros_tests.root_module, ros, rmw);

    const run_zeros_tests = b.addRunArtifact(zeros_tests);

    ////////////////////////////////////////////////////////////////////////////////

    const std_msgs = b.addModule("std_msgs", .{
        .root_source_file = b.path("src/std_msgs/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    try addRosMessageLibrary(arena, std_msgs, "std_msgs");

    const geometry_msgs = b.addModule("geometry_msgs", .{
        .root_source_file = b.path("src/geometry_msgs/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    try addRosMessageLibrary(arena, geometry_msgs, "geometry_msgs");

    ////////////////////////////////////////////////////////////////////////////////

    const publisher = b.addExecutable(.{
        .name = "zeros-publisher",
        .root_source_file = b.path("examples/publisher.zig"),
        .target = target,
        .optimize = optimize,
    });
    publisher.root_module.addImport("zeros", zeros);
    publisher.root_module.addImport("std_msgs", std_msgs);
    b.installArtifact(publisher);

    ////////////////////////////////////////////////////////////////////////////////

    const subscriber = b.addExecutable(.{
        .name = "zeros-subscriber",
        .root_source_file = b.path("examples/subscriber.zig"),
        .target = target,
        .optimize = optimize,
    });
    subscriber.root_module.addImport("zeros", zeros);
    subscriber.root_module.addImport("std_msgs", std_msgs);
    b.installArtifact(subscriber);

    ////////////////////////////////////////////////////////////////////////////////

    const timer = b.addExecutable(.{
        .name = "zeros-timer",
        .root_source_file = b.path("examples/timer.zig"),
        .target = target,
        .optimize = optimize,
    });
    timer.root_module.addImport("zeros", zeros);

    b.installArtifact(timer);

    ////////////////////////////////////////////////////////////////////////////////

    const docs_step = b.step("docs", "Build the documentation");
    docs_step.dependOn(&install_docs.step);

    ////////////////////////////////////////////////////////////////////////////////

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_zeros_tests.step);
}

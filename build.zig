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

fn linkRosDependency(arena: std.mem.Allocator, module: *std.Build.Module, name: []const u8, header_only: bool) !void {
    module.link_libc = true;

    const ament_prefix_path = brk: {
        if (std.posix.getenv("AMENT_PREFIX_PATH")) |path| {
            break :brk path;
        } else {
            std.log.err("AMENT_PREFIX_PATH unset", .{});
            return error.AmentPrefixPathUnset;
        }
    };

    // Split the path and search for the library `name`, adding the include
    // and library paths to the compile step.
    var iter = std.mem.splitScalar(u8, ament_prefix_path, ':');
    while (iter.next()) |prefix| {
        const include_path = try std.fmt.allocPrint(arena, "{s}/include/{s}", .{ prefix, name });
        module.addIncludePath(.{ .cwd_relative = include_path });

        if (!header_only) {
            const common_library_path = try std.fmt.allocPrint(arena, "{s}/lib", .{prefix});
            module.addLibraryPath(.{ .cwd_relative = common_library_path });
            const library_path = try std.fmt.allocPrint(arena, "{s}/lib/{s}", .{ prefix, name });
            module.addLibraryPath(.{ .cwd_relative = library_path });

            module.linkSystemLibrary(name, .{
                .use_pkg_config = .no,
            });
        }
    }
}

fn linkRos(arena: std.mem.Allocator, module: *std.Build.Module, ros: Ros, _: Rmw) !void {
    // try linkRosDependency(arena, step, @tagName(rmw), false);
    try linkRosDependency(arena, module, "rmw_cyclonedds_cpp", false);
    // try linkRosDependency(arena, module, "rmw_fastrtps_cpp", false);

    try linkRosDependency(arena, module, "rcutils", false);
    try linkRosDependency(arena, module, "rmw", false);
    try linkRosDependency(arena, module, "rcl", false);
    try linkRosDependency(arena, module, "rcl_action", false);
    try linkRosDependency(arena, module, "rcl_yaml_param_parser", false);
    try linkRosDependency(arena, module, "rclc", false);
    try linkRosDependency(arena, module, "rosidl_runtime_c", false);
    try linkRosDependency(arena, module, "rosidl_typesupport_interface", true);
    try linkRosDependency(arena, module, "rosidl_typesupport_c", false);

    try linkRosDependency(arena, module, "std_msgs", true);
    try linkRosDependency(arena, module, "std_msgs__rosidl_generator_c", false);
    try linkRosDependency(arena, module, "std_msgs__rosidl_typesupport_c", false);

    try linkRosDependency(arena, module, "rcl_interfaces", true);
    try linkRosDependency(arena, module, "actionlib_msgs", true);
    try linkRosDependency(arena, module, "action_msgs", true);
    try linkRosDependency(arena, module, "unique_identifier_msgs", true);
    try linkRosDependency(arena, module, "builtin_interfaces", true);
    if (ros == .iron) {
        try linkRosDependency(arena, module, "rosidl_dynamic_typesupport", false);
        try linkRosDependency(arena, module, "type_description_interfaces", true);
        try linkRosDependency(arena, module, "service_msgs", true);
    }
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
    try linkRosDependency(arena, std_msgs, "rosidl_runtime_c", false);
    try linkRosDependency(arena, std_msgs, "rosidl_typesupport_interface", true);
    try linkRosDependency(arena, std_msgs, "rosidl_typesupport_c", false);
    try linkRosDependency(arena, std_msgs, "std_msgs", true);
    try linkRosDependency(arena, std_msgs, "std_msgs__rosidl_generator_c", false);
    try linkRosDependency(arena, std_msgs, "std_msgs__rosidl_typesupport_c", false);

    const geometry_msgs = b.addModule("geometry_msgs", .{
        .root_source_file = b.path("src/geometry_msgs/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    try linkRosDependency(arena, geometry_msgs, "rosidl_runtime_c", false);
    try linkRosDependency(arena, geometry_msgs, "rosidl_typesupport_interface", true);
    try linkRosDependency(arena, geometry_msgs, "rosidl_typesupport_c", false);
    try linkRosDependency(arena, geometry_msgs, "geometry_msgs", true);
    try linkRosDependency(arena, geometry_msgs, "geometry_msgs__rosidl_generator_c", false);
    try linkRosDependency(arena, geometry_msgs, "geometry_msgs__rosidl_typesupport_c", false);

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

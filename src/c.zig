const c = @cImport({
    @cInclude("rmw/rmw.h");
    @cInclude("rmw/init_options.h");
    @cInclude("rmw/qos_string_conversions.h");

    @cInclude("rcl/rcl.h");
    @cInclude("rcl/types.h");
    @cInclude("rcl/node.h");
    @cInclude("rcl/timer.h");
    @cInclude("rcl/publisher.h");
    @cInclude("rcl/logging_rosout.h");

    @cInclude("rclc/rclc.h");
    @cInclude("rclc/executor.h");
});

pub usingnamespace c;

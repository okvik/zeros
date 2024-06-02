const std = @import("std");
const zeros = @import("root.zig");
const c = zeros.c;
const errors = zeros.errors;

const Node = @This();

base: c.rcl_node_t = undefined,

pub const Options = extern struct {
    allocator: zeros.Allocator = .{},
    use_global_arguments: bool = true,
    arguments: c.rcl_arguments_t = .{
        .impl = null,
    },
    enable_rosout: bool = true,
    rosout_qos: c.rmw_qos_profile_t = c.rcl_qos_profile_rosout_default,
};

pub fn init(allocator: zeros.Allocator, context: *zeros.Context, name: [:0]const u8, namespace: [:0]const u8, options: Options) !Node {
    var self = Node{};

    self.base = c.rcl_get_zero_initialized_node();

    var actual_options = options;
    actual_options.allocator = allocator;
    const rc = c.rcl_node_init(&self.base, name, namespace, &context.base.context, @ptrCast(&actual_options));
    if (errors.check(rc)) |err|
        return err;

    return self;
}

pub fn deinit(self: *Node) void {
    const rc = c.rcl_node_fini(&self.base);
    if (rc != 0) {
        errors.logError();
    }
}

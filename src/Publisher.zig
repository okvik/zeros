const std = @import("std");
const zeros = @import("root.zig");
const c = zeros.c;
const errors = zeros.errors;

const Publisher = @This();

base: c.rcl_publisher_t = undefined,
node: *c.rcl_node_t = undefined,

pub const Options = extern struct {
    qos: c.rmw_qos_profile_t = c.rmw_qos_profile_default,
    allocator: zeros.Allocator = .{},
    rmw_options: c.rmw_publisher_options_t = .{
        .rmw_specific_publisher_payload = null,
        .require_unique_network_flow_endpoints = c.RMW_UNIQUE_NETWORK_FLOW_ENDPOINTS_NOT_REQUIRED,
    },
};

pub fn init(allocator: zeros.Allocator, T: anytype, node: *zeros.Node, topic: [:0]const u8, options: Options) !Publisher {
    var self = Publisher{};
    self.base = c.rcl_get_zero_initialized_publisher();
    self.node = &node.base;

    var actual_options = options;
    actual_options.allocator = allocator;
    const type_support = T.ts();
    const rc = c.rcl_publisher_init(&self.base, &node.base, @ptrCast(type_support), topic.ptr, @ptrCast(&actual_options));
    if (errors.check(rc)) |err|
        return err;

    return self;
}

pub fn deinit(self: *Publisher) void {
    const rc = c.rcl_publisher_fini(&self.base, self.node);
    if (errors.check(rc)) |_|
        errors.logError();
}

pub fn publish(self: *Publisher, message: *const anyopaque) !void {
    const rc = c.rcl_publish(&self.base, message, null);
    if (errors.check(rc)) |err|
        return err;
}

pub fn getOptions(self: *Publisher) *const Options {
    return @ptrCast(c.rcl_publisher_get_options(&self.base));
}

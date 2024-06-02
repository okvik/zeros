const std = @import("std");

const zeros = @import("root.zig");
const c = zeros.c;
const errors = zeros.errors;

pub const Options = extern struct {
    qos: c.rmw_qos_profile_t = c.rmw_qos_profile_default,
    allocator: zeros.Allocator = .{},
    rmw_options: c.rmw_subscription_options_t = .{
        .rmw_specific_subscription_payload = null,
        .ignore_local_publications = false,
        .require_unique_network_flow_endpoints = c.RMW_UNIQUE_NETWORK_FLOW_ENDPOINTS_NOT_REQUIRED,
        .content_filter_options = null,
    },

    // No need to call this unless CFT options have been used
    pub fn deinit(self: *Options) void {
        const rc = c.rcl_subscription_options_fini(@ptrCast(self));
        if (errors.check(rc)) |_|
            errors.logError();
    }
};

const Subscription = @This();

base: c.rcl_subscription_t = undefined,
node: *c.rcl_node_t = undefined,

pub fn init(allocator: zeros.Allocator, T: anytype, node: *zeros.Node, topic: [:0]const u8, options: Options) !Subscription {
    var self = Subscription{};
    self.base = c.rcl_get_zero_initialized_subscription();
    self.node = &node.base;

    var actual_options = options;
    actual_options.allocator = allocator;
    const rc = c.rcl_subscription_init(&self.base, self.node, @ptrCast(T.ts()), topic.ptr, @ptrCast(&actual_options));
    if (errors.check(rc)) |err|
        return err;

    return self;
}

pub fn deinit(self: *Subscription) void {
    const rc = c.rcl_subscription_fini(&self.base, self.node);
    if (errors.check(rc)) |_|
        errors.logError();
}

const std = @import("std");

const zeros = @import("root.zig");
const c = zeros.c;
const errors = zeros.errors;

pub const Semantics = enum(c.rclc_executor_semantics_t) {
    rclcpp = c.RCLCPP_EXECUTOR,
    let = c.LET,
};

pub const Invocation = enum(c.rclc_executor_handle_invocation_t) {
    on_new_data = c.ON_NEW_DATA,
    always = c.ALWAYS,
};

const Executor = @This();

base: c.rclc_executor_t = undefined,
context: *zeros.Context = undefined,

pub fn init(allocator: zeros.Allocator, context: *zeros.Context, handles: usize) !Executor {
    var self = Executor{};
    self.context = context;
    self.base = c.rclc_executor_get_zero_initialized_executor();

    const rc = c.rclc_executor_init(&self.base, &context.base.context, handles, @constCast(@ptrCast(&allocator)));
    if (errors.check(rc)) |err|
        return err;

    return self;
}

pub fn deinit(self: *Executor) void {
    const rc = c.rclc_executor_fini(&self.base);
    if (rc != 0) {
        errors.logError();
    }
}

pub fn prepare(self: *Executor) !void {
    const rc = c.rclc_executor_prepare(&self.base);
    if (errors.check(rc)) |err|
        return err;
}

pub fn addTimer(self: *Executor, timer: *zeros.Timer) !void {
    const rc = c.rclc_executor_add_timer(&self.base, &timer.base);
    if (errors.check(rc)) |err|
        return err;
}

pub fn removeTimer(self: *Executor, timer: *zeros.Timer) !void {
    const rc = c.rclc_executor_remove_timer(&self.base, &timer.base);
    if (errors.check(rc)) |err|
        return err;
}

pub fn addSubscription(self: *Executor, subscription: *zeros.Subscription, msg: *anyopaque, callback: c.rclc_subscription_callback_t, invocation: Invocation) !void {
    const rc = c.rclc_executor_add_subscription(&self.base, &subscription.base, msg, callback, @intFromEnum(invocation));
    if (errors.check(rc)) |err|
        return err;
}

pub fn removeSubscription(_: *Executor) void {
    unreachable;
}

pub fn addSubscriptionWithContext(_: *Executor) void {
    unreachable;
}

pub fn addClient(_: *Executor) void {
    unreachable;
}

pub fn addClientWithRequestId(_: *Executor) void {
    unreachable;
}

pub fn removeClient(_: *Executor) void {
    unreachable;
}

pub fn addService(_: *Executor) void {
    unreachable;
}

pub fn addServiceWithRequestId(_: *Executor) void {
    unreachable;
}

pub fn addServiceWithContext(_: *Executor) void {
    unreachable;
}

pub fn removeService(_: *Executor) void {
    unreachable;
}

pub fn addActionClient(_: *Executor) void {
    unreachable;
}

pub fn addActionServer(_: *Executor) void {
    unreachable;
}

pub fn addGuardCondition(_: *Executor) void {
    unreachable;
}

pub fn removeGuardCondition(_: *Executor) void {
    unreachable;
}

pub fn setTrigger(self: *Executor, trigger: c.rclc_executor_trigger_t, trigger_obj: *anyopaque) !void {
    const rc = c.rclc_executor_set_trigger(&self.base, trigger, trigger_obj);
    if (errors.check(rc)) |err|
        return err;
}
pub const triggerAll = c.rclc_executor_trigger_all;
pub const triggerAny = c.rclc_executor_trigger_any;
pub const triggerOne = c.rclc_executor_trigger_one;
pub const triggerAlways = c.rclc_executor_trigger_always;

pub fn spin(self: *Executor) !void {
    const rc = c.rclc_executor_spin(&self.base);
    if (errors.check(rc)) |err|
        return err;
}

pub fn spinSome(self: *Executor, timeout: u64) !void {
    const rc = c.rclc_executor_spin_some(&self.base, timeout);
    if (errors.check(rc)) |err|
        return err;
}

pub fn spinPeriod(self: *Executor, period: u64) !void {
    const rc = c.rclc_executor_spin_period(&self.base, period);
    if (errors.check(rc)) |err|
        return err;
}

pub fn spinOnePeriod(self: *Executor, period: u64) !void {
    const rc = c.rclc_executor_spin_one_period(&self.base, period);
    if (errors.check(rc)) |err|
        return err;
}

pub fn setTimeout(self: *Executor, timeout_ns: u64) !void {
    const rc = c.rclc_executor_set_timeout(&self.base, timeout_ns);
    if (errors.check(rc)) |err|
        return err;
}

pub fn setSemantics(self: *Executor, semantics: Semantics) !void {
    const rc = c.rclc_executor_set_semantics(&self.base, @intFromEnum(semantics));
    if (errors.check(rc)) |err|
        return err;
}

////////////////////////////////////////////////////////////////////////////////


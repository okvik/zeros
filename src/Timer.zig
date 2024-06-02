const std = @import("std");
const zeros = @import("root.zig");
const c = zeros.c;
const errors = zeros.errors;

const Timer = @This();

const Callback = fn (*Timer, i64) void;

base: c.rcl_timer_t = undefined,
// TODO: ability to pass user *anyopaque to the callback
callback: ?*const fn (*Timer, i64) void = null,

pub fn init(allocator: zeros.Allocator, context: *zeros.Context, period: i64, callback: *const fn (*Timer, i64) void) !Timer {
    var self = Timer{};

    self.base = c.rcl_get_zero_initialized_timer();
    self.callback = callback;
    const rc = c.rcl_timer_init(&self.base, &context.base.clock, &context.base.context, period, @ptrCast(&base_callback), @bitCast(allocator));
    if (errors.check(rc)) |err|
        return err;

    return self;
}

fn base_callback(base_timer: *c.rcl_timer_t, last_call: i64) void {
    const timer: *Timer = @fieldParentPtr("base", base_timer);
    if (timer.callback) |callback| {
        callback(timer, last_call);
    }
}

pub fn deinit(self: *Timer) void {
    const rc = c.rcl_timer_fini(&self.base);
    if (errors.check(rc)) |_|
        errors.logError();
}

pub fn cancel(self: *Timer) !void {
    const rc = c.rcl_timer_cancel(&self.base);
    if (errors.check(rc)) |err|
        return err;
}

pub fn isCanceled(self: *Timer) !bool {
    var canceled: bool = undefined;
    const rc = c.rcl_timer_is_canceled(&self.base, &canceled);
    if (errors.check(rc)) |err|
        return err;
    return canceled;
}

pub fn reset(self: *Timer) !void {
    const rc = c.rcl_timer_reset(&self.base);
    if (errors.check(rc)) |err|
        return err;
}

pub fn getPeriod(self: *Timer) !i64 {
    var period: i64 = undefined;
    const rc = c.rcl_timer_get_period(&self.base, &period);
    if (errors.check(rc)) |err|
        return err;
    return period;
}

pub fn setPeriod(self: *Timer, period: i64) !i64 {
    var old_period: i64 = undefined;
    const rc = c.rcl_timer_exchange_period(&self.base, period, &old_period);
    if (errors.check(rc)) |err|
        return err;
    return old_period;
}

pub fn getCallback(self: *Timer) ?*const fn (*Timer, i64) void {
    return self.callback;
}

pub fn setCallback(self: *Timer, callback: *const fn (*Timer, i64) void) ?*const fn (*Timer, i64) void {
    const old_callback = self.callback;
    self.callback = callback;
    return old_callback;
}

// TODO:
// rcl_timer_clock
// rcl_timer_is_ready
// rcl_timer_get_time_since_last_call
// rcl_timer_get_time_until_last_call

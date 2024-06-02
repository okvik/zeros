const std = @import("std");

const zeros = @import("root.zig");
const c = zeros.c;
const errors = zeros.errors;
const rmw = zeros.rmw;

const Context = @This();

pub const Options = extern struct {
    impl: ?*c.rcl_init_options_impl_t = null,

    pub fn init(allocator: zeros.Allocator) !Options {
        var self = c.rcl_get_zero_initialized_init_options();
        const rc = c.rcl_init_options_init(@ptrCast(&self), @bitCast(allocator));
        if (errors.check(rc)) |err|
            return err;
        return @bitCast(self);
    }

    pub fn deinit(self: *Options) void {
        const rc = c.rcl_init_options_fini(@ptrCast(self));
        if (errors.check(rc)) |_|
            errors.logError();
    }

    pub fn setDomainId(self: *Options, domain_id: usize) !void {
        const rc = c.rcl_init_options_set_domain_id(@ptrCast(self), domain_id);
        if (errors.check(rc)) |err|
            return err;
    }

    pub fn getDomainId(self: *const Options) !usize {
        var domain_id: usize = undefined;
        const rc = c.rcl_init_options_get_domain_id(@ptrCast(&self), &domain_id);
        if (errors.check(rc)) |err|
            return err;
        return domain_id;
    }
};

base: c.rclc_support_t = undefined,

pub fn init(allocator: zeros.Allocator, options: *Options, argc: c_int, argv: ?[*]const [*]const u8) !Context {
    var self = Context{};

    const rc = c.rclc_support_init_with_options(&self.base, argc, argv, @ptrCast(options), @constCast(@ptrCast(&allocator)));
    if (errors.check(rc)) |err|
        return err;

    return self;
}

pub fn deinit(self: *Context) void {
    const rc = c.rclc_support_fini(&self.base);
    if (errors.check(rc)) |_|
        errors.logError();
}

////////////////////////////////////////////////////////////////////////////////

const testing = std.testing;

test Options {
    var ralloc = try zeros.Allocator.init(std.testing.allocator);
    defer ralloc.deinit();
    var opts = try Options.init(ralloc);
    defer opts.deinit();
}

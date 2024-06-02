const std = @import("std");

const zeros = @import("root.zig");

pub fn installHandlers() void {
    installHandler(std.posix.SIG.INT);
    installHandler(std.posix.SIG.TERM);
}

pub fn installHandler(sig: u6) void {
    const sig_action: std.posix.Sigaction = .{
        .flags = 0,
        .mask = .{0} ** 32,
        .handler = .{ .handler = handler },
    };
    std.posix.sigaction(sig, &sig_action, null);
}

fn handler(_: c_int) callconv(.C) void {
    zeros.running = false;
}

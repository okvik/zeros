const std = @import("std");
const zeros = @import("zeros");
const std_msgs = @import("std_msgs");

fn subscribeCallback(raw_msg: ?*const anyopaque) callconv(.C) void {
    const msg: ?*const std_msgs.msg.String = @alignCast(@ptrCast(raw_msg));
    std.log.info("{s}", .{msg.?.base.data.data});
}

pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{ .safety = true }).init;
    defer _ = gpa_state.deinit();
    const gpa = gpa_state.allocator();

    var ralloc = try zeros.Allocator.init(gpa);
    defer ralloc.deinit();

    var context_opts = try zeros.Context.Options.init(ralloc);
    defer context_opts.deinit();
    var context = try zeros.Context.init(ralloc, &context_opts, 0, null);
    defer context.deinit();

    var node = try zeros.Node.init(ralloc, &context, "subscriber", "", .{});
    defer node.deinit();

    var handles: u8 = 0;

    var msg = try std_msgs.msg.String.init();
    var subscription = try zeros.Subscription.init(ralloc, std_msgs.msg.String, &node, "hello", .{});
    defer subscription.deinit();
    handles += 1;

    var executor = try zeros.Executor.init(ralloc, &context, handles);
    defer executor.deinit();
    try executor.setSemantics(.let);

    try executor.addSubscription(&subscription, &msg, subscribeCallback, .on_new_data);

    zeros.signals.installHandlers();
    while (zeros.running) {
        try executor.spinSome(100 * std.time.ns_per_ms);
    }
}

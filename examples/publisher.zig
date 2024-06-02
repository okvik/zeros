const std = @import("std");
const zeros = @import("zeros");
const std_msgs = @import("std_msgs");

var msg: std_msgs.msg.String = undefined;
var publisher: zeros.Publisher = undefined;

fn publishCallback(_: *zeros.Timer, _: i64) void {
    publisher.publish(&msg) catch unreachable;
}

pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{ .safety = true }).init;
    defer _= gpa_state.deinit();
    const gpa = gpa_state.allocator();

    var ralloc = try zeros.Allocator.init(gpa);
    defer ralloc.deinit();

    var context_opts = try zeros.Context.Options.init(ralloc);
    defer context_opts.deinit();
    var context = try zeros.Context.init(ralloc, &context_opts, 0, null);
    defer context.deinit();

    var node = try zeros.Node.init(ralloc, &context, "publisher", "", .{});
    defer node.deinit();

    var handles: u8 = 0;

    const msg_buf = "hello";
    msg = try std_msgs.msg.String.init();
    msg.base.data.data = @constCast(msg_buf.ptr);
    msg.base.data.size = msg_buf.len;

    publisher = try zeros.Publisher.init(ralloc, std_msgs.msg.String, &node, "hello", .{});
    defer publisher.deinit();

    var timer = try zeros.Timer.init(ralloc, &context, 500 * std.time.ns_per_ms, publishCallback);
    defer timer.deinit();
    handles += 1;

    var executor = try zeros.Executor.init(ralloc, &context, handles);
    defer executor.deinit();
    try executor.setSemantics(.let);

    try executor.addTimer(&timer);

    zeros.signals.installHandlers();
    while (zeros.running) {
        try executor.spinSome(100 * std.time.ns_per_ms);
    }
}

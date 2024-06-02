const std = @import("std");
const zeros = @import("zeros");

var counter: u8 = 0;

fn timerCallback(timer: *zeros.Timer, last_call: i64) void {
    _ = last_call;
    std.debug.print("1s {}\n", .{counter});
    counter += 1;
    if (counter > 5)
        timer.cancel() catch unreachable;
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

    var node = try zeros.Node.init(ralloc, &context, "timer", "", .{});
    defer node.deinit();

    var handles: u8 = 0;

    var timer = try zeros.Timer.init(ralloc, &context, 1 * std.time.ns_per_s, timerCallback);
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

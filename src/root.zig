const std = @import("std");

pub const c = @import("c.zig");

pub const allocator = @import("allocator.zig");
pub const rmw = @import("rmw.zig");
pub const qos = @import("qos.zig");
pub usingnamespace qos;
pub const errors = @import("errors.zig");
pub const signals = @import("signals.zig");
pub const resource_index = @import("resource_index.zig");

pub const Allocator = allocator.RosAllocator;
pub const Context = @import("Context.zig");
pub const Node = @import("Node.zig");
pub const Timer = @import("Timer.zig");
pub const Publisher = @import("Publisher.zig");
pub const Subscription = @import("Subscription.zig");
pub const Executor = @import("Executor.zig");

pub const default_domain_id = c.RCL_DEFAULT_DOMAIN_ID;

pub var running = true;

test {
    std.testing.refAllDeclsRecursive(allocator);
    std.testing.refAllDeclsRecursive(errors);
    std.testing.refAllDeclsRecursive(rmw);
    std.testing.refAllDeclsRecursive(qos);
    std.testing.refAllDeclsRecursive(signals);
    std.testing.refAllDeclsRecursive(resource_index);

    std.testing.refAllDeclsRecursive(Context);
    std.testing.refAllDeclsRecursive(Node);
    std.testing.refAllDeclsRecursive(Timer);
    std.testing.refAllDeclsRecursive(Publisher);
    std.testing.refAllDeclsRecursive(Subscription);
    std.testing.refAllDeclsRecursive(Executor);
}

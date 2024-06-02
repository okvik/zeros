const std = @import("std");

const zeros = @import("root.zig");
const c = zeros.c;

pub const RosAllocator = extern struct {
    allocate: ?*const fn (usize, ?*anyopaque) callconv(.C) ?*anyopaque = null,
    deallocate: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void = null,
    reallocate: ?*const fn (?*anyopaque, usize, ?*anyopaque) callconv(.C) ?*anyopaque = null,
    zero_allocate: ?*const fn (usize, usize, ?*anyopaque) callconv(.C) ?*anyopaque = null,
    state: ?*anyopaque = null,

    pub fn init(allocator: std.mem.Allocator) !RosAllocator {
        const state = try allocator.create(std.mem.Allocator);
        state.* = allocator;
        return .{
            .allocate = &_allocate,
            .deallocate = &_deallocate,
            .reallocate = &_reallocate,
            .zero_allocate = &_zero_allocate,
            .state = state,
        };
    }

    pub fn deinit(self: *RosAllocator) void {
        const allocator: *std.mem.Allocator = @alignCast(@ptrCast(self.state));
        allocator.destroy(allocator);
    }

    fn _allocate(size: usize, state: ?*anyopaque) callconv(.C) ?*anyopaque {
        const allocator: *std.mem.Allocator = @alignCast(@ptrCast(state));

        const actual_size = size + @sizeOf(usize);
        const mem = allocator.alloc(u8, actual_size)
            catch return null;

        const len_ptr: *usize = @ptrCast(@alignCast(mem.ptr));
        len_ptr.* = actual_size;

        return mem.ptr + @sizeOf(usize);
    }

    fn _deallocate(ptr: ?*anyopaque, state: ?*anyopaque) callconv(.C) void {
        const allocator: *std.mem.Allocator = @alignCast(@ptrCast(state));

        if (ptr == null) {
            return;
        }
        const actual_ptr: [*]u8 = @ptrFromInt(@intFromPtr(ptr.?) - @sizeOf(usize));
        const len: *usize = @ptrCast(@alignCast(actual_ptr));

        allocator.free(actual_ptr[0..len.*]);
    }
    
    fn _reallocate(ptr: ?*anyopaque, size: usize, state: ?*anyopaque) callconv(.C) ?*anyopaque {
        const allocator: *std.mem.Allocator = @alignCast(@ptrCast(state));

        if (ptr == null) {
            return _allocate(size, state);
        }
        if (size == 0) {
            _deallocate(ptr, state);
            return null;
        }

        const actual_ptr: [*]u8 = @ptrFromInt(@intFromPtr(ptr.?) - @sizeOf(usize));
        const old_len: *usize = @ptrCast(@alignCast(actual_ptr));
        const old_mem = actual_ptr[0..old_len.*];

        const new_size = size + @sizeOf(usize);
        const mem = allocator.realloc(old_mem, new_size)
            catch return null;

        const len_ptr: *usize = @ptrCast(@alignCast(mem.ptr));
        len_ptr.* = new_size;

        return mem.ptr + @sizeOf(usize);
    }

    fn _zero_allocate(count: usize, size: usize, state: ?*anyopaque) callconv(.C) ?*anyopaque {
        const allocator: *std.mem.Allocator = @alignCast(@ptrCast(state));
        _ = allocator;

        const total = count * size;
        const ptr = _allocate(total, state)
            orelse return null;
        const mem: [*]u8 = @ptrCast(ptr);
        @memset(mem[0..total], 0);
        return mem;
    }

    pub fn default() RosAllocator {
        return @bitCast(c.rcutils_get_default_allocator());
    }
};

test RosAllocator {
    {
        var ralloc = try RosAllocator.init(std.testing.allocator);
        defer ralloc.deinit();
    }
    {
        var ralloc = try RosAllocator.init(std.testing.allocator);
        defer ralloc.deinit();
        {
            const ptr: ?*usize = @alignCast(@ptrCast(ralloc.allocate.?(@sizeOf(usize), ralloc.state)));
            defer ralloc.deallocate.?(ptr, ralloc.state);

            try std.testing.expect(ptr != null);
            ptr.?.* = 999;
            try std.testing.expectEqual(999, ptr.?.*);
        }
        {
            const ptr: ?*usize = @alignCast(@ptrCast(ralloc.zero_allocate.?(1, @sizeOf(usize), ralloc.state)));
            defer ralloc.deallocate.?(ptr, ralloc.state);

            try std.testing.expect(ptr != null);
            try std.testing.expectEqual(0, ptr.?.*);
        }
    }
}

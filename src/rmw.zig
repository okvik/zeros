const std = @import("std");

const zeros = @import("root.zig");
const c = zeros.c;

pub const RmwTime = extern struct {
    sec: u64,
    nsec: u64,

    pub const infinite: RmwTime = .{ .sec = 0x7FFF_FFFF, .nsec = 0xFFFF_FFFF };
    pub const unspecified: RmwTime = .{ .sec = 0, .nsec = 0 };
};

pub fn getImplementationIdentifier() []const u8 {
    const s = c.rmw_get_implementation_identifier();
    return s[0..std.mem.len(s)];
}

pub fn getSerializationFormat() []const u8 {
    const s = c.rmw_get_serialization_format();
    return s[0..std.mem.len(s)];
}

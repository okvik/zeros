const c = @cImport({
    @cInclude("std_msgs/msg/header.h");
});

const Header = @This();

////////////////////////////////////////////////////////////////////////////////

pub const Base = c.std_msgs__msg__Header;

base: Base = undefined,

pub const ts = c.rosidl_typesupport_c__get_message_type_support_handle__std_msgs__msg__Header;

pub fn init() !Header {
    var self = Header{};
    if (!c.std_msgs__msg__Header__init(&self.base))
        return error.Error;
    return self;
}

pub fn deinit(self: *Header) void {
    c.std_msgs__msg__Header__fini(&self.base);
}

pub fn create() !*Base {
    const self = c.std_msgs__msg__Header__create();
    if (self == null)
        return error.Error;
    return self;
}

pub fn destroy(self: *Base) void {
    c.std_msgs__msg__Header__destroy(self);
}

pub fn copy(self: *Header, other: *Header) !void {
    if (!c.std_msgs__msg__Header__copy(&self.base, &other.base))
        return error.Error;
}

pub fn equal(self: *Header, other: *Header) bool {
    return c.std_msgs__msg__Header__are_equal(&self.base, &other.base);
}

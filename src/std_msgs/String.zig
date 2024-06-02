const c = @cImport({
    @cInclude("std_msgs/msg/string.h");
});

const String = @This();

////////////////////////////////////////////////////////////////////////////////

pub const Base = c.std_msgs__msg__String;

base: Base = undefined,

pub const ts = c.rosidl_typesupport_c__get_message_type_support_handle__std_msgs__msg__String;

pub fn init() !String {
    var self = String{};
    if (!c.std_msgs__msg__String__init(&self.base))
        return error.Error;
    return self;
}

pub fn deinit(self: *String) void {
    c.std_msgs__msg__String__fini(&self.base);
}

pub fn create() !*Base {
    const self = c.std_msgs__msg__String__create();
    if (self == null)
        return error.Error;
    return self;
}

pub fn destroy(self: *Base) void {
    c.std_msgs__msg__String__destroy(self);
}

pub fn copy(self: *String, other: *String) !void {
    if (!c.std_msgs__msg__String__copy(&self.base, &other.base))
        return error.Error;
}

pub fn equal(self: *String, other: *String) bool {
    return c.std_msgs__msg__String__are_equal(&self.base, &other.base);
}

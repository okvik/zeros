const std = @import("std");

const zeros = @import("root.zig");
const c = zeros.c;
const errors = zeros.errors;
const RmwTime = zeros.rmw.RmwTime;

pub const PolicyKind = enum(c.rmw_qos_policy_kind_t) {
    invalid = c.RMW_QOS_POLICY_INVALID,
    durability = c.RMW_QOS_POLICY_DURABILITY,
    deadline = c.RMW_QOS_POLICY_DEADLINE,
    liveliness = c.RMW_QOS_POLICY_LIVELINESS,
    reliability = c.RMW_QOS_POLICY_RELIABILITY,
    history = c.RMW_QOS_POLICY_HISTORY,
    lifespan = c.RMW_QOS_POLICY_LIFESPAN,
    depth = c.RMW_QOS_POLICY_DEPTH,
    liveliness_lease_duration = c.RMW_QOS_POLICY_LIVELINESS_LEASE_DURATION,
    avoid_ros_namespace_conventions = c.RMW_QOS_POLICY_AVOID_ROS_NAMESPACE_CONVENTIONS,

    pub fn toStr(self: *const PolicyKind) [:0]const u8 {
        return std.mem.sliceTo(c.rmw_qos_policy_kind_to_str(@intFromEnum(self.*)), 0);
    }

    pub fn fromStr(self: [:0]const u8) PolicyKind {
        return @enumFromInt(c.rmw_qos_policy_kind_from_str(self.ptr));
    }
};

test PolicyKind {
    try std.testing.expectEqualStrings("durability", PolicyKind.durability.toStr());
    try std.testing.expectEqual(PolicyKind.durability, PolicyKind.fromStr("durability"));
}

pub const ReliabilityPolicy = enum(c.rmw_qos_reliability_policy_t) {
    system_default = c.RMW_QOS_POLICY_RELIABILITY_SYSTEM_DEFAULT,
    reliable = c.RMW_QOS_POLICY_RELIABILITY_RELIABLE,
    best_effort = c.RMW_QOS_POLICY_RELIABILITY_BEST_EFFORT,
    unknown = c.RMW_QOS_POLICY_RELIABILITY_UNKNOWN,

    pub fn toStr(self: *const ReliabilityPolicy) [:0]const u8 {
        return std.mem.sliceTo(c.rmw_qos_reliability_policy_to_str(@intFromEnum(self.*)), 0);
    }

    pub fn fromStr(self: [:0]const u8) ReliabilityPolicy {
        return @enumFromInt(c.rmw_qos_reliability_policy_from_str(self.ptr));
    }
};

test ReliabilityPolicy {
    try std.testing.expectEqualStrings("reliable", ReliabilityPolicy.reliable.toStr());
    try std.testing.expectEqual(ReliabilityPolicy.reliable, ReliabilityPolicy.fromStr("reliable"));
}

pub const HistoryPolicy = enum(c.rmw_qos_history_policy_t) {
    system_default = c.RMW_QOS_POLICY_HISTORY_SYSTEM_DEFAULT,
    keep_last = c.RMW_QOS_POLICY_HISTORY_KEEP_LAST,
    keep_all = c.RMW_QOS_POLICY_HISTORY_KEEP_ALL,
    unknown = c.RMW_QOS_POLICY_HISTORY_UNKNOWN,

    pub fn toStr(self: *const HistoryPolicy) [:0]const u8 {
        return std.mem.sliceTo(c.rmw_qos_history_policy_to_str(@intFromEnum(self.*)), 0);
    }

    pub fn fromStr(self: [:0]const u8) HistoryPolicy {
        return @enumFromInt(c.rmw_qos_history_policy_from_str(self.ptr));
    }
};

test HistoryPolicy {
    try std.testing.expectEqualStrings("keep_last", HistoryPolicy.keep_last.toStr());
    try std.testing.expectEqual(HistoryPolicy.keep_last, HistoryPolicy.fromStr("keep_last"));
}

pub const DurabilityPolicy = enum(c.rmw_qos_durability_policy_t) {
    system_default = c.RMW_QOS_POLICY_DURABILITY_SYSTEM_DEFAULT,
    transient_local = c.RMW_QOS_POLICY_DURABILITY_TRANSIENT_LOCAL,
    @"volatile" = c.RMW_QOS_POLICY_DURABILITY_VOLATILE,
    unknown = c.RMW_QOS_POLICY_DURABILITY_UNKNOWN,

    pub fn toStr(self: *const DurabilityPolicy) [:0]const u8 {
        return std.mem.sliceTo(c.rmw_qos_durability_policy_to_str(@intFromEnum(self.*)), 0);
    }

    pub fn fromStr(self: [:0]const u8) DurabilityPolicy {
        return @enumFromInt(c.rmw_qos_durability_policy_from_str(self.ptr));
    }
};

test DurabilityPolicy {
    try std.testing.expectEqualStrings("transient_local", DurabilityPolicy.transient_local.toStr());
    try std.testing.expectEqual(DurabilityPolicy.transient_local, DurabilityPolicy.fromStr("transient_local"));
}

pub const LivelinessPolicy = enum(c.rmw_qos_liveliness_policy_t) {
    system_default = c.RMW_QOS_POLICY_LIVELINESS_SYSTEM_DEFAULT,
    automatic = c.RMW_QOS_POLICY_LIVELINESS_AUTOMATIC,
    manual_by_node = c.RMW_QOS_POLICY_LIVELINESS_MANUAL_BY_NODE,
    manual_by_topic = c.RMW_QOS_POLICY_LIVELINESS_MANUAL_BY_TOPIC,
    unknown = c.RMW_QOS_POLICY_LIVELINESS_UNKNOWN,

    pub fn toStr(self: *const LivelinessPolicy) [:0]const u8 {
        return std.mem.sliceTo(c.rmw_qos_liveliness_policy_to_str(@intFromEnum(self.*)), 0);
    }

    pub fn fromStr(self: [:0]const u8) LivelinessPolicy {
        return @enumFromInt(c.rmw_qos_liveliness_policy_from_str(self.ptr));
    }
};

test LivelinessPolicy {
    try std.testing.expectEqualStrings("automatic", LivelinessPolicy.automatic.toStr());
    try std.testing.expectEqual(LivelinessPolicy.automatic, LivelinessPolicy.fromStr("automatic"));
}

pub const deadline_default = RmwTime.unspecified;
pub const lifespan_default = RmwTime.unspecified;
pub const liveliness_lease_duration_default = RmwTime.unspecified;

pub const Profile = extern struct {
    history: HistoryPolicy = .keep_last,
    depth: usize = 10,

    reliability: ReliabilityPolicy = .reliable,
    durability: DurabilityPolicy = .@"volatile",

    deadline: RmwTime = deadline_default,
    lifespan: RmwTime = lifespan_default,
    liveliness: LivelinessPolicy = .system_default,
    liveliness_lease_duration: RmwTime = liveliness_lease_duration_default,

    avoid_ros_namespace_conventions: bool = false,

    pub const default = @as(Profile, @bitCast(c.rmw_qos_profile_default));
    pub const sensor_data = @as(Profile, @bitCast(c.rmw_qos_profile_sensor_data));
    pub const parameters = @as(Profile, @bitCast(c.rmw_qos_profile_parameters));
    pub const services = @as(Profile, @bitCast(c.rmw_qos_profile_services_default));
    pub const parameter_events = @as(Profile, @bitCast(c.rmw_qos_profile_parameter_events));
    pub const system_default = @as(Profile, @bitCast(c.rmw_qos_profile_system_default));
    pub const unknown = @as(Profile, @bitCast(c.rmw_qos_profile_unknown));
    pub const rosout = @as(Profile, @bitCast(c.rcl_qos_profile_rosout_default));

    pub const Compatibility = enum(c.rmw_qos_compatibility_type_t) {
        ok = c.RMW_QOS_COMPATIBILITY_OK,
        warning = c.RMW_QOS_COMPATIBILITY_WARNING,
        @"error" = c.RMW_QOS_COMPATIBILITY_ERROR,
    };

    pub fn check(publisher: Profile, subscription: Profile, reason: ?[]u8) !Compatibility {
        var compat: c.rmw_qos_compatibility_type_t = undefined;
        const reason_ptr = if (reason) |r| r.ptr else null;
        const reason_len = if (reason) |r| r.len else 0;
        const rc = c.rmw_qos_profile_check_compatible(@bitCast(publisher), @bitCast(subscription), &compat, reason_ptr, reason_len);
        if (errors.check(rc)) |err|
            return err;
        return @enumFromInt(compat);
    }
    test check {
        const compat = try Profile.check(.default, .default, null);
        try std.testing.expectEqual(.warning, compat);
    }
};


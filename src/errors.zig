const std = @import("std");

const zeros = @import("root.zig");
const c = zeros.c;

// Copied from generated cimport.zig for reference, likely to get out of date eventually
// 
// Unfortunately the rcutils_ret_t overlaps with rmw_ret_t and thus also rcl_ret_t.
// Fortunately for us neither rmw nor rcl return rcutils_ret_t directly, but translate
// it to equivalent codes when needed. Also, so far we haven't used rcutils directly, but
// if or when we do a different check function specific to rcutils must be used.
const RCUTILS_RET_OK = @as(c_int, 0);
const RCUTILS_RET_WARN = @as(c_int, 1);
const RCUTILS_RET_ERROR = @as(c_int, 2);
const RCUTILS_RET_BAD_ALLOC = @as(c_int, 10);
const RCUTILS_RET_INVALID_ARGUMENT = @as(c_int, 11);
const RCUTILS_RET_NOT_ENOUGH_SPACE = @as(c_int, 12);
const RCUTILS_RET_NOT_INITIALIZED = @as(c_int, 13);
const RCUTILS_RET_NOT_FOUND = @as(c_int, 14);
const RCUTILS_RET_STRING_MAP_ALREADY_INIT = @as(c_int, 30);
const RCUTILS_RET_STRING_MAP_INVALID = @as(c_int, 31);
const RCUTILS_RET_STRING_KEY_NOT_FOUND = @as(c_int, 32);
const RCUTILS_RET_LOGGING_SEVERITY_MAP_INVALID = @as(c_int, 40);
const RCUTILS_RET_LOGGING_SEVERITY_STRING_INVALID = @as(c_int, 41);
const RCUTILS_RET_HASH_MAP_NO_MORE_ENTRIES = @as(c_int, 50);
const RMW_RET_OK = @as(c_int, 0);
const RMW_RET_ERROR = @as(c_int, 1);
const RMW_RET_TIMEOUT = @as(c_int, 2);
const RMW_RET_UNSUPPORTED = @as(c_int, 3);
const RMW_RET_BAD_ALLOC = @as(c_int, 10);
const RMW_RET_INVALID_ARGUMENT = @as(c_int, 11);
const RMW_RET_INCORRECT_RMW_IMPLEMENTATION = @as(c_int, 12);
const RMW_RET_NODE_NAME_NON_EXISTENT = @as(c_int, 203);
const RCL_RET_OK = RMW_RET_OK;
const RCL_RET_ERROR = RMW_RET_ERROR;
const RCL_RET_TIMEOUT = RMW_RET_TIMEOUT;
const RCL_RET_BAD_ALLOC = RMW_RET_BAD_ALLOC;
const RCL_RET_INVALID_ARGUMENT = RMW_RET_INVALID_ARGUMENT;
const RCL_RET_UNSUPPORTED = RMW_RET_UNSUPPORTED;
const RCL_RET_ALREADY_INIT = @as(c_int, 100);
const RCL_RET_NOT_INIT = @as(c_int, 101);
const RCL_RET_MISMATCHED_RMW_ID = @as(c_int, 102);
const RCL_RET_TOPIC_NAME_INVALID = @as(c_int, 103);
const RCL_RET_SERVICE_NAME_INVALID = @as(c_int, 104);
const RCL_RET_UNKNOWN_SUBSTITUTION = @as(c_int, 105);
const RCL_RET_ALREADY_SHUTDOWN = @as(c_int, 106);
const RCL_RET_NODE_INVALID = @as(c_int, 200);
const RCL_RET_NODE_INVALID_NAME = @as(c_int, 201);
const RCL_RET_NODE_INVALID_NAMESPACE = @as(c_int, 202);
const RCL_RET_NODE_NAME_NON_EXISTENT = @as(c_int, 203);
const RCL_RET_PUBLISHER_INVALID = @as(c_int, 300);
const RCL_RET_SUBSCRIPTION_INVALID = @as(c_int, 400);
const RCL_RET_SUBSCRIPTION_TAKE_FAILED = @as(c_int, 401);
const RCL_RET_CLIENT_INVALID = @as(c_int, 500);
const RCL_RET_CLIENT_TAKE_FAILED = @as(c_int, 501);
const RCL_RET_SERVICE_INVALID = @as(c_int, 600);
const RCL_RET_SERVICE_TAKE_FAILED = @as(c_int, 601);
const RCL_RET_TIMER_INVALID = @as(c_int, 800);
const RCL_RET_TIMER_CANCELED = @as(c_int, 801);
const RCL_RET_WAIT_SET_INVALID = @as(c_int, 900);
const RCL_RET_WAIT_SET_EMPTY = @as(c_int, 901);
const RCL_RET_WAIT_SET_FULL = @as(c_int, 902);
const RCL_RET_INVALID_REMAP_RULE = @as(c_int, 1001);
const RCL_RET_WRONG_LEXEME = @as(c_int, 1002);
const RCL_RET_INVALID_ROS_ARGS = @as(c_int, 1003);
const RCL_RET_INVALID_PARAM_RULE = @as(c_int, 1010);
const RCL_RET_INVALID_LOG_LEVEL_RULE = @as(c_int, 1020);
const RCL_RET_EVENT_INVALID = @as(c_int, 2000);
const RCL_RET_EVENT_TAKE_FAILED = @as(c_int, 2001);
const RCL_RET_LIFECYCLE_STATE_REGISTERED = @as(c_int, 3000);
const RCL_RET_LIFECYCLE_STATE_NOT_REGISTERED = @as(c_int, 3001);
const RCL_RET_ACTION_NAME_INVALID = @as(c_int, 2000);
const RCL_RET_ACTION_GOAL_ACCEPTED = @as(c_int, 2100);
const RCL_RET_ACTION_GOAL_REJECTED = @as(c_int, 2101);
const RCL_RET_ACTION_CLIENT_INVALID = @as(c_int, 2102);
const RCL_RET_ACTION_CLIENT_TAKE_FAILED = @as(c_int, 2103);
const RCL_RET_ACTION_SERVER_INVALID = @as(c_int, 2200);
const RCL_RET_ACTION_SERVER_TAKE_FAILED = @as(c_int, 2201);
const RCL_RET_ACTION_GOAL_HANDLE_INVALID = @as(c_int, 2300);
const RCL_RET_ACTION_GOAL_EVENT_INVALID = @as(c_int, 2301);
const RCLC_RET_ACTION_WAIT_RESULT_REQUEST = @as(c_int, 2104);

pub const Error = error{
    // rmw return codes

    // Ok is not an error

    Error,
    Timeout,
    BadAlloc,
    InvalidArgument,
    Unsupported,

    // rmw return codes (ones without an rcl alias)
    IncorrectRmwImplementation,

    // rcl return codes
    AlreadyInit,
    NotInit,
    MismatchedRmwId,
    TopicNameInvalid,
    ServiceNameInvalid,
    UnknownSubstitution,
    AlreadyShutdown,

    // rcl node specific return codes
    NodeInvalid,
    NodeInvalidName,
    NodeInvalidNamespace,
    NodeNameNonExistent,

    // rcl publisher specific return codes
    PublisherInvalid,

    // rcl subscription specific return codes
    SubscriptionInvalid,
    SubscriptionTakeFailed,

    // rcl service client return codes
    ClientInvalid,
    ClientTakeFailed,

    // rcl service server return codes
    ServiceInvalid,
    ServiceTakeFailed,

    // rcl timer specific return codes
    TimerInvalid,
    TimerCanceled,

    // rcl wait and wait set specific return codes
    WaitSetInvalid,
    WaitSetEmpty,
    WaitSetFull,

    // rcl argument parsing specific return codes
    InvalidRemapRule,
    WrongLexeme,
    InvalidRosArgs,
    InvalidParamRule,
    InvalidLogLevelRule,

    // rcl event specific return codes
    EventInvalid,
    EventTakeFailed,

    // rcl lifecycle state register return codes
    LifecycleStateRegistered,
    LifecycleStateNotRegistered,

    // rcl action specific return codes
    ActionNameOrEventInvalid, // TODO: fix next release, see below
    ActionGoalAccepted, // not really an error
    ActionGoalRejected, // not really an error
    ActionClientInvalid,
    ActionClientTakeFailed,
    ActionServerInvalid,
    ActionServerTakeFailed,
    ActionGoalHandleInvalid,
    ActionGoalEventInvalid,
    ActionWaitResultRequest, // rclc

    // Unknown error code
    ZerosUnknownError,
};

pub fn check(ret: i32) ?Error {
    switch (ret) {
        c.RCL_RET_OK => return null,

        c.RMW_RET_INCORRECT_RMW_IMPLEMENTATION => return Error.IncorrectRmwImplementation,

        c.RCL_RET_ERROR => return Error.Error,
        c.RCL_RET_TIMEOUT => return Error.Timeout,
        c.RCL_RET_BAD_ALLOC => return Error.BadAlloc,
        c.RCL_RET_INVALID_ARGUMENT => return Error.InvalidArgument,
        c.RCL_RET_UNSUPPORTED => return Error.Unsupported,

        c.RCL_RET_ALREADY_INIT => return Error.AlreadyInit,
        c.RCL_RET_NOT_INIT => return Error.NotInit,
        c.RCL_RET_MISMATCHED_RMW_ID => return Error.MismatchedRmwId,
        c.RCL_RET_TOPIC_NAME_INVALID => return Error.TopicNameInvalid,
        c.RCL_RET_SERVICE_NAME_INVALID => return Error.ServiceNameInvalid,
        c.RCL_RET_UNKNOWN_SUBSTITUTION => return Error.UnknownSubstitution,
        c.RCL_RET_ALREADY_SHUTDOWN => return Error.AlreadyShutdown,

        c.RCL_RET_NODE_INVALID => return Error.NodeInvalid,
        c.RCL_RET_NODE_INVALID_NAME => return Error.NodeInvalidName,
        c.RCL_RET_NODE_INVALID_NAMESPACE => return Error.NodeInvalidNamespace,
        c.RCL_RET_NODE_NAME_NON_EXISTENT => return Error.NodeNameNonExistent,

        c.RCL_RET_PUBLISHER_INVALID => return Error.PublisherInvalid,

        c.RCL_RET_SUBSCRIPTION_INVALID => return Error.SubscriptionInvalid,
        c.RCL_RET_SUBSCRIPTION_TAKE_FAILED => return Error.SubscriptionTakeFailed,

        c.RCL_RET_CLIENT_INVALID => return Error.ClientInvalid,
        c.RCL_RET_CLIENT_TAKE_FAILED => return Error.ClientTakeFailed,

        c.RCL_RET_SERVICE_INVALID => return Error.ServiceInvalid,
        c.RCL_RET_SERVICE_TAKE_FAILED => return Error.ServiceTakeFailed,

        c.RCL_RET_TIMER_INVALID => return Error.TimerInvalid,
        c.RCL_RET_TIMER_CANCELED => return Error.TimerCanceled,

        c.RCL_RET_WAIT_SET_INVALID => return Error.WaitSetInvalid,
        c.RCL_RET_WAIT_SET_EMPTY => return Error.WaitSetEmpty,
        c.RCL_RET_WAIT_SET_FULL => return Error.WaitSetFull,

        c.RCL_RET_INVALID_REMAP_RULE => return Error.InvalidRemapRule,
        c.RCL_RET_WRONG_LEXEME => return Error.WrongLexeme,
        c.RCL_RET_INVALID_ROS_ARGS => return Error.InvalidRosArgs,
        c.RCL_RET_INVALID_PARAM_RULE => return Error.InvalidParamRule,
        c.RCL_RET_INVALID_LOG_LEVEL_RULE => return Error.InvalidLogLevelRule,

        c.RCL_RET_EVENT_TAKE_FAILED => return Error.EventTakeFailed,

        c.RCL_RET_LIFECYCLE_STATE_REGISTERED => return Error.LifecycleStateRegistered,
        c.RCL_RET_LIFECYCLE_STATE_NOT_REGISTERED => return Error.LifecycleStateNotRegistered,

        // This conflict will be fixed in next release
        // c.RCL_RET_EVENT_INVALID,
        c.RCL_RET_ACTION_NAME_INVALID => return Error.ActionNameOrEventInvalid,

        c.RCL_RET_ACTION_GOAL_ACCEPTED => return Error.ActionGoalAccepted,
        c.RCL_RET_ACTION_GOAL_REJECTED => return Error.ActionGoalRejected,
        c.RCL_RET_ACTION_CLIENT_INVALID => return Error.ActionClientInvalid,
        c.RCL_RET_ACTION_CLIENT_TAKE_FAILED => return Error.ActionClientTakeFailed,
        c.RCL_RET_ACTION_SERVER_INVALID => return Error.ActionServerInvalid,
        c.RCL_RET_ACTION_SERVER_TAKE_FAILED => return Error.ActionServerTakeFailed,
        c.RCL_RET_ACTION_GOAL_HANDLE_INVALID => return Error.ActionGoalHandleInvalid,
        c.RCL_RET_ACTION_GOAL_EVENT_INVALID => return Error.ActionGoalEventInvalid,
        c.RCLC_RET_ACTION_WAIT_RESULT_REQUEST => return Error.ActionWaitResultRequest,

        else => return Error.ZerosUnknownError,
    }
}

pub fn logError() void {
    const err_string = std.mem.sliceTo(&getErrorString().str, 0);
    std.log.err("unhandled error: {s}", .{err_string});
}

pub const ErrorState = c.rcl_error_state_t;
pub const ErrorString = c.rcl_error_string_t;

/// Set the error message, as well as the file and line on which it occurred.
pub fn setErrorState(message: [:0]const u8, location: std.builtin.SourceLocation) void {
    c.rcutils_set_error_state(message.ptr, location.file.ptr, location.line);
}

/// Return an ErrorState which was set with setErrorState.
pub fn getErrorState() ?*const ErrorState {
    return @ptrCast(c.rcl_get_error_state());
}

/// Return the error message followed by `, at <file>:<line>` if set, else "error not set".
pub fn getErrorString() ErrorString {
    return c.rcl_get_error_string();
}

/// Return `true` if the error is set, otherwise `false`.
pub fn errorIsSet() bool {
    return c.rcl_error_is_set();
}

/// Reset the error state by clearing any previously set error state.
pub fn resetError() void {
    c.rcl_reset_error();
}

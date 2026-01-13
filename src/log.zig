const utils = @import("utils.zig");

const Level = enum(u8) {
    none,
    err,
    warn,
    info,
};

pub var level: Level = .none;

pub fn info(comptime fmt: []const u8, args: anytype) void {
    if (@intFromEnum(level) >= @intFromEnum(Level.info))
        utils.print("info: " ++ fmt ++ "\n", args);
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    if (@intFromEnum(level) >= @intFromEnum(Level.warn))
        utils.print("warn: " ++ fmt ++ "\n", args);
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    if (@intFromEnum(level) >= @intFromEnum(Level.err))
        utils.print("warn: " ++ fmt ++ "\n", args);
}

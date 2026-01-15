const std = @import("std");
const mem = std.mem;

const COLOR_RESET = "\x1b[0m";
const FORE_COLOR_RED = "\x1b[31m";

pub fn print(comptime fmt: []const u8, args: anytype) void {
    var stdout = std.fs.File.stdout().writer(&.{}).interface;
    stdout.print(fmt, args) catch |e| {
        std.debug.print("err:{any}\n", .{e});
        std.debug.print("Should print:\n", .{});
        std.debug.print(fmt, args);
        unreachable;
    };
}

pub fn printNoArgs(comptime str: []const u8) void {
    print(str, .{});
}

pub fn print_error(comptime fmt: []const u8, args: anytype) void {
    printNoArgs(FORE_COLOR_RED);
    print(fmt, args);
    printNoArgs(COLOR_RESET);
}

pub fn strEql(s1: []const u8, s2: []const u8) bool {
    return mem.eql(u8, s1, s2);
}

test strEql {
    try std.testing.expect(strEql("This is a test", "This is a test") == true);
    try std.testing.expectEqual(strEql("This a false test", "Yes"), false);
}

pub fn optionType(comptime T: type) type {
    return union(enum) {
        some: T,
        none,
    };
}

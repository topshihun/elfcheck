const std = @import("std");
const mem = std.mem;

const COLOR_RESET = "\x1b[0m";
const FORE_COLOR_RED = "\x1b[31m";

pub fn print(comptime fmt: []const u8, args: anytype) void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();

        if (deinit_status == .leak) @panic("memory leak");
    }

    const out_buffer = std.fmt.allocPrint(allocator, fmt, args) catch {
        @panic("alloc error");
    };
    defer allocator.free(out_buffer);
    const std_out = std.fs.File.stdout();
    std_out.writeAll(out_buffer) catch |err| {
        @panic(@errorName(err));
    };
}

pub fn printNoArgs(comptime str: []const u8) void {
    std.fs.File.stdout().writeAll(str) catch |err| {
        @panic(@errorName(err));
    };
}

pub fn print_error(comptime fmt: []const u8, args: anytype) void {
    print(FORE_COLOR_RED, .{});
    print(fmt, args);
    print(COLOR_RESET, .{});
}

pub fn strEql(s1: []const u8, s2: []const u8) bool {
    return mem.eql(u8, s1, s2);
}

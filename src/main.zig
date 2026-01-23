const std = @import("std");
const log = @import("log.zig");

const parseArgs = @import("parse_args.zig").parseArgs;
const readElf = @import("read_elf.zig").readElf;
const itemEq = @import("check.zig").eq;
const items_fns = @import("check.zig").items_fns;

const ExpectItems = @import("check.zig").ExpectItems;

const DIFF_SUCCESS_CODE = 0;
const DIFF_FAILED_CODE = 1;
const OTHER_ERROR_CODE = 2;

pub fn main() u8 {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var gpa = std.heap.DebugAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) unreachable;
    }

    const arg_item_checked, const file = parseArgs() catch return OTHER_ERROR_CODE;
    log.info("finish parse args", .{});

    // log print expect items after parse args
    log.info("type name: {s}", .{@typeName(ExpectItems)});
    const allocator = gpa.allocator();
    for (items_fns) |item_fns| {
        const value = item_fns.format_fn(allocator, &arg_item_checked) catch @panic("Alloca out of memory");
        defer allocator.free(value);
        log.info("\t {s}={s}", .{ item_fns.name, value });
    }

    const file_item_checked = readElf(file) catch return OTHER_ERROR_CODE;
    log.info("finish read elf", .{});
    const diff_result = itemEq(&file_item_checked, &arg_item_checked);
    log.info("finish diff", .{});
    if (diff_result) {
        return DIFF_SUCCESS_CODE;
    } else {
        return DIFF_FAILED_CODE;
    }
}

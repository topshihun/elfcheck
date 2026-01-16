const std = @import("std");
const log = @import("log.zig");

const parseArgs = @import("parse_args.zig").parseArgs;
const readElf = @import("read_elf.zig").readElf;
const itemEq = @import("check.zig").eq;

const ExpectItems = @import("check.zig").ExpectItems;

const DIFF_SUCCESS_CODE = 0;
const DIFF_FAILED_CODE = 1;
const OTHER_ERROR_CODE = 2;

pub fn main() u8 {
    const arg_item_checked, const file = parseArgs() catch return OTHER_ERROR_CODE;
    log.info("finish parse args", .{});

    // print expect items after parse args
    log.info("type name: {s}", .{@typeName(ExpectItems)});
    // const info = @typeInfo(ExpectItems);
    // inline for (info.@"struct".fields) |field| {
    //     const value = @field(arg_item_checked, field.name);
    //     log.info("\t {s} = {s}", .{ field.name, if (value == .some) if (value.some) "true" else "false" else "none" });
    // }

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

const std = @import("std");
const log = @import("log.zig");

const parseArgs = @import("parse_args.zig").parseArgs;
const readElf = @import("read_elf.zig").readElf;
const item_checked_diff = @import("check.zig").diff;

const DIFF_SUCCESS_CODE = 0;
const DIFF_FAILED_CODE = 1;
const OTHER_ERROR_CODE = 2;

pub fn main() u8 {
    const arg_item_checked, const file = parseArgs() catch return OTHER_ERROR_CODE;
    log.info("finish parse args", .{});
    const file_item_checked = readElf(file) catch return OTHER_ERROR_CODE;
    log.info("finish read elf", .{});
    const diff_result = item_checked_diff(&file_item_checked, &arg_item_checked);
    log.info("finish diff", .{});
    if(diff_result) {
        return DIFF_SUCCESS_CODE;
    } else {
        return DIFF_FAILED_CODE;
    }
}

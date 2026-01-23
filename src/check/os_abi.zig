const std = @import("std");
const elf = std.elf;
const check = @import("../check.zig");
const utils = @import("../utils.zig");
const log = @import("../log.zig");

const Item = check.Item;
const ItemFns = check.ItemFns;
const ExpectItems = check.ExpectItems;
const Realitems = check.RealItems;

const OPTION_OS_ABI: utils.optionType(elf.OSABI) = .none;
const OS_ABI = "os_abi";

pub const os_abi_item: Item = .{
    .name = OS_ABI,
    .type = elf.OSABI,
    .default_value_ptr = &OPTION_OS_ABI,
};

pub const os_abi_fns: ItemFns = .{
    .name = OS_ABI,
    .change_fn = &changeOsAbi,
    .eq_fn = &eqOsAbi,
    .format_fn = &formatOsAbi,
};

fn changeOsAbi(expect_items: *ExpectItems, fmt: []const u8) bool {
    for (std.meta.fieldNames(elf.OSABI)) |os_abi_name| {
        if (std.mem.eql(u8, os_abi_name, fmt)) {
            const os_abi = std.meta.stringToEnum(elf.OSABI, os_abi_name) orelse unreachable;
            expect_items.os_abi = .{ .some = os_abi };
            return true;
        }
    }
    log.err("{s} isn't OSABI value", .{fmt});
    return false;
}

fn eqOsAbi(real_items: *const Realitems, expect_items: *const ExpectItems) bool {
    if (expect_items.os_abi == .some) {
        if (real_items.os_abi != expect_items.os_abi.some) {
            log.warn("OSABI is not correct", .{});
            return false;
        }
    }
    return true;
}

fn formatOsAbi(gpa: std.mem.Allocator, expect_items: *const ExpectItems) ![]const u8 {
    if (expect_items.os_abi == .some) {
        return std.fmt.allocPrint(gpa, "some({s})", .{@tagName(expect_items.os_abi.some)});
    }
    return std.fmt.allocPrint(gpa, "none", .{});
}

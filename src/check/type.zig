const std = @import("std");
const elf = std.elf;
const check = @import("../check.zig");
const utils = @import("../utils.zig");
const log = @import("../log.zig");

const Item = check.Item;
const ItemFns = check.ItemFns;
const ExpectItems = check.ExpectItems;
const RealItems = check.RealItems;

const OPTION_TYPE: utils.optionType(elf.ET) = .none;
const TYPE = "type";

pub const type_item: Item = .{
    .name = TYPE,
    .type = elf.ET,
    .default_value_ptr = &OPTION_TYPE,
    .describe = "zig reference: https://ziglang.org/documentation/0.15.2/std/#std.elf.ET",
};

pub const type_fns: ItemFns = .{
    .name = TYPE,
    .change_fn = &changeType,
    .eq_fn = &eqType,
    .format_fn = &formatType,
};

fn changeType(expect_items: *ExpectItems, fmt: []const u8) bool {
    for (std.meta.fieldNames(elf.ET)) |type_name| {
        if (std.mem.eql(u8, type_name, fmt)) {
            const @"type" = std.meta.stringToEnum(elf.ET, type_name) orelse unreachable;
            expect_items.type = .{ .some = @"type" };
            return true;
        }
    }
    return false;
}

fn eqType(real_items: *const RealItems, expect_items: *const ExpectItems) bool {
    if (expect_items.type == .some) {
        if (real_items.type != expect_items.type.some) {
            log.warn("Tpe is not correct", .{});
            return false;
        }
    }
    return true;
}

fn formatType(gpa: std.mem.Allocator, expect_items: *const ExpectItems) ![]const u8 {
    if (expect_items.type == .some) {
        return std.fmt.allocPrint(gpa, "some({s})", .{@tagName(expect_items.type.some)});
    }
    return std.fmt.allocPrint(gpa, "none", .{});
}

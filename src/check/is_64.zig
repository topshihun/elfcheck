const std = @import("std");
const utils = @import("../utils.zig");

const check = @import("../check.zig");
const Item = check.Item;
const ItemFns = check.ItemFns;
const ExpectItems = check.ExpectItems;
const RealItems = check.RealItems;

const log = @import("../log.zig");

const OPTION_BOOL_DEFAULT: utils.optionType(bool) = .none;

pub const is_64_item = Item{
    .name = "is_64",
    .type = bool,
    .default_value_ptr = &OPTION_BOOL_DEFAULT,
};

pub const is_64_fns = ItemFns{
    .name = "is_64",
    .change_fn = &changeIs64,
    .eq_fn = &eqIs64,
};

fn changeIs64(expect_items: *ExpectItems, value: []const u8) bool {
    if (utils.strEql(value, "true")) {
        expect_items.is_64 = .{ .some = true };
        log.info("is_64 change to true", .{});
    } else if (utils.strEql(value, "false")) {
        expect_items.is_64 = .{ .some = false };
        log.info("is_64 change to false", .{});
    } else {
        log.err("{s} is invalid for is_64", .{value});
        return false;
    }
    return true;
}

fn eqIs64(real_items: *const RealItems, expect_items: *const ExpectItems) bool {
    if (expect_items.is_64 == .some) {
        if (real_items.is_64 != expect_items.is_64.some) {
            log.warn("is_64 is correct", .{});
            return false;
        }
    }
    return true;
}

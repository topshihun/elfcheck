const std = @import("std");
const utils = @import("../utils.zig");

const check = @import("../check.zig");
const Item = check.Item;
const ItemFns = check.ItemFns;
const ExpectItem = check.ExpectItemCheck;
const RealItem = check.RealItemCheck;

const OPTION_BOOL_DEFAULT: ?bool = null;

pub const is_64_item = Item{
    .name = "is_64",
    .type = bool,
    .default_value_ptr = &OPTION_BOOL_DEFAULT,
};

pub const is_64_fns = ItemFns{
    .name = "is_64",
    .change_fn = &changeIs64,
    .diff_fn = &diffIs64,
};

fn changeIs64(item_check: *ExpectItem, value: []const u8) bool {
    if (utils.strEql(value, "true")) {
        item_check.is_64 = true;
    } else if (utils.strEql(value, "false")) {
        item_check.is_64 = false;
    } else return false;
    return true;
}

fn diffIs64(real_item_checked: *const RealItem, expect_item_checked: *const ExpectItem) bool {
    if (expect_item_checked.is_64) |is_64| {
        if (real_item_checked.is_64 != is_64) return false;
    }
    return true;
}

const std = @import("std");
const elf = std.elf;
const mem = std.mem;

const log = @import("log.zig");
const utils = @import("utils.zig");

pub const Item = struct {
    name: [:0]const u8,
    type: type,
    default_value_ptr: *const anyopaque,
};

/// change_fn:
// TODO: change name, because describe
pub const ItemFns = struct {
    name: []const u8,
    describe: []const u8 = "No describe",
    change_fn: *const fn (*ExpectItems, []const u8) bool,
    eq_fn: *const fn (*const RealItems, *const ExpectItems) bool,
};

const is_64 = @import("check/is_64.zig");
const machine = @import("check/machine.zig");

pub const items = [_]*const Item{
    &is_64.is_64_item,
    &machine.machine_item,
};

pub const items_fns = [_]*const ItemFns{
    &is_64.is_64_fns,
    &machine.machine_fns,
};

const EROption = enum {
    expect,
    real,
};

pub const ExpectItems = ERItemType(.expect);

pub const RealItems = ERItemType(.real);

fn ERItemType(er_option: EROption) type {
    var struct_fields: [items.len]std.builtin.Type.StructField = undefined;

    for (items, 0..) |item, i| {
        const item_type = switch (er_option) {
            .expect => utils.optionType(item.type),
            .real => item.type,
        };
        const default_value_ptr: ?*const anyopaque = switch (er_option) {
            .expect => item.default_value_ptr,
            .real => null,
        };

        struct_fields[i] = .{
            .name = item.name,
            .type = item_type,
            .default_value_ptr = default_value_ptr,
            .is_comptime = false,
            .alignment = @alignOf(item_type),
        };
    }

    return @Type(.{
        .@"struct" = .{
            .layout = .auto,
            .fields = &struct_fields,
            .decls = &.{},
            .is_tuple = false,
        },
    });
}

pub fn eq(real_item_checked: *const RealItems, expect_item_checked: *const ExpectItems) bool {
    for (items_fns) |item_fns| {
        if (!item_fns.eq_fn(real_item_checked, expect_item_checked)) {
            log.warn("diff is false", .{});
            return false;
        }
    }
    return true;
}

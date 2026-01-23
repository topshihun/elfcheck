const std = @import("std");
const elf = std.elf;
const mem = std.mem;

const log = @import("log.zig");
const utils = @import("utils.zig");

// Item have to separate ItemFns
// because deepdnecy loop error(Item -> ExpectItems -> Item)
pub const Item = struct {
    name: [:0]const u8,
    type: type,
    default_value_ptr: *const anyopaque,
    describe: []const u8 = "No describe",
};

pub const ItemFns = struct {
    name: []const u8,
    change_fn: *const fn (*ExpectItems, []const u8) bool,
    eq_fn: *const fn (*const RealItems, *const ExpectItems) bool,
    // T must be ExpectItems or RealItems
    format_fn: *const fn (gpa: std.mem.Allocator, expect_items: *const ExpectItems) mem.Allocator.Error![]const u8,
};

const is_64 = @import("check/is_64.zig");
const endian = @import("check/endian.zig");
const os_abi = @import("check/os_abi.zig");
const @"type" = @import("check/type.zig");
const machine = @import("check/machine.zig");

pub const items = [_]*const Item{
    &is_64.is_64_item,
    &endian.endian_item,
    &os_abi.os_abi_item,
    &@"type".type_item,
    &machine.machine_item,
};

pub const items_fns = [_]*const ItemFns{
    &is_64.is_64_fns,
    &endian.endian_fns,
    &os_abi.os_abi_fns,
    &@"type".type_fns,
    &machine.machine_fns,
};

const EROption = enum {
    expect,
    real,
};

pub const ExpectItems = ERItemType(.expect);

pub const RealItems = ERItemType(.real);

fn ERItemType(comptime er_option: EROption) type {
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

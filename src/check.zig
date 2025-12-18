const std = @import("std");
const elf = std.elf;
const mem = std.mem;

pub const Item = struct {
    name: [:0]const u8,
    type: type,
    default_value_ptr: ?*const anyopaque,
};

/// change_fn:
// TODO: change name, because describe
pub const ItemFns = struct {
    name: []const u8,
    describe: []const u8 = "No describe",
    change_fn: *const fn (*ExpectItemCheck, []const u8) bool,
    diff_fn: *const fn (*const RealItemCheck, *const ExpectItemCheck) bool,
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

pub const ExpectItemCheck = expect_type: {
    var struct_fields: [items.len]std.builtin.Type.StructField = undefined;

    for (items, 0..) |item, i| {
        struct_fields[i] = .{
            .name = item.name,
            .type = ?item.type,
            .default_value_ptr = item.default_value_ptr,
            .is_comptime = false,
            .alignment = @alignOf(item.type),
        };
    }

    break :expect_type @Type(.{
        .@"struct" = .{
            .layout = .auto,
            .fields = &struct_fields,
            .decls = &.{},
            .is_tuple = false,
        },
    });
};

pub const RealItemCheck = real_type: {
    var struct_fields: [items.len]std.builtin.Type.StructField = undefined;

    for (items, 0..) |item, i| {
        struct_fields[i] = .{
            .name = item.name,
            .type = item.type,
            .default_value_ptr = null,
            .is_comptime = false,
            .alignment = @alignOf(item.type),
        };
    }

    break :real_type @Type(.{
        .@"struct" = .{
            .layout = .auto,
            .fields = &struct_fields,
            .decls = &.{},
            .is_tuple = false,
        },
    });
};

pub fn diff(real_item_checked: *const RealItemCheck, expect_item_checked: *const ExpectItemCheck) bool {
    for (items_fns) |item_fns| {
        if (item_fns.diff_fn(real_item_checked, expect_item_checked))
            return false;
    }
    return true;
}

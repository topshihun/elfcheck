const std = @import("std");
const check = @import("../check.zig");
const utils = @import("../utils.zig");
const log = @import("../log.zig");

const Item = check.Item;
const ItemFns = check.ItemFns;
const ExpectItems = check.ExpectItems;
const RealItems = check.RealItems;

const OPTION_ENDIAN: utils.optionType(std.builtin.Endian) = .none;
const ENDIAN = "endian";

pub const endian_item: Item = .{
    .name = ENDIAN,
    .type = std.builtin.Endian,
    .default_value_ptr = &OPTION_ENDIAN,
    .short_describe = "little, big",
    .values = &[_][]const u8{ "little", "big" },
};

pub const endian_fns: ItemFns = .{
    .name = ENDIAN,
    .change_fn = &changeEndian,
    .eq_fn = &eqEndian,
    .format_fn = &formatEndian,
};

fn changeEndian(expect_items: *ExpectItems, fmt: []const u8) bool {
    inline for (std.meta.fieldNames(std.builtin.Endian)) |endian_name| {
        if (std.mem.eql(u8, endian_name, fmt)) {
            log.info("endian changed: {s}", .{endian_name});
            const endian = std.meta.stringToEnum(std.builtin.Endian, endian_name) orelse unreachable;
            expect_items.endian = .{ .some = endian };
            return true;
        }
    }
    log.err("{s} isn't Endian value", .{fmt});
    return false;
}

fn eqEndian(real_items: *const RealItems, expect_items: *const ExpectItems) bool {
    if (expect_items.endian == .some) {
        if (real_items.endian != expect_items.endian.some) {
            log.warn("Endian is not correct: real={any}, expect={any}", .{ real_items.endian, expect_items.endian.some });
            return false;
        }
    }
    return true;
}

fn formatEndian(gpa: std.mem.Allocator, expect_items: *const ExpectItems) ![]const u8 {
    if (expect_items.endian == .some) {
        return std.fmt.allocPrint(gpa, "some({s})", .{@tagName(expect_items.endian.some)});
    }
    return std.fmt.allocPrint(gpa, "none", .{});
}

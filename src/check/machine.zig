const std = @import("std");
const elf = std.elf;

const check = @import("../check.zig");
const Item = check.Item;
const ItemFns = check.ItemFns;
const ExpectItems = check.ExpectItems;
const RealItems = check.RealItems;

const utils = @import("../utils.zig");
const log = @import("../log.zig");

const OPTION_EM_DEFAULT: utils.optionType(elf.EM) = .none;
const MACHINE = "machine";

pub const machine_item = Item{
    .name = MACHINE,
    .type = elf.EM,
    .default_value_ptr = &OPTION_EM_DEFAULT,
    .short_describe = "zig refernece: https://ziglang.org/documentation/0.15.2/std/#std.elf.EM",
    .values = valuesMachine(),
};

fn valuesMachine() []const []const u8 {
    return std.meta.fieldNames(elf.EM);
}

pub const machine_fns = ItemFns{
    .name = MACHINE,
    .change_fn = &changeMachine,
    .eq_fn = &eqMachine,
    .format_fn = &formatMachine,
};

fn changeMachine(expect_items: *ExpectItems, fmt: []const u8) bool {
    inline for (std.meta.fieldNames(elf.EM)) |machine_name| {
        if (utils.strEql(machine_name, fmt)) {
            // elf_em is impossibly null
            const elf_em = std.meta.stringToEnum(elf.EM, machine_name) orelse std.debug.panic("There is no {s} in EM", .{machine_name});
            expect_items.machine = .{ .some = elf_em };
            return true;
        }
    }
    return false;
}

fn eqMachine(real_items: *const RealItems, expect_items: *const ExpectItems) bool {
    if (expect_items.machine == .some) {
        if (real_items.machine != expect_items.machine.some) {
            log.warn("Machine is not correct", .{});
            return false;
        }
    }
    return true;
}

fn formatMachine(gpa: std.mem.Allocator, expect_items: *const ExpectItems) ![]const u8 {
    if (expect_items.machine == .some) {
        return std.fmt.allocPrint(gpa, "some({s})", .{@tagName(expect_items.machine.some)});
    }
    return std.fmt.allocPrint(gpa, "none", .{});
}

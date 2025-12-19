const std = @import("std");
const elf = std.elf;

const check = @import("../check.zig");
const Item = check.Item;
const ItemFns = check.ItemFns;
const ExpectItem = check.ExpectItemCheck;
const RealItem = check.RealItemCheck;

const utils = @import("../utils.zig");
const log = @import("../log.zig");

const OPTION_EM_DEFAULT: utils.optionType(elf.EM) = .none;
const MACHINE = "machine";

pub const machine_item = Item{
    .name = MACHINE,
    .type = elf.EM,
    .default_value_ptr = &OPTION_EM_DEFAULT,
};

pub const machine_fns = ItemFns{
    .name = MACHINE,
    .change_fn = &changeMachine,
    .diff_fn = &diffMachine,
};

fn changeMachine(expect_item_check: *ExpectItem, fmt: []const u8) bool {
    inline for (std.meta.fieldNames(elf.EM)) |machine_name| {
        if (utils.strEql(machine_name, fmt)) {
            // elf_em is impossibly null
            const elf_em = std.meta.stringToEnum(elf.EM, machine_name) orelse std.debug.panic("There is no {s} in EM", .{machine_name});
            expect_item_check.machine = .{ .some = elf_em };
            return true;
        }
    }
    return false;
}

fn diffMachine(real_item_check: *const RealItem, expect_item_check: *const ExpectItem) bool {
    if (expect_item_check.machine == .some) {
        if (real_item_check.machine != expect_item_check.machine.some) {
            log.warn("Machine is not correct", .{});
            return false;
        }
    }
    return true;
}

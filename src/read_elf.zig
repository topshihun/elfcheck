const std = @import("std");
const elf = std.elf;
const fs = std.fs;
const mem = std.mem;
const checked = @import("check.zig");

const RealItemCheck = checked.RealItemCheck;

const EI_NIDENT = 16;

const ReadElfError = error{
    NotElfFile,
    InvalidClass,
};

pub fn readElf(file_path: []const u8) !RealItemCheck {
    var file = fs.cwd().openFile(file_path, .{ .mode = .read_only, .lock = .none }) catch @panic("file open failed");
    defer file.close();

    var buffer: [@sizeOf(elf.Elf64_Ehdr)]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const header = elf.Header.read(&file_reader.interface) catch |e| {
        std.debug.print("error: {any}\n", .{e});
        unreachable;
    };

    var real_item_check: RealItemCheck = undefined;

    // get is_64
    real_item_check.is_64 = header.is_64;

    // get machine
    real_item_check.machine = header.machine;

    return real_item_check;
}

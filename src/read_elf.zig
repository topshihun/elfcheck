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

    // var read_buff: [1024]u8 = undefined;
    // const file_reader = file.reader(&read_buff);
    // var reader = file_reader.interface;
    // _ = elf.Header.read(&reader) catch |e| {
    //     std.debug.print("error: {any}\n", .{e});
    //     unreachable;
    // };

    var e_ident: [EI_NIDENT]u8 = undefined;

    const magic_size = file.readAll(&e_ident) catch @panic("file read failed");

    if (magic_size < EI_NIDENT)
        return error.NotElfFile;
    if (mem.eql(u8, e_ident[0..4], "\x7felf"))
        return error.NotElfFile;

    var real_item_check: RealItemCheck = undefined;

    // get is_64
    const ei_class: u16 = e_ident[4];
    real_item_check.is_64 = switch (ei_class) {
        elf.ELFCLASS32 => false,
        elf.ELFCLASS64 => true,
        else => return error.InvalidClass,
    };

    // get machine

    return real_item_check;
}

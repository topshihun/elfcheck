const std = @import("std");
const process = std.process;
const utils = @import("utils.zig");
const check = @import("check.zig");
const log = @import("log.zig");

const ExpectItems = check.ExpectItems;

const items_fns = check.items_fns;

// test all
test {
    std.testing.refAllDecls(@This());
}

const ArgPair = struct {
    key: []const u8,
    value: []const u8,

    fn split(fmt: []const u8) ?ArgPair {
        // split string with '='
        var eq_index: ?usize = null;
        for (fmt, 0..) |c, index| {
            if (c == '=') eq_index = index;
        }

        if (eq_index) |index| {
            if (index >= fmt.len) return null;
            const key = fmt[0..index];
            const value = fmt[index + 1 .. fmt.len];
            return ArgPair{
                .key = key,
                .value = value,
            };
        } else {
            return null;
        }
    }

    test split {
        const key_value = ArgPair.split("key=value") orelse return error.InvalidArg;
        try std.testing.expectEqualStrings(key_value.key, "key");
        try std.testing.expectEqualStrings(key_value.value, "value");
    }
};

const CommonArg = struct {
    names: []const []const u8,
    describe: []const u8 = "No describe",
    do: *const fn () void,
};

const common_args = [_]CommonArg{
    CommonArg{
        .names = &[_][]const u8{ "-h", "--help" },
        .do = argHelp,
    },
    CommonArg{
        .names = &[_][]const u8{"-v"},
        .do = argVersion,
    },
    CommonArg{
        .names = &[_][]const u8{"-err"},
        .do = argErr,
    },
    CommonArg{
        .names = &[_][]const u8{"-warn"},
        .do = argWarn,
    },
    CommonArg{
        .names = &[_][]const u8{"-info"},
        .do = argInfo,
    },
};

const ParseArgsError = error{
    InvalidArg,
    MultipleFile,
    HaveNotFile,
};

pub fn parseArgs() !struct { ExpectItems, []const u8 } {
    const mem = std.mem;

    var args = process.args();
    _ = args.next();
    var item_check: ExpectItems = undefined;

    // must have one file arg
    var file: ?[]const u8 = null;
    while (args.next()) |arg| {
        if (arg[0] == '-') {
            var invalid_arg = true;
            for (common_args) |common_arg| {
                for (common_arg.names) |name| {
                    if (mem.eql(u8, arg, name)) {
                        common_arg.do();
                        invalid_arg = false;
                    }
                }
            }
            if (invalid_arg) {
                printInvalidArg(arg);
                return error.InvalidArg;
            }
        } else {
            if (ArgPair.split(arg)) |arg_pair| {
                for (items_fns) |item_fns| {
                    if (mem.eql(u8, arg_pair.key, item_fns.name)) {
                        if (!item_fns.change_fn(&item_check, arg_pair.value)) {
                            printInvalidArg(arg);
                            return error.InvalidArg;
                        }
                    }
                }
            } else {
                // maybe file name
                if (file) |_| {
                    // multiple files
                    log.err("mutiple file {s}", .{arg});
                    return error.MultipleFile;
                }
                file = arg;
            }
        }
    }

    if (file) |f| {
        return .{ item_check, f };
    } else {
        log.err("No file", .{});
        return error.HaveNotFile;
    }
}

fn argHelp() void {
    printHelp();
    process.exit(0);
}

fn printHelp() void {
    // TODO: comptime for help information.
    utils.printNoArgs("Usage: elfcheck [commond] [input]\n");
    utils.printNoArgs("\n");
    utils.printNoArgs("[input]\tThe path to the file to be checked.\n");
    utils.printNoArgs("\n");
    utils.printNoArgs("General Options:\n");
    for (common_args) |common_arg| {
        utils.printNoArgs(" ");
        for (common_arg.names, 1..) |name, i| {
            utils.print("{s}", .{name});
            if (common_arg.names.len != i)
                utils.printNoArgs(", ");
        }
        utils.print("\t{s}.\n", .{common_arg.describe});
    }
    utils.printNoArgs("\n");
    utils.printNoArgs("Options:\n");
    for (items_fns) |item| {
        utils.print(" {s}\t{s}\n", .{ item.name, item.describe });
    }
}

fn argVersion() void {
    const version = @import("elfcheck").version;
    utils.print("version: {s}\n", .{version});
    process.exit(0);
}

fn printInvalidArg(arg: []const u8) void {
    log.err("Invalid arg: {s}", .{arg});
}

fn argErr() void {
    log.level = .err;
}

fn argWarn() void {
    log.level = .warn;
}

fn argInfo() void {
    log.level = .info;
}

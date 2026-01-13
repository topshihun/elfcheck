const std = @import("std");

const check_machine = @import("check/machine.zig");
const utils = @import("utils.zig");
const parse_args = @import("parse_args.zig");

test {
    std.testing.refAllDecls(@This());
}

test utils {
    _ = utils;
}

// test parse_args {
//     _ = parse_args;
// }

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const version = "0.0.1";
    const elfcheck_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // add version to elfcheck
    const options = b.addOptions();
    options.addOption([]const u8, "version", version);
    elfcheck_module.addOptions("elfcheck", options);

    const elfcheck = b.addExecutable(.{
        .name = "elfcheck",
        .version = std.SemanticVersion.parse(version) catch @panic("invalid version"),
        .root_module = elfcheck_module,
    });

    b.installArtifact(elfcheck);

    // build run
    const run_exe = b.addRunArtifact(elfcheck);
    run_exe.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_exe.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");

    run_step.dependOn(&run_exe.step);

    // build test
    const test_root_module = b.addModule("zig_unit_tests", .{
        .root_source_file = b.path("src/tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_root_module.addOptions("elfcheck", options);
    const exe_unit_tests = b.addTest(.{ .root_module = test_root_module });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    run_exe_unit_tests.skip_foreign_checks = true;
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}

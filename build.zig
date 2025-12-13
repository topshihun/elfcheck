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

    const run_exe = b.addRunArtifact(elfcheck);
    run_exe.step.dependOn(b.getInstallStep());

    if(b.args) |args| {
        run_exe.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");

    run_step.dependOn(&run_exe.step);
}

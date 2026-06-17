const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const binarystream_dep = b.dependency("BinaryStream", .{
        .target = target,
        .optimize = optimize,
    });
    const nbt_dep = b.dependency("nbt", .{
        .target = target,
        .optimize = optimize,
    });

    const mod = b.addModule("Protocol", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    mod.addImport("BinaryStream", binarystream_dep.module("BinaryStream"));
    mod.addImport("nbt", nbt_dep.module("nbt"));

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}

const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "zimulator",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/cpu.zig"),
            .target = b.graph.host,
        }),
    });

    exe.addIncludePath(b.path("libs/raylib/include/raylib.h"));
    exe.linkSystemLibrary("raylib");

    b.installArtifact(exe);
}

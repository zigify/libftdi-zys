const std = @import("std");

const src = &.{
    "src/ftdi.c",
    "src/ftdi_stream.c",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libusb = b.dependency("libusb", .{
        .target = target,
        .optimize = optimize,
    }).artifact("usb");

    const lib = b.addStaticLibrary(.{
        .name = "ftdi",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    lib.linkLibrary(libusb);

    lib.addCSourceFiles(.{ .files = src });

    lib.addIncludePath(b.path("src"));

    const ftdi_version_i = b.addConfigHeader(.{ .style = .{ .cmake = b.path("src/ftdi_version_i.h.in") } }, .{
        .MAJOR_VERSION = "1",
        .MINOR_VERSION = "5",
        .VERSION_STRING = "1.5",
        .SNAPSHOT_VERSION = "unknown",
    });

    lib.addConfigHeader(ftdi_version_i);

    lib.installHeader(b.path("src/ftdi.h"), "ftdi.h");

    b.installArtifact(lib);
}

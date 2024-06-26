const std = @import("std");
const statically = @import("statically");

const src = &.{
    "src/ftdi.c",
    "src/ftdi_stream.c",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    _ = statically.option(b);
    statically.log("libftdi");

    const libusb = statically.dependency(b, "libusb", target, optimize).artifact("usb");

    const options = .{
        // Needed for proper linking.
        .name = "ftdi1",
        .target = target,
        .optimize = optimize,
    };

    const lib = statically.library(b, options, options);

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

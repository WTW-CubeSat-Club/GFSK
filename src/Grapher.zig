const std = @import("std");
const Image = @import("Image.zig");

const Rect = struct {
    x: f64,
    y: f64,
    width: f64,
    height: f64,
};

image: Image,
viewport: Rect,
fidelity: u64,
allocator: std.mem.Allocator,

pub fn init(width: usize, height: usize, allocator: std.mem.Allocator, viewport: Rect, fidelity: u64) !@This() {
    const image = try Image.init(width, height, allocator);
    image.clear(0x000000);

    return .{
        .image = image,
        .viewport = viewport,
        .fidelity = fidelity,
        .allocator = allocator,
    };
}

pub fn deinit(self: @This()) void {
    self.image.deinit();
}

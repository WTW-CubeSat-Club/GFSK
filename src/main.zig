const std = @import("std");
const Image = @import("Image.zig");

// TODO: inline functions if necessary

// fn plot(, image: Image) !void {

// }

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const image = try Image.init(1280, 720, allocator);
    defer image.deinit();

    image.clear(0x000000);

    const file = try std.fs.cwd().openFile("test.bmp", .{ .mode = .write_only });
    defer file.close();
    var buffered_stream = std.io.bufferedWriter(file.writer());
    const writer = buffered_stream.writer();

    try image.toBMP(writer);

    try buffered_stream.flush();
}

const std = @import("std");

const Pos = struct {
    x: usize,
    y: usize,
};

width: usize,
height: usize,
data: []u32,
allocator: std.mem.Allocator,

pub fn init(width: usize, height: usize, allocator: std.mem.Allocator) error{OutOfMemory}!@This() {
    return .{
        .width = width,
        .height = height,
        .data = try allocator.alloc(u32, width * height),
        .allocator = allocator,
    };
}

pub fn deinit(self: @This()) void {
    self.allocator.free(self.data);
}

pub fn point(self: @This(), comptime issafe: bool, p: Pos, color: u32) if (issafe) error{OutOfBounds}!void else void {
    if (issafe and !(p.x < self.width and p.y < self.height)) {
        return error.OutOfBounds;
    }

    self.data[(p.y * self.width + p.x)] = color;
}

pub fn clear(self: @This(), color: u32) void {
    @memset(self.data, color);
}

pub fn toBMP(self: @This(), output: anytype) !void {
    const paddingamount = (4 - self.width * 3 % 4) % 4;
    const headersize = 14;
    const infoheadersize = 40;
    const pixelarraysize = self.height * (self.width * 3 + paddingamount);
    const filesize = headersize + infoheadersize + pixelarraysize;

    const header = [14]u8{
        'B',                                            'M',
        @as(u8, @intCast((filesize >> 8 * 0) & 0xff)),  @as(u8, @intCast((filesize >> 8 * 1) & 0xff)),
        @as(u8, @intCast((filesize >> 8 * 2) & 0xff)),  @as(u8, @intCast((filesize >> 8 * 3) & 0xff)),
        0,                                              0,
        0,                                              0,
        @as(u8, @intCast(headersize + infoheadersize)), 0,
        0,                                              0,
    };

    const infoheader = [40]u8{
        @as(u8, @intCast(infoheadersize)),                0,                                                0,                                                0,
        @as(u8, @intCast((self.width >> 8 * 0) & 0xff)),  @as(u8, @intCast((self.width >> 8 * 1) & 0xff)),  @as(u8, @intCast((self.width >> 8 * 2) & 0xff)),  @as(u8, @intCast((self.width >> 8 * 3) & 0xff)),
        @as(u8, @intCast((self.height >> 8 * 0) & 0xff)), @as(u8, @intCast((self.height >> 8 * 1) & 0xff)), @as(u8, @intCast((self.height >> 8 * 2) & 0xff)), @as(u8, @intCast((self.height >> 8 * 3) & 0xff)),
        1,                                                0,                                                24,                                               0,
        0,                                                0,                                                0,                                                0,
        0,                                                0,                                                0,                                                0,
        0,                                                0,                                                0,                                                0,
        0,                                                0,                                                0,                                                0,
        0,                                                0,                                                0,                                                0,
        0,                                                0,                                                0,                                                0,
    };

    _ = try output.write(&header); // TODO: Maybe I shouldn't just throw out the size information
    _ = try output.write(&infoheader);

    const zeros = ([4]u8{ 0, 0, 0, 0 })[0..paddingamount];

    for (0..self.height) |y| {
        for (0..self.width) |x| {
            _ = try output.write(@as([*]u8, @ptrCast(&self.data[(self.height - 1 - y) * self.width + x]))[0..3]); // TODO: Make this endian-independent
            _ = try output.write(zeros);
        }
    }
}

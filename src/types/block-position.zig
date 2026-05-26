const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Vector3f = @import("vector3f.zig").Vector3f;

pub const Face = enum(u8) {
    North,
    South,
    East,
    West,
    Up,
    Down,

    pub fn getOffset(self: Face) BlockPosition {
        return switch (self) {
            .North => .{ .x = 0, .y = 0, .z = -1 },
            .South => .{ .x = 0, .y = 0, .z = 1 },
            .East => .{ .x = 1, .y = 0, .z = 0 },
            .West => .{ .x = -1, .y = 0, .z = 0 },
            .Up => .{ .x = 0, .y = 1, .z = 0 },
            .Down => .{ .x = 0, .y = -1, .z = 0 },
        };
    }

    pub fn oposite(self: Face) Face {
        return switch (self) {
            .North => .South,
            .South => .North,
            .East => .West,
            .West => .East,
            .Up => .Down,
            .Down => .Up,
        };
    }

    pub const horizontal = [_]Face{ .North, .South, .East, .West };
};

pub const BlockPosition = struct {
    x: i32,
    y: i32,
    z: i32,

    pub fn init(x: i32, y: i32, z: i32) BlockPosition {
        return BlockPosition{ .x = x, .y = y, .z = z };
    }

    pub fn toVector3f(self: BlockPosition) Vector3f {
        return .{
            .x = @floatFromInt(self.x),
            .y = @floatFromInt(self.y),
            .z = @floatFromInt(self.z),
        };
    }

    pub fn fromVector3f(vec: Vector3f) BlockPosition {
        return .{
            .x = @intFromFloat(@floor(vec.x)),
            .y = @intFromFloat(@floor(vec.y)),
            .z = @intFromFloat(@floor(vec.z)),
        };
    }

    pub fn add(self: BlockPosition, other: BlockPosition) BlockPosition {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn relative(self: BlockPosition, face: Face) BlockPosition {
        return self.add(face.getOffset());
    }

    pub fn horizontalNeighbors(self: BlockPosition) [4]BlockPosition {
        var neighbors: [4]BlockPosition = undefined;
        inline for (Face.horizontal, 0..) |face, i| {
            neighbors[i] = self.relative(face);
        }
        return neighbors;
    }

    pub fn eql(self: BlockPosition, pos: BlockPosition) bool {
        return std.meta.eql(self, pos);
    }

    pub fn read(stream: *BinaryStream) !BlockPosition {
        const x = try stream.readZigZag();
        const y = try stream.readZigZag();
        const z = try stream.readZigZag();

        return BlockPosition{ .x = x, .y = y, .z = z };
    }

    pub fn write(stream: *BinaryStream, value: BlockPosition) !void {
        try stream.writeZigZag(value.x);
        try stream.writeZigZag(value.y);
        try stream.writeZigZag(value.z);
    }
};

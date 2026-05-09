const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Vector3f = @import("vector3f.zig").Vector3f;

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

const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const SerializableVoxelShape = @import("../types/serializable-voxel-shape.zig").SerializableVoxelShape;

pub const VoxelShapesPacket = struct {
    shapes: []SerializableVoxelShape,
    hash_string: []const u8,
    registry_handle: u16,

    pub fn serialize(self: *VoxelShapesPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.VoxelShapes);

        try stream.writeVarInt(@intCast(self.shapes.len));
        for (self.shapes) |shape| {
            try SerializableVoxelShape.write(stream, shape);
        }

        try stream.writeVarString(self.hash_string);
        try stream.writeInt16(@bitCast(self.registry_handle), .Little);

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !VoxelShapesPacket {
        _ = try stream.readVarInt();

        const shapesLen = try stream.readVarInt();
        const shapes = try stream.allocator.alloc(SerializableVoxelShape, @intCast(shapesLen));

        for (0..@intCast(shapesLen)) |i| {
            shapes[i] = try SerializableVoxelShape.read(stream);
        }

        const hash_string = try stream.readVarString();
        const registry_handle: u16 = @bitCast(try stream.readInt16(.Little));

        return VoxelShapesPacket{
            .shapes = shapes,
            .hash_string = hash_string,
            .registry_handle = registry_handle,
        };
    }

    pub fn deinit(self: *VoxelShapesPacket, allocator: std.mem.Allocator) void {
        for (self.shapes) |*shape| {
            shape.deinit(allocator);
        }
        allocator.free(self.shapes);
    }
};

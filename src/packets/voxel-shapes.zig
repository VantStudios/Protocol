const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const SerializableVoxelShape = @import("../types/serializable-voxel-shape.zig").SerializableVoxelShape;

pub const VoxelShapeNameEntry = struct {
    name: []const u8,
    handle: i16,
};

pub const VoxelShapesPacket = struct {
    shapes: []SerializableVoxelShape,
    name_map: []const VoxelShapeNameEntry = &.{},
    custom_shape_count: u16 = 0,

    pub fn serialize(self: *VoxelShapesPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.VoxelShapes);

        try stream.writeVarInt(@intCast(self.shapes.len));
        for (self.shapes) |shape| {
            try SerializableVoxelShape.write(stream, shape);
        }

        try stream.writeVarInt(@intCast(self.name_map.len));
        for (self.name_map) |entry| {
            try stream.writeVarString(entry.name);
            try stream.writeInt16(entry.handle, .Little);
        }

        try stream.writeInt16(@intCast(self.custom_shape_count), .Little);

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !VoxelShapesPacket {
        _ = try stream.readVarInt();

        const shapes_len = try stream.readVarInt();
        const shapes = try allocator.alloc(SerializableVoxelShape, @intCast(shapes_len));
        for (0..@intCast(shapes_len)) |i| {
            shapes[i] = try SerializableVoxelShape.read(stream);
        }

        const map_len = try stream.readVarInt();
        const name_map = try allocator.alloc(VoxelShapeNameEntry, @intCast(map_len));
        for (0..@intCast(map_len)) |i| {
            name_map[i] = .{
                .name = try stream.readVarString(),
                .handle = @bitCast(try stream.readInt16(.Little)),
            };
        }

        return VoxelShapesPacket{
            .shapes = shapes,
            .name_map = name_map,
            .custom_shape_count = @bitCast(try stream.readInt16(.Little)),
        };
    }

    pub fn deinit(self: *VoxelShapesPacket, allocator: std.mem.Allocator) void {
        for (self.shapes) |*shape| {
            shape.deinit(allocator);
        }
        allocator.free(self.shapes);
        allocator.free(self.name_map);
    }
};

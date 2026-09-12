const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../enums/packet.zig").Packet;
const Vector3i = @import("../types/block-position.zig").BlockPosition;
const Uuid = @import("../types/uuid.zig").Uuid;

pub const DimensionDefinition = struct {
    id: []const u8,
    max_height: i32,
    min_height: i32,
    generator_type: i32,
    dimension_type: i32,
    pack_id: []const u8,
};

pub const DimensionDataPacket = struct {
    definitions: []const DimensionDefinition = &.{},

    pub fn serialize(self: *const DimensionDataPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.DimensionData);
        try stream.writeVarInt(@intCast(self.definitions.len));
        for (self.definitions) |def| {
            try stream.writeVarString(def.id);
            try stream.writeZigZag(def.max_height);
            try stream.writeZigZag(def.min_height);
            try stream.writeZigZag(def.generator_type);
            try stream.writeZigZag(def.dimension_type);
            try Uuid.write(stream, def.pack_id);
        }
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !DimensionDataPacket {
        _ = try stream.readVarInt();
        const count = try stream.readVarInt();
        const definitions = try allocator.alloc(DimensionDefinition, @intCast(count));
        for (0..@intCast(count)) |i| {
            const id = try stream.readVarString();
            const max_height = try stream.readZigZag();
            const min_height = try stream.readZigZag();
            const generator_type = try stream.readZigZag();
            const dimension_type = try stream.readZigZag();
            const pack_id = Uuid.read(stream);
            definitions[i] = .{
                .id = id,
                .max_height = max_height,
                .min_height = min_height,
                .generator_type = generator_type,
                .dimension_type = dimension_type,
                .pack_id = pack_id,
            };
        }
        return .{ .definitions = definitions };
    }

    pub fn deinit(self: *const DimensionDataPacket, allocator: std.mem.Allocator) void {
        for (self.definitions) |*def| {
            allocator.free(@constCast(def.id));
        }
        allocator.free(@constCast(self.definitions));
    }
};

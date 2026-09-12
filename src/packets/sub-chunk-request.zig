const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;

pub const SubChunkOffset = struct {
    x: i8 = 0,
    y: i8 = 0,
    z: i8 = 0,
};

pub const SubChunkRequestPacket = struct {
    dimension: i32 = 0,
    /// Offsets relative to `base_position`; the client requests up to 128 of
    /// them per packet.
    offsets: []SubChunkOffset = &.{},
    /// The wire carries the base position AFTER the offset list.
    base_x: i32 = 0,
    base_y: i32 = 0,
    base_z: i32 = 0,

    pub fn serialize(self: *const SubChunkRequestPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.SubChunkRequest);
        try stream.writeZigZag(self.dimension);

        try stream.writeVarInt(@intCast(self.offsets.len));
        for (self.offsets) |offset| {
            try stream.writeByte(@bitCast(offset.x));
            try stream.writeByte(@bitCast(offset.y));
            try stream.writeByte(@bitCast(offset.z));
        }

        try stream.writeInt32(self.base_x, .Little);
        try stream.writeInt32(self.base_y, .Little);
        try stream.writeInt32(self.base_z, .Little);
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !SubChunkRequestPacket {
        _ = try stream.readVarInt();

        const dimension = try stream.readZigZag();

        const offset_count: u32 = @intCast(try stream.readVarInt());
        const offsets = try allocator.alloc(SubChunkOffset, offset_count);
        errdefer allocator.free(offsets);
        for (0..offset_count) |i| {
            offsets[i] = .{
                .x = @bitCast(try stream.readUint8()),
                .y = @bitCast(try stream.readUint8()),
                .z = @bitCast(try stream.readUint8()),
            };
        }

        const base_x = try stream.readInt32(.Little);
        const base_y = try stream.readInt32(.Little);
        const base_z = try stream.readInt32(.Little);

        return .{
            .dimension = dimension,
            .offsets = offsets,
            .base_x = base_x,
            .base_y = base_y,
            .base_z = base_z,
        };
    }

    pub fn deinit(self: *SubChunkRequestPacket, allocator: std.mem.Allocator) void {
        allocator.free(self.offsets);
    }
};

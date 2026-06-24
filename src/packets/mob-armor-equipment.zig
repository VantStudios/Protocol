const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../root.zig").Packet;
const NetworkItemStackDescriptor = @import("../root.zig").NetworkItemStackDescriptor;

pub const MobArmorEquipmentPacket = struct {
    runtime_entity_id: u64,
    helmet: NetworkItemStackDescriptor,
    chestplate: NetworkItemStackDescriptor,
    leggings: NetworkItemStackDescriptor,
    boots: NetworkItemStackDescriptor,
    body: NetworkItemStackDescriptor,

    pub fn serialize(self: *const MobArmorEquipmentPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.MobArmorEquipment);

        try stream.writeVarLong(self.runtime_entity_id);
        try NetworkItemStackDescriptor.writeShort(stream, self.helmet, stream.allocator);
        try NetworkItemStackDescriptor.writeShort(stream, self.chestplate, stream.allocator);
        try NetworkItemStackDescriptor.writeShort(stream, self.leggings, stream.allocator);
        try NetworkItemStackDescriptor.writeShort(stream, self.boots, stream.allocator);
        try NetworkItemStackDescriptor.writeShort(stream, self.body, stream.allocator);

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !MobArmorEquipmentPacket {
        _ = try stream.readVarInt();

        const runtime_entity_id = try stream.readVarLong();
        const helmet = try NetworkItemStackDescriptor.readShort(stream, allocator);
        errdefer helmet.deinit(allocator);

        const chestplate = try NetworkItemStackDescriptor.readShort(stream, allocator);
        errdefer chestplate.deinit(allocator);

        const leggings = try NetworkItemStackDescriptor.readShort(stream, allocator);
        errdefer leggings.deinit(allocator);

        const boots = try NetworkItemStackDescriptor.readShort(stream, allocator);
        errdefer boots.deinit(allocator);

        const body = try NetworkItemStackDescriptor.readShort(stream, allocator);

        return .{
            .runtime_entity_id = runtime_entity_id,
            .helmet = helmet,
            .chestplate = chestplate,
            .leggings = leggings,
            .boots = boots,
            .body = body,
        };
    }

    pub fn deinit(self: *MobArmorEquipmentPacket, allocator: std.mem.Allocator) void {
        self.helmet.deinit(allocator);
        self.chestplate.deinit(allocator);
        self.leggings.deinit(allocator);
        self.boots.deinit(allocator);
        self.body.deinit(allocator);
    }
};

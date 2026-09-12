const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../root.zig").Packet;
const ContainerId = @import("../root.zig").ContainerId;
const FullContainerName = @import("../root.zig").FullContainerName;
const NetworkItemStackDescriptor = @import("../root.zig").NetworkItemStackDescriptor;

pub const InventorySlotPacket = struct {
    container_id: ContainerId,
    slot: u32,
    full_container_name: ?FullContainerName = null,
    storage_item: NetworkItemStackDescriptor,
    item: NetworkItemStackDescriptor,

    pub fn serialize(self: *const InventorySlotPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.InventorySlot);
        try stream.writeVarInt(@as(u32, @bitCast(@as(i32, @intFromEnum(self.container_id)))));
        try stream.writeVarInt(self.slot);

        if (self.full_container_name) |name| {
            try stream.writeBool(true);
            try FullContainerName.write(stream, name);
        } else {
            try stream.writeBool(false);
        }

        if (self.storage_item.network != 0) {
            try stream.writeBool(true);
            try NetworkItemStackDescriptor.writeShort(stream, self.storage_item, stream.allocator);
        } else {
            try stream.writeBool(false);
        }

        try NetworkItemStackDescriptor.writeShort(stream, self.item, stream.allocator);
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !InventorySlotPacket {
        _ = try stream.readVarInt();
        const container_id: ContainerId = @enumFromInt(@as(i8, @truncate(@as(i32, @bitCast(try stream.readVarInt())))));
        const slot = try stream.readVarInt();

        const full_container_name: ?FullContainerName = if (try stream.readBool())
            try FullContainerName.read(stream)
        else
            null;

        const storage_item = if (try stream.readBool())
            try NetworkItemStackDescriptor.readShort(stream, stream.allocator)
        else
            NetworkItemStackDescriptor{ .network = 0 };

        const item = try NetworkItemStackDescriptor.readShort(stream, stream.allocator);
        return .{
            .container_id = container_id,
            .slot = slot,
            .full_container_name = full_container_name,
            .storage_item = storage_item,
            .item = item,
        };
    }
};

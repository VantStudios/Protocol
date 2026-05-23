const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const ContainerId = @import("../root.zig").ContainerId;
const FullContainerName = @import("../root.zig").FullContainerName;
const NetworkItemStackDescriptor = @import("../root.zig").NetworkItemStackDescriptor;

pub const InventorySlotPacket = struct {
    containerId: ContainerId,
    slot: u32,
    fullContainerName: FullContainerName,
    storageItem: NetworkItemStackDescriptor,
    item: NetworkItemStackDescriptor,

    pub fn serialize(self: *const InventorySlotPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.InventorySlot);
        try stream.writeVarInt(@as(u32, @bitCast(@as(i32, @intFromEnum(self.containerId)))));
        try stream.writeVarInt(self.slot);

        if (!self.fullContainerName.isLegacy()) {
            try stream.writeBool(true);
            try FullContainerName.write(stream, self.fullContainerName);
        } else {
            try stream.writeBool(false);
        }

        if (self.storageItem.network != 0) {
            try stream.writeBool(true);
            try NetworkItemStackDescriptor.writeShort(stream, self.storageItem, stream.allocator);
        } else {
            try stream.writeBool(false);
        }

        try NetworkItemStackDescriptor.writeShort(stream, self.item, stream.allocator);
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !InventorySlotPacket {
        _ = try stream.readVarInt();
        const containerId: ContainerId = @enumFromInt(@as(i8, @truncate(@as(i32, @bitCast(try stream.readVarInt())))));
        const slot = try stream.readVarInt();

        const fullContainerName = if (try stream.readBool())
            try FullContainerName.read(stream)
        else
            FullContainerName.legacy();

        const storageItem = if (try stream.readBool())
            try NetworkItemStackDescriptor.readShort(stream, stream.allocator)
        else
            NetworkItemStackDescriptor{ .network = 0 };

        const item = try NetworkItemStackDescriptor.readShort(stream, stream.allocator);
        return .{
            .containerId = containerId,
            .slot = slot,
            .fullContainerName = fullContainerName,
            .storageItem = storageItem,
            .item = item,
        };
    }
};

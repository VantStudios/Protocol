const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const ContainerId = @import("../enums/container-id.zig").ContainerId;
const Packet = @import("../root.zig").Packet;
const FullContainerName = @import("../root.zig").FullContainerName;
const NetworkItemStackDescriptor = @import("../root.zig").NetworkItemStackDescriptor;

pub const InventoryContentPacket = struct {
    containerId: ContainerId,
    items: []const NetworkItemStackDescriptor,
    fullContainerName: FullContainerName,
    storageItem: NetworkItemStackDescriptor,

    pub fn serialize(self: *const InventoryContentPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.InventoryContent);

        try stream.writeVarInt(@as(u32, @bitCast(@as(i32, @intFromEnum(self.containerId)))));
        try stream.writeVarInt(@intCast(self.items.len));
        for (self.items) |item| {
            try NetworkItemStackDescriptor.writeShort(stream, item, stream.allocator);
        }
        try FullContainerName.write(stream, self.fullContainerName);
        try NetworkItemStackDescriptor.writeShort(stream, self.storageItem, stream.allocator);
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !InventoryContentPacket {
        _ = try stream.readVarInt();

        const identifier_raw = try stream.readVarInt();
        const length = try stream.readVarInt();
        const items = try allocator.alloc(NetworkItemStackDescriptor, length);
        for (0..length) |i| {
            items[i] = try NetworkItemStackDescriptor.read(stream, allocator);
        }
        const fullContainerName = try FullContainerName.read(stream);
        const storageItem = try NetworkItemStackDescriptor.read(stream, allocator);

        return .{
            .containerId = std.enums.fromInt(ContainerId, @intCast(@as(i32, @bitCast(identifier_raw)))) catch return error.UnknownContainerId,
            .items = items,
            .fullContainerName = fullContainerName,
            .storageItem = storageItem,
        };
    }

    pub fn deinit(self: *InventoryContentPacket, allocator: std.mem.Allocator) void {
        for (self.items) |item| {
            item.deinit(allocator);
        }
        allocator.free(self.items);
    }
};

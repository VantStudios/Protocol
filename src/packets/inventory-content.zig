const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const ContainerId = @import("../enums/container-id.zig").ContainerId;
const Packet = @import("../root.zig").Packet;
const FullContainerName = @import("../root.zig").FullContainerName;
const NetworkItemStackDescriptor = @import("../root.zig").NetworkItemStackDescriptor;

pub const InventoryContentPacket = struct {
    container_id: ContainerId,
    items: []const NetworkItemStackDescriptor,
    full_container_name: FullContainerName,
    storage_item: NetworkItemStackDescriptor,

    pub fn serialize(self: *const InventoryContentPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.InventoryContent);

        try stream.writeVarInt(@as(u32, @bitCast(@as(i32, @intFromEnum(self.container_id)))));
        try stream.writeVarInt(@intCast(self.items.len));
        for (self.items) |item| {
            try NetworkItemStackDescriptor.writeShort(stream, item, stream.allocator);
        }
        try FullContainerName.write(stream, self.full_container_name);
        try NetworkItemStackDescriptor.writeShort(stream, self.storage_item, stream.allocator);
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
        const full_container_name = try FullContainerName.read(stream);
        const storage_item = try NetworkItemStackDescriptor.read(stream, allocator);

        return .{
            .container_id = std.enums.fromInt(ContainerId, @intCast(@as(i32, @bitCast(identifier_raw)))) catch return error.UnknownContainerId,
            .items = items,
            .full_container_name = full_container_name,
            .storage_item = storage_item,
        };
    }

    pub fn deinit(self: *InventoryContentPacket, allocator: std.mem.Allocator) void {
        for (self.items) |item| {
            item.deinit(allocator);
        }
        allocator.free(self.items);
    }
};

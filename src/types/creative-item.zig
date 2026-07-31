const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const NetworkItemInstanceDescriptor = @import("network-item-instance-descriptor.zig").NetworkItemInstanceDescriptor;

pub const CreativeItem = struct {
    item_index: u32,
    item_instance: NetworkItemInstanceDescriptor,
    group_index: u32,

    pub fn read(stream: *BinaryStream, allocator: std.mem.Allocator) ![]CreativeItem {
        const amount = try stream.readVarInt();
        const items = try allocator.alloc(CreativeItem, amount);
        for (0..amount) |i| {
            const item_index = try stream.readVarInt();
            const item_instance = try NetworkItemInstanceDescriptor.read(stream, allocator);
            const group_index = try stream.readVarInt();
            items[i] = .{ .item_index = item_index, .item_instance = item_instance, .group_index = group_index };
        }
        return items;
    }

    pub fn write(stream: *BinaryStream, values: []const CreativeItem, allocator: std.mem.Allocator) !void {
        try stream.writeVarInt(@intCast(values.len));
        for (values) |item| {
            try stream.writeVarInt(item.item_index);
            try NetworkItemInstanceDescriptor.write(stream, item.item_instance, allocator);
            try stream.writeVarInt(item.group_index);
        }
    }
};

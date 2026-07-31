const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;
const Vector3f = @import("../types/vector3f.zig").Vector3f;
const DataItem = @import("../types/data-item.zig").DataItem;
const NetworkItemStackDescriptor = @import("../types/network-item-stack-descriptor.zig").NetworkItemStackDescriptor;
const std = @import("std");

pub const AddItemActorPacket = struct {
    unique_entity_id: i64,
    runtime_entity_id: u64,
    item: NetworkItemStackDescriptor,
    position: Vector3f,
    velocity: Vector3f = Vector3f.init(0, 0, 0),
    entity_metadata: []const DataItem = &[_]DataItem{},
    from_fishing: bool = false,

    pub fn serialize(self: *const AddItemActorPacket, stream: *BinaryStream, allocator: std.mem.Allocator) ![]const u8 {
        try stream.writeVarInt(Packet.AddItemActor);
        try stream.writeZigZong(self.unique_entity_id);
        try stream.writeVarLong(self.runtime_entity_id);
        try NetworkItemStackDescriptor.write(stream, self.item, allocator);
        try Vector3f.write(stream, self.position);
        try Vector3f.write(stream, self.velocity);
        try stream.writeVarInt(@intCast(self.entity_metadata.len));
        for (self.entity_metadata) |item| {
            try item.write(stream);
        }
        try stream.writeUint8(if (self.from_fishing) 1 else 0);
        return stream.getBuffer();
    }
};

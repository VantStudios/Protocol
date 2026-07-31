const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;

pub const TakeItemActorPacket = struct {
    item_entity_runtime_id: u64,
    taker_entity_runtime_id: u64,

    pub fn serialize(self: *const TakeItemActorPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.TakeItemActor);
        try stream.writeVarLong(self.item_entity_runtime_id);
        try stream.writeVarLong(self.taker_entity_runtime_id);
        return stream.getBuffer();
    }
};

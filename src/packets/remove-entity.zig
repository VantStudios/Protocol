const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;

pub const RemoveEntityPacket = struct {
    unique_entity_id: i64,

    pub fn serialize(self: *const RemoveEntityPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.RemoveActor);
        try stream.writeZigZong(self.unique_entity_id);
        return stream.getBuffer();
    }
};

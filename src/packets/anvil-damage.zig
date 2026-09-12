const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../enums/packet.zig").Packet;
const BlockPosition = @import("../types/block-position.zig").BlockPosition;

pub const AnvilDamagePacket = struct {
    position: BlockPosition,

    pub fn serialize(self: *const AnvilDamagePacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.AnvilDamage);
        try BlockPosition.write(stream, self.position);
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !AnvilDamagePacket {
        _ = try stream.readVarInt();
        const position = try BlockPosition.read(stream);
        return .{ .position = position };
    }
};

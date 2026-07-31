const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;

pub const RequestChunkRadius = struct {
    radius: i32,
    max_radius: u8,

    pub fn serialize(self: *RequestChunkRadius, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.RequestChunkRadius);
        try stream.writeZigZag(self.radius);
        try stream.writeUint8(self.max_radius);
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !RequestChunkRadius {
        _ = try stream.readVarInt();
        const radius = try stream.readZigZag();
        const max_radius = try stream.readUint8();

        return RequestChunkRadius{
            .radius = radius,
            .max_radius = max_radius,
        };
    }
};

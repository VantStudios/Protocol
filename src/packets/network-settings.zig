const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const CompressionMethod = @import("../root.zig").CompressionMethod;

pub const NetworkSettings = struct {
    compression_threshold: u16,
    compression_method: CompressionMethod,
    client_throttle: bool,
    client_threshold: u8,
    client_scalar: f32,

    pub fn serialize(self: *NetworkSettings, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.NetworkSettings);
        try stream.writeUint16(self.compression_threshold, .Little);
        try stream.writeUint16(@intFromEnum(self.compression_method), .Little);
        try stream.writeBool(self.client_throttle);
        try stream.writeUint8(self.client_threshold);
        try stream.writeFloat32(self.client_scalar, .Little);
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !NetworkSettings {
        _ = try stream.readVarInt();
        const compression_threshold = try stream.readUint16(.Little);
        const compression_method = try stream.readUint16(.Little);
        const client_throttle = try stream.readBool();
        const client_threshold = try stream.readUint8();
        const client_scalar = try stream.readFloat32(.Little);

        return NetworkSettings{
            .compression_threshold = compression_threshold,
            .compression_method = @enumFromInt(compression_method),
            .client_throttle = client_throttle,
            .client_threshold = client_threshold,
            .client_scalar = client_scalar,
        };
    }
};

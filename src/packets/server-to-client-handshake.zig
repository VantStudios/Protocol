const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;

pub const ServerToClientHandshake = struct {
    jwt_data: []const u8,

    pub fn serialize(self: *ServerToClientHandshake, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.ServerToClientHandshake);
        try stream.writeVarString(self.jwt_data);

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !ServerToClientHandshake {
        _ = try stream.readVarInt();
        const jwt_data = stream.readVarString();

        return .{
            .jwt_data = jwt_data,
        };
    }
};

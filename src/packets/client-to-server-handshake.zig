const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;

pub const ClientToServerHandshake = struct {
    jwt_data: []const u8,

    pub fn serialize(_: *ClientToServerHandshake, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.ClientToServerHandshake);

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !ClientToServerHandshake {
        _ = try stream.readVarInt();
        return .{};
    }
};

const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const DisconnectReason = @import("../root.zig").DisconnectReason;

pub const Disconnect = struct {
    reason: DisconnectReason,
    hideScreen: bool,
    message: ?[]const u8 = null,
    filtered: ?[]const u8 = null,

    pub fn serialize(self: *Disconnect, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.Disconnect);
        try stream.writeZigZag(@intFromEnum(self.reason));
        try stream.writeZigZag(if (self.hideScreen) 1 else 0);

        if (!self.hideScreen) {
            try stream.writeVarString(self.message orelse "Disconnected from server.");
            try stream.writeVarString(self.filtered orelse "Disconnected from server.");
        }

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !Disconnect {
        _ = try stream.readVarInt();
        const reason: DisconnectReason = @enumFromInt(try stream.readZigZag());
        const hideScreen = try stream.readZigZag();

        if (!hideScreen) {
            return Disconnect{
                .reason = reason,
                .hideScreen = hideScreen == 0,
                .message = try stream.readVarString(),
                .filtered = try stream.readVarString(),
            };
        }
        return Disconnect{
            .reason = reason,
            .hideScreen = hideScreen,
        };
    }
};

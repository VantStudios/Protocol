const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const DisconnectReason = @import("../root.zig").DisconnectReason;

pub const DisconnectMessages = struct {
    message: []const u8,
    filtered_message: []const u8,
};

pub const Disconnect = struct {
    reason: DisconnectReason,
    messages: ?DisconnectMessages = null,

    pub fn serialize(self: *Disconnect, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.Disconnect);
        try stream.writeZigZag(@intFromEnum(self.reason));

        if (self.messages) |msgs| {
            try stream.writeVarInt(1);
            try stream.writeVarString(msgs.message);
            try stream.writeVarString(msgs.filtered_message);
        } else {
            try stream.writeVarInt(0);
        }

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !Disconnect {
        _ = try stream.readVarInt();
        const reason: DisconnectReason = std.enums.fromInt(DisconnectReason, try stream.readZigZag()) orelse return error.UnknownDisconnectReason;

        const has_messages = try stream.readVarInt();
        var messages: ?DisconnectMessages = null;
        if (has_messages != 0) {
            const msg = try stream.readVarString();
            const filtered = try stream.readVarString();
            messages = .{
                .message = msg,
                .filtered_message = filtered,
            };
        }

        return Disconnect{
            .reason = reason,
            .messages = messages,
        };
    }
};

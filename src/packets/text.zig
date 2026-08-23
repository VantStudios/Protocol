const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const TextType = @import("../root.zig").TextType;

pub const TextPacket = struct {
    text_type: TextType,
    needs_translation: bool = false,
    source_name: []const u8 = "",
    message: []const u8,
    parameters: []const []const u8 = &[_][]const u8{},
    xuid: []const u8 = "",
    platform_chat_id: []const u8 = "",
    filtered_message: ?[]const u8 = null,

    pub fn serialize(self: *TextPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.Text);
        try stream.writeBool(self.needs_translation);

        try stream.writeVarInt(@intFromEnum(self.text_type));

        switch (self.text_type) {
            .Chat, .Whisper, .Announcement => {
                try stream.writeVarString(self.source_name);
                try stream.writeVarString(self.message);
            },
            .Raw, .Tip, .System, .Object, .ObjectWhisper, .ObjectAnnouncement => {
                try stream.writeVarString(self.message);
            },
            .Translation, .Popup, .JukeboxPopup => {
                try stream.writeVarString(self.message);
                try stream.writeVarInt(@intCast(self.parameters.len));
                for (self.parameters) |param| {
                    try stream.writeVarString(param);
                }
            },
        }

        try stream.writeVarString(self.xuid);
        try stream.writeVarString(self.platform_chat_id);

        if (self.filtered_message) |filtered| {
            try stream.writeBool(true);
            try stream.writeVarString(filtered);
        } else {
            try stream.writeBool(false);
        }

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !TextPacket {
        _ = try stream.readVarInt();
        const needs_translation = try stream.readBool();
        const text_type: TextType = std.enums.fromInt(TextType, try stream.readVarInt()) orelse return error.UnknownTextType;

        var source_name: []const u8 = "";
        var message: []const u8 = "";
        var parameters: []const []const u8 = &[_][]const u8{};

        switch (text_type) {
            .Chat, .Whisper, .Announcement => {
                source_name = try stream.readVarString();
                message = try stream.readVarString();
            },
            .Raw, .Tip, .System, .Object, .ObjectWhisper, .ObjectAnnouncement => {
                message = try stream.readVarString();
            },
            .Translation, .Popup, .JukeboxPopup => {
                message = try stream.readVarString();
                const count = try stream.readVarInt();
                if (count > 0 and count < 128) {
                    var params: [128][]const u8 = undefined;
                    for (0..count) |i| {
                        params[i] = try stream.readVarString();
                    }
                    parameters = params[0..count];
                }
            },
        }

        const xuid = try stream.readVarString();
        const platform_chat_id = try stream.readVarString();

        var filtered_message: ?[]const u8 = null;
        const hasFiltered = try stream.readBool();
        if (hasFiltered) {
            filtered_message = try stream.readVarString();
        }

        return TextPacket{
            .text_type = text_type,
            .needs_translation = needs_translation,
            .source_name = source_name,
            .message = message,
            .parameters = parameters,
            .xuid = xuid,
            .platform_chat_id = platform_chat_id,
            .filtered_message = filtered_message,
        };
    }
};

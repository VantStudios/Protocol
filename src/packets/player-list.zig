const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const PlayerListAction = @import("../enums/player-list-action.zig").PlayerListAction;
const PlayerListEntry = @import("../types/player-list-entry.zig").PlayerListEntry;

pub const PlayerListPacket = struct {
    entries: []const PlayerListEntry,

    pub fn serialize(self: *PlayerListPacket, stream: *BinaryStream, allocator: std.mem.Allocator) ![]const u8 {
        try stream.writeVarInt(Packet.PlayerList);
        try stream.writeVarInt(@intCast(self.entries.len));

        for (self.entries) |entry| {
            try PlayerListEntry.write(stream, entry, allocator);
        }

        return stream.getBuffer();
    }
};

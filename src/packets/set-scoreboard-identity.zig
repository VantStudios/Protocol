const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../enums/packet.zig").Packet;

pub const SetScoreboardAction = enum(u8) {
    Add = 0,
    Remove = 1,
};

pub const Entry = struct {
    scoreboard_id: i64,
    player_id: ?i64 = null,
};

pub const SetScoreboardIdentityPacket = struct {
    action: SetScoreboardAction,
    entries: []const Entry = &.{},

    pub fn serialize(self: *const SetScoreboardIdentityPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.SetScoreboardIdentity);
        try stream.writeUint8(@intFromEnum(self.action));
        try stream.writeVarInt(@intCast(self.entries.len));
        for (self.entries) |entry| {
            try stream.writeZigZong(entry.scoreboard_id);
            if (entry.player_id) |pid| {
                try stream.writeBool(true);
                try stream.writeZigZong(pid);
            } else {
                try stream.writeBool(false);
            }
        }
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !SetScoreboardIdentityPacket {
        _ = try stream.readVarInt();
        const action: SetScoreboardAction = @enumFromInt(try stream.readUint8());
        const count = try stream.readVarInt();
        const entries = try allocator.alloc(Entry, @intCast(count));
        for (0..@intCast(count)) |i| {
            const scoreboard_id = try stream.readZigZong();
            var player_id: ?i64 = null;
            if (try stream.readBool()) {
                player_id = try stream.readZigZong();
            }
            entries[i] = .{ .scoreboard_id = scoreboard_id, .player_id = player_id };
        }
        return .{ .action = action, .entries = entries };
    }

    pub fn deinit(self: *const SetScoreboardIdentityPacket, allocator: std.mem.Allocator) void {
        allocator.free(@constCast(self.entries));
    }
};

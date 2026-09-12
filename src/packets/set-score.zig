const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../enums/packet.zig").Packet;

pub const ScorerType = enum(u8) {
    Invalid = 0,
    Player = 1,
    Entity = 2,
    FakePlayer = 3,
};

pub const ScoreInfo = struct {
    scorer_type: ScorerType,
    scoreboard_id: i64,
    objective_id: []const u8 = "",
    score: i32 = 0,
    entity_id: i64 = 0,
    name: []const u8 = "",

    pub fn write(stream: *BinaryStream, value: ScoreInfo) !void {
        try stream.writeVarInt(@intFromEnum(value.scorer_type));
        const type_name: []const u8 = switch (value.scorer_type) {
            .Invalid => "remove",
            .Player => "changeplayer",
            .Entity => "changeentity",
            .FakePlayer => "changefakeplayer",
        };
        try stream.writeVarString(type_name);
        try stream.writeZigZong(value.scoreboard_id);

        switch (value.scorer_type) {
            .Invalid => {
                if (value.objective_id.len == 0) {
                    try stream.writeBool(false);
                } else {
                    try stream.writeBool(true);
                    try stream.writeVarString(value.objective_id);
                }
            },
            .Player, .Entity => {
                const objective = if (value.objective_id.len == 0) " " else value.objective_id;
                try stream.writeVarString(objective);
                try stream.writeInt32(value.score, .Little);
                try stream.writeZigZong(value.entity_id);
            },
            .FakePlayer => {
                const objective = if (value.objective_id.len == 0) " " else value.objective_id;
                const fake_name = if (value.name.len == 0) " " else value.name;
                try stream.writeVarString(objective);
                try stream.writeInt32(value.score, .Little);
                try stream.writeVarString(fake_name);
            },
        }
    }
};

pub const SetScorePacket = struct {
    infos: []const ScoreInfo = &.{},

    pub fn serialize(self: *const SetScorePacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.SetScore);
        try stream.writeVarInt(@intCast(self.infos.len));
        for (self.infos) |info| {
            try ScoreInfo.write(stream, info);
        }
        return stream.getBuffer();
    }
};

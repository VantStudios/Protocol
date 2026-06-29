const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../enums/packet.zig").Packet;
const SoundEvent = @import("../enums/sound-event.zig").SoundEvent;
const Vector3f = @import("../types/vector3f.zig").Vector3f;

pub const LevelSoundEventPacket = struct {
    event: SoundEvent,
    position: Vector3f,
    data: i32,
    actorIdentifier: []const u8,
    isBabyMob: bool,
    isGlobal: bool,
    uniqueActorId: i64 = -1,
    fire_at_position: ?Vector3f = null,

    pub fn serialize(self: *const LevelSoundEventPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.LevelSoundEvent);

        try stream.writeVarString(self.event.asString());
        try Vector3f.write(stream, self.position);
        try stream.writeVarInt(@as(u32, @bitCast(self.data)));
        try stream.writeVarString(self.actorIdentifier);
        try stream.writeBool(self.isBabyMob);
        try stream.writeBool(self.isGlobal);
        try stream.writeInt64(self.uniqueActorId, .Little);
        if (self.fire_at_position) |fire_at_position| {
            try stream.writeBool(true);
            try Vector3f.write(stream, fire_at_position);
        } else {
            try stream.writeBool(false);
        }
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !LevelSoundEventPacket {
        _ = try stream.readVarInt();

        const eventStr = try stream.readVarString();
        const event = SoundEvent.fromString(eventStr);
        const position = try Vector3f.read(stream);
        const data_raw = try stream.readVarInt();
        const data = @as(i32, @bitCast(data_raw));
        const raw_actor_id = try stream.readVarString();
        const actorIdentifier = try allocator.dupe(u8, raw_actor_id);
        errdefer allocator.free(actorIdentifier);
        const isBabyMob = try stream.readBool();
        const isGlobal = try stream.readBool();
        const uniqueActorId = try stream.readInt64(.Little);
        var fire_at_position: ?Vector3f = null;
        if (try stream.readBool()) {
            fire_at_position = try Vector3f.read(stream);
        }

        return .{
            .event = event,
            .position = position,
            .data = data,
            .actorIdentifier = actorIdentifier,
            .isBabyMob = isBabyMob,
            .isGlobal = isGlobal,
            .uniqueActorId = uniqueActorId,
            .fire_at_position = fire_at_position,
        };
    }

    pub fn deinit(self: *LevelSoundEventPacket, allocator: std.mem.Allocator) void {
        allocator.free(self.actorIdentifier);
    }
};

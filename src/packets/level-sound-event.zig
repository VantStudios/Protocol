const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../enums/packet.zig").Packet;
const SoundEvent = @import("../enums/sound-event.zig").SoundEvent;
const Vector3f = @import("../types/vector3f.zig").Vector3f;

pub const LevelSoundEventPacket = struct {
    event: SoundEvent,
    position: Vector3f,
    data: i32,
    actor_identifier: []const u8,
    is_baby_mob: bool,
    is_global: bool,
    unique_actor_id: i64 = -1,
    fire_at_position: ?Vector3f = null,

    pub fn serialize(self: *const LevelSoundEventPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.LevelSoundEvent);

        try stream.writeVarString(self.event.asString());
        try Vector3f.write(stream, self.position);
        try stream.writeVarInt(@as(u32, @bitCast(self.data)));
        try stream.writeVarString(self.actor_identifier);
        try stream.writeBool(self.is_baby_mob);
        try stream.writeBool(self.is_global);
        try stream.writeInt64(self.unique_actor_id, .Little);
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
        const actor_identifier = try allocator.dupe(u8, raw_actor_id);
        errdefer allocator.free(actor_identifier);
        const is_baby_mob = try stream.readBool();
        const is_global = try stream.readBool();
        const unique_actor_id = try stream.readInt64(.Little);
        var fire_at_position: ?Vector3f = null;
        if (try stream.readBool()) {
            fire_at_position = try Vector3f.read(stream);
        }

        return .{
            .event = event,
            .position = position,
            .data = data,
            .actor_identifier = actor_identifier,
            .is_baby_mob = is_baby_mob,
            .is_global = is_global,
            .unique_actor_id = unique_actor_id,
            .fire_at_position = fire_at_position,
        };
    }

    pub fn deinit(self: *LevelSoundEventPacket, allocator: std.mem.Allocator) void {
        allocator.free(self.actor_identifier);
    }
};

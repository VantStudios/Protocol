const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;
const Vector3f = @import("../types/vector3f.zig").Vector3f;

pub const PlaySoundPacket = struct {
    name: []const u8,
    position: Vector3f,
    volume: f32,
    pitch: f32,
    loop_count: i32 = 0,
    bypass_listener_range_check: bool = false,
    server_sound_handle: ?i64 = null,
    playback_position_seconds: ?f32 = null,

    pub fn serialize(self: *const PlaySoundPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.PlaySound);
        try stream.writeVarString(self.name);

        try stream.writeZigZag(@as(i32, @intFromFloat(self.position.x * 8.0)));
        try stream.writeZigZag(@as(i32, @intFromFloat(self.position.y * 8.0)));
        try stream.writeZigZag(@as(i32, @intFromFloat(self.position.z * 8.0)));
        try stream.writeFloat32(self.volume, .Little);
        try stream.writeFloat32(self.pitch, .Little);

        try stream.writeVarInt(@bitCast(self.loop_count));
        try stream.writeBool(self.bypass_listener_range_check);
        if (self.server_sound_handle) |handle| {
            try stream.writeBool(true);
            try stream.writeInt64(handle, .Little);
        } else {
            try stream.writeBool(false);
        }
        if (self.playback_position_seconds) |seconds| {
            try stream.writeBool(true);
            try stream.writeFloat32(seconds, .Little);
        } else {
            try stream.writeBool(false);
        }
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !PlaySoundPacket {
        _ = try stream.readVarInt();
        const name = try stream.readVarString();
        const bx = @as(f32, @floatFromInt(try stream.readZigZag())) / 8.0;
        const by = @as(f32, @floatFromInt(try stream.readZigZag())) / 8.0;
        const bz = @as(f32, @floatFromInt(try stream.readZigZag())) / 8.0;
        const volume = try stream.readFloat32(.Little);
        const pitch = try stream.readFloat32(.Little);
        const loop_count: i32 = @bitCast(try stream.readVarInt());
        const bypass_listener_range_check = try stream.readBool();
        var server_sound_handle: ?i64 = null;
        if (try stream.readBool()) {
            server_sound_handle = try stream.readInt64(.Little);
        }
        var playback_position_seconds: ?f32 = null;
        if (try stream.readBool()) {
            playback_position_seconds = try stream.readFloat32(.Little);
        }
        return .{
            .name = name,
            .position = Vector3f.init(bx, by, bz),
            .volume = volume,
            .pitch = pitch,
            .loop_count = loop_count,
            .bypass_listener_range_check = bypass_listener_range_check,
            .server_sound_handle = server_sound_handle,
            .playback_position_seconds = playback_position_seconds,
        };
    }
};

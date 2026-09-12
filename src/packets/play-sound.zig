const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;
const Vector3f = @import("../types/vector3f.zig").Vector3f;

pub const PlaySoundPacket = struct {
    name: []const u8,
    position: Vector3f,
    volume: f32,
    pitch: f32,
    loop_count: i32 = 0,
    server_sound_handle: ?i64 = null,

    pub fn serialize(self: *const PlaySoundPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.PlaySound);
        try stream.writeVarString(self.name);

        try stream.writeZigZag(@as(i32, @intFromFloat(self.position.x * 8.0)));
        try stream.writeZigZag(@as(i32, @intFromFloat(self.position.y * 8.0)));
        try stream.writeZigZag(@as(i32, @intFromFloat(self.position.z * 8.0)));
        try stream.writeFloat32(self.volume, .Little);
        try stream.writeFloat32(self.pitch, .Little);

        try stream.writeZigZag(self.loop_count);
        if (self.server_sound_handle) |handle| {
            try stream.writeBool(true);
            try stream.writeInt64(handle, .Little);
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
        const loop_count = try stream.readZigZag();
        var server_sound_handle: ?i64 = null;
        if (try stream.readBool()) {
            server_sound_handle = try stream.readInt64(.Little);
        }
        return .{
            .name = name,
            .position = Vector3f.init(bx, by, bz),
            .volume = volume,
            .pitch = pitch,
            .loop_count = loop_count,
            .server_sound_handle = server_sound_handle,
        };
    }
};

const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;

pub const SoundAction = enum(u32) {
    Stop = 0,
    SetVolume = 1,
    SetPitch = 2,
    Fade = 3,
    SeekTo = 4,
    Pause = 5,
    Resume = 6,
};

pub const ClientboundUpdateSoundDataPacket = struct {
    server_sound_handle: i64 = 0,
    stop: bool = false,
    volume: ?f32 = null,
    pitch: ?f32 = null,
    fade_target_volume: ?f32 = null,
    fade_duration: ?f32 = null,
    seek_seconds: ?f32 = null,
    pause: bool = false,
    resume_: bool = false,

    fn writeEffect(stream: *BinaryStream, discriminator: u8, present: bool) !void {
        try stream.writeBool(present);
        if (present) {
            try stream.writeVarInt(discriminator);
        }
    }

    pub fn serialize(self: *const ClientboundUpdateSoundDataPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.ClientboundUpdateSoundData);
        try stream.writeInt64(self.server_sound_handle, .Little);

        try writeEffect(stream, 0, self.stop);
        if (self.volume) |v| {
            try writeEffect(stream, 0, true);
            try stream.writeFloat32(v, .Little);
        } else {
            try writeEffect(stream, 0, false);
        }
        if (self.pitch) |p| {
            try writeEffect(stream, 0, true);
            try stream.writeFloat32(p, .Little);
        } else {
            try writeEffect(stream, 0, false);
        }
        if (self.fade_target_volume != null and self.fade_duration != null) {
            try writeEffect(stream, 0, true);
            try stream.writeFloat32(self.fade_target_volume.?, .Little);
            try stream.writeFloat32(self.fade_duration.?, .Little);
        } else {
            try writeEffect(stream, 0, false);
        }
        if (self.seek_seconds) |s| {
            try writeEffect(stream, 0, true);
            try stream.writeFloat32(s, .Little);
        } else {
            try writeEffect(stream, 0, false);
        }
        try writeEffect(stream, 0, self.pause);
        try writeEffect(stream, 0, self.resume_);

        return stream.getBuffer();
    }
};

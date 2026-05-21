const BinaryStream = @import("BinaryStream").BinaryStream;
const std = @import("std");
const MoveDeltaFlags = @import("../types/move-delta-flags.zig").MoveDeltaFlags;

pub const MoveActorDeltaPacket = struct {
    runtime_id: u64,
    flags: u16,
    x: f32,
    y: f32,
    z: f32,
    pitch: f32,
    yaw: f32,
    head_yaw: f32,

    pub fn init(runtime_id: u64) MoveActorDeltaPacket {
        return .{
            .runtime_id = runtime_id,
            .flags = MoveDeltaFlags.None,
            .x = 0.0,
            .y = 0.0,
            .z = 0.0,
            .pitch = 0.0,
            .yaw = 0.0,
            .head_yaw = 0.0,
        };
    }

    fn writeByteFloat(stream: *BinaryStream, value: f32) !void {
        const byte_val = @mod(value, 360.0) / (360.0 / 256.0);
        try stream.writeUint8(@intFromFloat(@max(0.0, @min(255.0, byte_val))));
    }

    fn readByteFloat(stream: *BinaryStream) !f32 {
        const b = try stream.readUint8();
        return @as(f32, @floatFromInt(b)) * (360.0 / 256.0);
    }

    pub fn serialize(self: *const MoveActorDeltaPacket, stream: *BinaryStream) ![]const u8 {
        const Packet = @import("../enums/packet.zig").Packet;
        try stream.writeVarInt(Packet.MoveActorDelta);

        try stream.writeVarLong(self.runtime_id);
        try stream.writeUint16(self.flags, .Little);

        if (MoveDeltaFlags.hasFlag(self.flags, MoveDeltaFlags.HasX)) {
            try stream.writeFloat32(self.x, .Little);
        }
        if (MoveDeltaFlags.hasFlag(self.flags, MoveDeltaFlags.HasY)) {
            try stream.writeFloat32(self.y, .Little);
        }
        if (MoveDeltaFlags.hasFlag(self.flags, MoveDeltaFlags.HasZ)) {
            try stream.writeFloat32(self.z, .Little);
        }
        if (MoveDeltaFlags.hasFlag(self.flags, MoveDeltaFlags.HasRotX)) {
            try writeByteFloat(stream, if (!std.math.isInf(self.pitch)) self.pitch else 0.0);
        }
        if (MoveDeltaFlags.hasFlag(self.flags, MoveDeltaFlags.HasRotY)) {
            try writeByteFloat(stream, if (!std.math.isInf(self.yaw)) self.yaw else 0.0);
        }
        if (MoveDeltaFlags.hasFlag(self.flags, MoveDeltaFlags.HasRotZ)) {
            try writeByteFloat(stream, if (!std.math.isInf(self.yaw)) self.yaw else 0.0);
        }

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !MoveActorDeltaPacket {
        _ = try stream.readVarInt();
        const raw_id: u64 = @intCast(try stream.readVarLong());
        var packet = MoveActorDeltaPacket.init(raw_id);
        packet.flags = try stream.readUint16(.Little);

        if (MoveDeltaFlags.hasFlag(packet.flags, MoveDeltaFlags.HasX)) {
            packet.x = try stream.readFloat32(.Little);
        }
        if (MoveDeltaFlags.hasFlag(packet.flags, MoveDeltaFlags.HasY)) {
            packet.y = try stream.readFloat32(.Little);
        }
        if (MoveDeltaFlags.hasFlag(packet.flags, MoveDeltaFlags.HasZ)) {
            packet.z = try stream.readFloat32(.Little);
        }
        if (MoveDeltaFlags.hasFlag(packet.flags, MoveDeltaFlags.HasRotX)) {
            packet.pitch = try readByteFloat(stream);
        }
        if (MoveDeltaFlags.hasFlag(packet.flags, MoveDeltaFlags.HasRotY)) {
            packet.yaw = try readByteFloat(stream);
        }
        if (MoveDeltaFlags.hasFlag(packet.flags, MoveDeltaFlags.HasRotZ)) {
            packet.head_yaw = try readByteFloat(stream);
        }

        return packet;
    }
};

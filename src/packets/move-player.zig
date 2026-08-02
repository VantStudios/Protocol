const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;
const Vector3f = @import("../types/vector3f.zig").Vector3f;
const Vector2f = @import("../types/vector2f.zig").Vector2f;

pub const MoveMode = enum(u8) {
    Normal = 0,
    Respawn = 1,
    Teleport = 2,
    OnlyHeadRot = 3,
};

pub const MovePlayerTeleportData = struct {
    teleportation_cause: i32,
    source_actor_type: i32,
};

pub const MovePlayerPacket = struct {
    runtime_id: u64,
    position: Vector3f,
    pitch: f32,
    yaw: f32,
    head_yaw: f32,
    mode: MoveMode,
    on_ground: bool,
    riding_runtime_id: u64 = 0,
    teleport_data: ?MovePlayerTeleportData = null,
    tick: u64 = 0,

    pub fn serialize(self: *const MovePlayerPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.MovePlayer);
        try stream.writeVarLong(@intCast(self.runtime_id));
        try Vector3f.write(stream, self.position);
        try Vector2f.write(stream, Vector2f{ .x = self.pitch, .y = self.yaw });
        try stream.writeFloat32(self.head_yaw, .Little);

        try stream.writeUint8(@intFromEnum(self.mode));
        try stream.writeBool(self.on_ground);
        try stream.writeVarLong(@intCast(self.riding_runtime_id));

        const has_teleport = self.mode == .Teleport and self.teleport_data != null;
        try stream.writeBool(has_teleport);
        if (has_teleport) {
            try stream.writeUint32(@bitCast(self.teleport_data.?.teleportation_cause), .Little);
            try stream.writeUint32(@bitCast(self.teleport_data.?.source_actor_type), .Little);
        }

        try stream.writeVarLong(@intCast(self.tick));
        return stream.getBuffer();
    }
};

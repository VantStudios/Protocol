const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;
const Vector3f = @import("../types/vector3f.zig").Vector3f;

pub const MoveMode = enum(u8) {
    Normal = 0,
    Respawn = 1,
    Teleport = 2,
    OnlyHeadRot = 3,
};

pub const TeleportationCause = enum(i32) {
    Unknown = 0,
    Projectile = 1,
    ChorusFruit = 2,
    Command = 3,
    Behavior = 4,
};

pub const MovePlayerTeleportData = struct {
    teleportation_cause: TeleportationCause,
    source_actor_type: i32,
};

pub const MovePlayerPacket = struct {
    runtime_id: u64,
    position: Vector3f,
    rotation: Vector3f = Vector3f.zero(),
    mode: MoveMode,
    on_ground: bool,
    riding_runtime_id: u64 = 0,
    teleport_data: ?MovePlayerTeleportData = null,
    tick: u64 = 0,

    pub fn serialize(self: *const MovePlayerPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.MovePlayer);
        try stream.writeVarLong(@intCast(self.runtime_id));
        try Vector3f.write(stream, self.position);
        try Vector3f.write(stream, self.rotation);
        try stream.writeUint8(@intFromEnum(self.mode));
        try stream.writeBool(self.on_ground);
        try stream.writeVarLong(@intCast(self.riding_runtime_id));

        const has_teleport = self.mode == .Teleport;
        try stream.writeBool(has_teleport);
        if (has_teleport) {
            const data = self.teleport_data orelse MovePlayerTeleportData{
                .teleportation_cause = .Unknown,
                .source_actor_type = 0,
            };
            try stream.writeInt32(@intFromEnum(data.teleportation_cause), .Little);
            try stream.writeInt32(data.source_actor_type, .Little);
        }

        try stream.writeVarLong(@intCast(self.tick));
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !MovePlayerPacket {
        _ = try stream.readVarInt();

        const runtime_id: u64 = @intCast(try stream.readVarLong());
        const position = try Vector3f.read(stream);
        const rotation = try Vector3f.read(stream);
        const mode: MoveMode = @enumFromInt(try stream.readUint8());
        const on_ground = try stream.readBool();
        const riding_runtime_id: u64 = @intCast(try stream.readVarLong());

        var teleport_data: ?MovePlayerTeleportData = null;
        if (try stream.readBool()) {
            const cause_raw = try stream.readInt32(.Little);
            const cause: TeleportationCause = std.enums.fromInt(TeleportationCause, cause_raw) orelse .Unknown;
            const source_actor_type = try stream.readInt32(.Little);
            teleport_data = MovePlayerTeleportData{
                .teleportation_cause = cause,
                .source_actor_type = source_actor_type,
            };
        }

        const tick: u64 = @intCast(try stream.readVarLong());

        return MovePlayerPacket{
            .runtime_id = runtime_id,
            .position = position,
            .rotation = rotation,
            .mode = mode,
            .on_ground = on_ground,
            .riding_runtime_id = riding_runtime_id,
            .teleport_data = teleport_data,
            .tick = tick,
        };
    }
};

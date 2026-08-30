const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;
const Vector3f = @import("../types/vector3f.zig").Vector3f;

pub const PlayerLocationType = enum(u8) {
    Coordinates = 0,
    Hide = 1,
    Respawn = 2,
    _,

    pub fn fromOrdinal(o: u8) PlayerLocationType {
        return switch (o) {
            0 => .Coordinates,
            1 => .Hide,
            2 => .Respawn,
            else => .Coordinates,
        };
    }
};

pub const PlayerLocationPacket = struct {
    target_entity_id: i64,
    location_type: PlayerLocationType,
    position: Vector3f,

    pub fn serialize(self: *const PlayerLocationPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.PlayerLocation);
        try stream.writeZigZong(self.target_entity_id);
        const ordinal: u32 = @intFromEnum(self.location_type);
        try stream.writeVarInt(ordinal);
        try stream.writeZigZag(@intCast(ordinal));
        if (self.location_type == .Coordinates) {
            try Vector3f.write(stream, self.position);
        }
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !PlayerLocationPacket {
        _ = try stream.readVarInt();
        const target_entity_id = try stream.readZigZong();
        const location_type_ordinal: u8 = @intCast(try stream.readVarInt());
        _ = try stream.readZigZag(); // duplicated signed ordinal, discarded
        const location_type = PlayerLocationType.fromOrdinal(location_type_ordinal);

        var position = Vector3f.zero();
        if (location_type == .Coordinates) {
            position = try Vector3f.read(stream);
        }

        return .{
            .target_entity_id = target_entity_id,
            .location_type = location_type,
            .position = position,
        };
    }
};

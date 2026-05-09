const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;
const Vector3f = @import("../types/vector3f.zig").Vector3f;

pub const ActorEventType = enum(u8) {
    Hurt = 2,
    Death = 3,
    StartAttacking = 4,
    StopAttacking = 5,
    Respawn = 18,
    _,
};

pub const ActorEventPacket = struct {
    runtimeEntityId: u64,
    event: ActorEventType,
    data: i32 = 0,
    fire_at_position: ?Vector3f = null,

    pub fn serialize(self: *const ActorEventPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.ActorEvent);
        try stream.writeVarLong(self.runtimeEntityId);
        try stream.writeUint8(@intFromEnum(self.event));
        try stream.writeZigZag(self.data);
        if (self.fire_at_position) |fire_at_position| {
            try stream.writeBool(true);
            try Vector3f.write(stream, fire_at_position);
        } else {
            try stream.writeBool(false);
        }

        return stream.getBuffer();
    }
};

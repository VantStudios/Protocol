const BinaryStream = @import("BinaryStream").BinaryStream;

pub const MoveActorDeltaPacket = struct {
    runtime_id: u64,
    x: ?f32 = null,
    y: ?f32 = null,
    z: ?f32 = null,
    rotation_x: ?i8 = null,
    rotation_y: ?i8 = null,
    rotation_y_head: ?i8 = null,
    on_ground: bool = false,
    force_move: bool = false,
    force_move_local_entity: bool = false,
    force_completion: bool = false,
    ticks: u64 = 0,

    pub fn init(runtime_id: u64) MoveActorDeltaPacket {
        return .{
            .runtime_id = runtime_id,
        };
    }

    fn writeOptionalFloat(stream: *BinaryStream, value: ?f32) !void {
        if (value) |v| {
            try stream.writeBool(true);
            try stream.writeFloat32(v, .Little);
        } else {
            try stream.writeBool(false);
        }
    }

    fn writeOptionalI8(stream: *BinaryStream, value: ?i8) !void {
        if (value) |v| {
            try stream.writeBool(true);
            try stream.writeInt8(v);
        } else {
            try stream.writeBool(false);
        }
    }

    fn readOptionalFloat(stream: *BinaryStream) !?f32 {
        if (try stream.readBool()) {
            return try stream.readFloat32(.Little);
        }
        return null;
    }

    fn readOptionalI8(stream: *BinaryStream) !?i8 {
        if (try stream.readBool()) {
            return try stream.readInt8();
        }
        return null;
    }

    pub fn serialize(self: *const MoveActorDeltaPacket, stream: *BinaryStream) ![]const u8 {
        const Packet = @import("../enums/packet.zig").Packet;
        try stream.writeVarInt(Packet.MoveActorDelta);

        try stream.writeVarLong(self.runtime_id);
        try writeOptionalFloat(stream, self.x);
        try writeOptionalFloat(stream, self.y);
        try writeOptionalFloat(stream, self.z);
        try writeOptionalI8(stream, self.rotation_x);
        try writeOptionalI8(stream, self.rotation_y);
        try writeOptionalI8(stream, self.rotation_y_head);
        try stream.writeBool(self.on_ground);
        try stream.writeBool(self.force_move);
        try stream.writeBool(self.force_move_local_entity);
        try stream.writeBool(self.force_completion);
        try stream.writeVarLong(@bitCast(self.ticks));

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !MoveActorDeltaPacket {
        _ = try stream.readVarInt();
        const runtime_id: u64 = @intCast(try stream.readVarLong());
        const x = try readOptionalFloat(stream);
        const y = try readOptionalFloat(stream);
        const z = try readOptionalFloat(stream);
        const rotation_x = try readOptionalI8(stream);
        const rotation_y = try readOptionalI8(stream);
        const rotation_y_head = try readOptionalI8(stream);
        const on_ground = try stream.readBool();
        const force_move = try stream.readBool();
        const force_move_local_entity = try stream.readBool();
        const force_completion = try stream.readBool();
        const ticks: u64 = @bitCast(try stream.readVarLong());

        return MoveActorDeltaPacket{
            .runtime_id = runtime_id,
            .x = x,
            .y = y,
            .z = z,
            .rotation_x = rotation_x,
            .rotation_y = rotation_y,
            .rotation_y_head = rotation_y_head,
            .on_ground = on_ground,
            .force_move = force_move,
            .force_move_local_entity = force_move_local_entity,
            .force_completion = force_completion,
            .ticks = ticks,
        };
    }
};

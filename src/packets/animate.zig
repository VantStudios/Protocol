const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;

pub const AnimateAction = enum(u8) {
    SwingArm = 1,
    StopSleep = 2,
    CriticalHit = 3,
    MagicCriticalHit = 4,
    _,
};

pub const SwingSource = enum(u8) {
    None = 0,
    Build = 1,
    Mine = 2,
    Interact = 3,
    Attack = 4,
    UseItem = 5,
    ThrowItem = 6,
    DropItem = 7,
    Event = 8,
    _,
};

pub const AnimatePacket = struct {
    action: AnimateAction,
    runtime_entity_id: u64,
    data: f32 = 0,
    swing_source: ?SwingSource = null,

    pub fn serialize(self: *const AnimatePacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.Animate);
        try stream.writeUint8(@intFromEnum(self.action));
        try stream.writeVarLong(self.runtime_entity_id);
        try stream.writeFloat32(self.data, .Little);
        if (self.swing_source) |source| {
            try stream.writeBool(true);
            try stream.writeUint8(@intFromEnum(source));
        } else {
            try stream.writeBool(false);
        }
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !AnimatePacket {
        _ = try stream.readVarInt();
        const action_raw = try stream.readUint8();
        const action: AnimateAction = std.enums.fromInt(AnimateAction, action_raw) orelse return error.UnknownAnimateAction;
        const runtime_entity_id: u64 = @intCast(try stream.readVarLong());
        const data = try stream.readFloat32(.Little);
        var swing_source: ?SwingSource = null;
        if (try stream.readBool()) {
            const swing_source_raw = try stream.readUint8();
            swing_source = std.enums.fromInt(SwingSource, swing_source_raw) orelse .None;
        }
        return AnimatePacket{
            .action = action,
            .runtime_entity_id = runtime_entity_id,
            .data = data,
            .swing_source = swing_source,
        };
    }
};

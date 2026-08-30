const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../enums/packet.zig").Packet;

pub const UpdateType = enum(u8) {
    Clear = 0,
    Remove = 1,
    SetIntOverride = 2,
    SetFloatOverride = 3,
};

pub const PlayerUpdateEntityOverridesPacket = struct {
    entity_unique_id: i64,
    property_index: u32,
    update_type: UpdateType,
    int_value: i32 = 0,
    float_value: f32 = 0.0,

    pub fn serialize(self: *const PlayerUpdateEntityOverridesPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.PlayerUpdateEntityOverrides);
        try stream.writeZigZong(self.entity_unique_id);
        try stream.writeVarInt(self.property_index);
        try stream.writeVarInt(@intFromEnum(self.update_type));
        try stream.writeUint8(@intFromEnum(self.update_type));
        switch (self.update_type) {
            .SetIntOverride => try stream.writeInt32(self.int_value, .Little),
            .SetFloatOverride => try stream.writeFloat32(self.float_value, .Little),
            else => {},
        }
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !PlayerUpdateEntityOverridesPacket {
        _ = try stream.readVarInt();
        const entity_unique_id = try stream.readZigZong();
        const property_index: u32 = @intCast(try stream.readVarInt());

        const type_varuint: u32 = @intCast(try stream.readVarInt());
        const type_byte: u8 = try stream.readUint8();
        if (type_varuint != type_byte) {
            return error.PlayerUpdateEntityOverridesTypeMismatch;
        }
        const update_type: UpdateType = @enumFromInt(type_varuint);

        var int_value: i32 = 0;
        var float_value: f32 = 0.0;
        switch (update_type) {
            .SetIntOverride => int_value = try stream.readInt32(.Little),
            .SetFloatOverride => float_value = try stream.readFloat32(.Little),
            else => {},
        }

        return .{
            .entity_unique_id = entity_unique_id,
            .property_index = property_index,
            .update_type = update_type,
            .int_value = int_value,
            .float_value = float_value,
        };
    }
};

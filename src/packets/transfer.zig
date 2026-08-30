const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;

pub const TransferPacket = struct {
    address: []const u8,
    port: i32,
    reload_world: bool,
    has_gatherings_configuration: bool = false,

    pub fn serialize(self: *const TransferPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.Transfer);
        try stream.writeVarString(self.address);
        try stream.writeInt32(self.port, .Little);
        try stream.writeBool(self.reload_world);
        try stream.writeBool(self.has_gatherings_configuration);
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !TransferPacket {
        _ = try stream.readVarInt();
        const address = try stream.readVarString();
        const port = try stream.readInt32(.Little);
        const reload_world = try stream.readBool();
        const has_gatherings_configuration = try stream.readBool();
        return .{
            .address = address,
            .port = port,
            .reload_world = reload_world,
            .has_gatherings_configuration = has_gatherings_configuration,
        };
    }
};

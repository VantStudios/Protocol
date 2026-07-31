const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;
const BlockPosition = @import("../types/block-position.zig").BlockPosition;
const PlayerActionType = @import("../enums/player-action-type.zig").PlayerActionType;

pub const PlayerActionPacket = struct {
    runtime_entity_id: u64,
    action: PlayerActionType,
    block_position: BlockPosition,
    result_position: BlockPosition,
    face: i32,

    pub fn deserialize(stream: *BinaryStream) !PlayerActionPacket {
        _ = try stream.readVarInt();
        const runtime_entity_id: u64 = @intCast(try stream.readVarLong());
        const action: PlayerActionType = @enumFromInt(try stream.readZigZag());
        const block_position = try BlockPosition.read(stream);
        const result_position = try BlockPosition.read(stream);
        const face = try stream.readZigZag();

        return .{
            .runtime_entity_id = runtime_entity_id,
            .action = action,
            .block_position = block_position,
            .result_position = result_position,
            .face = face,
        };
    }

    pub fn serialize(self: *const PlayerActionPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.PlayerAction);
        try stream.writeVarLong(self.runtime_entity_id);
        try stream.writeZigZag(@intFromEnum(self.action));
        try BlockPosition.write(stream, self.block_position);
        try BlockPosition.write(stream, self.result_position);
        try stream.writeZigZag(self.face);
        return stream.getBuffer();
    }
};

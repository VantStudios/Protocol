const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const PlayerActionType = @import("../enums/player-action-type.zig").PlayerActionType;
const BlockPosition = @import("block-position.zig").BlockPosition;

pub const PlayerBlockAction = struct {
    action: PlayerActionType,
    block_pos: BlockPosition,
    face: i32,

    pub fn read(stream: *BinaryStream) !PlayerBlockAction {
        const action: PlayerActionType = @enumFromInt(try stream.readZigZag());
        const block_pos = try BlockPosition.read(stream);
        const face = try stream.readZigZag();
        return .{
            .action = action,
            .block_pos = block_pos,
            .face = face,
        };
    }

    pub fn write(stream: *BinaryStream, value: PlayerBlockAction) !void {
        try stream.writeZigZag(@intFromEnum(value.action));
        try BlockPosition.write(stream, value.block_pos);
        try stream.writeZigZag(value.face);
    }
};

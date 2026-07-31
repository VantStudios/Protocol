const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const PlayerActionType = @import("../enums/player-action-type.zig").PlayerActionType;
const BlockPosition = @import("block-position.zig").BlockPosition;

pub const PlayerBlockAction = struct {
    action: PlayerActionType,
    block_pos: BlockPosition,
    face: i32,

    fn readBlockPos(stream: *BinaryStream) !BlockPosition {
        const x = try stream.readZigZag();
        const y = try stream.readZigZag();
        const z = try stream.readZigZag();
        return BlockPosition{ .x = x, .y = y, .z = z };
    }

    fn writeBlockPos(stream: *BinaryStream, value: BlockPosition) !void {
        try stream.writeZigZag(value.x);
        try stream.writeZigZag(value.y);
        try stream.writeZigZag(value.z);
    }

    pub fn read(stream: *BinaryStream) !PlayerBlockAction {
        const action: PlayerActionType = @enumFromInt(try stream.readZigZag());
        var block_pos = BlockPosition.init(0, 0, 0);
        var face: i32 = 0;

        if (action.hasBlockPos()) {
            block_pos = try readBlockPos(stream);
            face = try stream.readZigZag();
        }

        return .{
            .action = action,
            .block_pos = block_pos,
            .face = face,
        };
    }

    pub fn write(stream: *BinaryStream, value: PlayerBlockAction) !void {
        try stream.writeZigZag(@intFromEnum(value.action));
        if (value.action.hasBlockPos()) {
            try writeBlockPos(stream, value.block_pos);
            try stream.writeZigZag(value.face);
        }
    }
};

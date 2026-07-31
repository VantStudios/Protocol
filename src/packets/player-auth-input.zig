const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const Vector2f = @import("../types/vector2f.zig").Vector2f;
const Vector3f = @import("../types/vector3f.zig").Vector3f;
const PlayerAuthInputData = @import("../types/player-auth-input-data.zig").PlayerAuthInputData;
const InputMode = @import("../enums/input-mode.zig").InputMode;
const PlayMode = @import("../enums/play-mode.zig").PlayMode;
const InteractionMode = @import("../enums/interaction-mode.zig").InteractionMode;
const InputData = @import("../enums/input-data.zig").InputData;
const PlayerBlockAction = @import("../types/player-block-action.zig").PlayerBlockAction;
const ItemUseTransaction = @import("../types/item-use-transaction.zig").ItemUseTransaction;
const ItemStackRequest = @import("../types/item-stack-request.zig").ItemStackRequest;
const BlockPosition = @import("../types/block-position.zig").BlockPosition;

pub const PlayerAuthInputPacket = struct {
    rotation: Vector2f,
    position: Vector3f,
    motion: Vector2f,
    head_yaw: f32,
    input_data: PlayerAuthInputData,
    input_mode: InputMode,
    play_mode: PlayMode,
    interaction_mode: InteractionMode,
    interact_rotation: Vector2f,
    input_tick: u64,
    position_delta: Vector3f,
    item_transaction: ?ItemUseTransaction,
    block_actions: [MAX_BLOCK_ACTIONS]PlayerBlockAction,
    block_action_count: u32,
    vehicle_rotation: Vector2f,
    client_predicted_vehicle: i64,
    analogue_motion: Vector2f,
    camera_orientation: Vector3f,
    raw_move_vector: Vector2f,

    const MAX_BLOCK_ACTIONS = 16;

    pub fn deserialize(stream: *BinaryStream) !PlayerAuthInputPacket {
        _ = try stream.readVarInt();

        const rotation = try Vector2f.read(stream);
        const position = try Vector3f.read(stream);
        const motion = try Vector2f.read(stream);
        const head_yaw = try stream.readFloat32(.Little);
        const input_data = try PlayerAuthInputData.read(stream);
        const input_mode: InputMode = @enumFromInt(try stream.readVarInt());
        const play_mode: PlayMode = @enumFromInt(try stream.readVarInt());
        const interaction_mode: InteractionMode = @enumFromInt(try stream.readVarInt());
        const interact_rotation = try Vector2f.read(stream);
        const input_tick: u64 = @intCast(try stream.readVarLong());
        const position_delta = try Vector3f.read(stream);

        var item_transaction: ?ItemUseTransaction = null;
        if (input_data.hasFlag(.PerformItemInteraction)) {
            item_transaction = try ItemUseTransaction.read(stream);
        }

        if (input_data.hasFlag(.PerformItemStackRequest)) {
            try ItemStackRequest.skip(stream);
        }

        var block_actions: [MAX_BLOCK_ACTIONS]PlayerBlockAction = undefined;
        var block_action_count: u32 = 0;
        if (input_data.hasFlag(.PerformBlockActions)) {
            const count: u32 = @intCast(try stream.readZigZag());
            const read_count = @min(count, MAX_BLOCK_ACTIONS);
            for (0..read_count) |i| {
                block_actions[i] = try PlayerBlockAction.read(stream);
            }
            for (read_count..count) |_| {
                _ = try PlayerBlockAction.read(stream);
            }
            block_action_count = read_count;
        }

        var vehicle_rotation = Vector2f.init(0, 0);
        var client_predicted_vehicle: i64 = 0;
        if (input_data.hasFlag(.IsInClientPredictedVehicle)) {
            vehicle_rotation = try Vector2f.read(stream);
            client_predicted_vehicle = try stream.readZigZong();
        }

        const analogue_motion = try Vector2f.read(stream);
        const camera_orientation = try Vector3f.read(stream);
        const raw_move_vector = try Vector2f.read(stream);

        return PlayerAuthInputPacket{
            .rotation = rotation,
            .position = position,
            .motion = motion,
            .head_yaw = head_yaw,
            .input_data = input_data,
            .input_mode = input_mode,
            .play_mode = play_mode,
            .interaction_mode = interaction_mode,
            .interact_rotation = interact_rotation,
            .input_tick = input_tick,
            .position_delta = position_delta,
            .item_transaction = item_transaction,
            .block_actions = block_actions,
            .block_action_count = block_action_count,
            .vehicle_rotation = vehicle_rotation,
            .client_predicted_vehicle = client_predicted_vehicle,
            .analogue_motion = analogue_motion,
            .camera_orientation = camera_orientation,
            .raw_move_vector = raw_move_vector,
        };
    }

    pub fn serialize(self: *PlayerAuthInputPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.PlayerAuthInput);

        try Vector2f.write(stream, self.rotation);
        try Vector3f.write(stream, self.position);
        try Vector2f.write(stream, self.motion);
        try stream.writeFloat32(self.head_yaw, .Little);
        try PlayerAuthInputData.write(stream, self.input_data);
        try stream.writeVarInt(@intFromEnum(self.input_mode));
        try stream.writeVarInt(@intFromEnum(self.play_mode));
        try stream.writeVarInt(@intFromEnum(self.interaction_mode));
        try Vector2f.write(stream, self.interact_rotation);
        try stream.writeVarLong(@intCast(self.input_tick));
        try Vector3f.write(stream, self.position_delta);

        if (self.input_data.hasFlag(.PerformBlockActions)) {
            try stream.writeZigZag(@intCast(self.block_action_count));
            for (0..self.block_action_count) |i| {
                try PlayerBlockAction.write(stream, self.block_actions[i]);
            }
        }

        if (self.input_data.hasFlag(.IsInClientPredictedVehicle)) {
            try Vector2f.write(stream, self.vehicle_rotation);
            try stream.writeZigZong(self.client_predicted_vehicle);
        }

        try Vector2f.write(stream, self.analogue_motion);
        try Vector3f.write(stream, self.camera_orientation);
        try Vector2f.write(stream, self.raw_move_vector);

        return stream.getBuffer();
    }

    pub fn getBlockActions(self: *const PlayerAuthInputPacket) []const PlayerBlockAction {
        return self.block_actions[0..self.block_action_count];
    }
};

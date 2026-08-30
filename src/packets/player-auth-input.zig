const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const Vector2f = @import("../types/vector2f.zig").Vector2f;
const Vector3f = @import("../types/vector3f.zig").Vector3f;
const PlayerAuthInputData = @import("../types/player-auth-input-data.zig").PlayerAuthInputData;
const InputMode = @import("../enums/input-mode.zig").InputMode;
const PlayMode = @import("../enums/play-mode.zig").PlayMode;
const InteractionMode = @import("../enums/interaction-mode.zig").InteractionMode;
const PlayerBlockAction = @import("../types/player-block-action.zig").PlayerBlockAction;
const ItemUseTransaction = @import("../types/item-use-transaction.zig").ItemUseTransaction;
const ItemStackRequest = @import("../types/item-stack-request.zig").ItemStackRequest;
const BlockPosition = @import("../types/block-position.zig").BlockPosition;

pub const PlayerAuthInputPacket = struct {
    rotation: Vector3f,
    position: Vector3f,
    motion: Vector2f,
    input_data: PlayerAuthInputData,
    input_mode: InputMode,
    play_mode: PlayMode,
    interaction_mode: InteractionMode,
    interact_rotation: Vector2f,
    input_tick: u64,
    position_delta: Vector3f,
    item_transaction: ?ItemUseTransaction = null,
    item_stack_request: ?ItemStackRequest = null,
    block_actions: [MAX_BLOCK_ACTIONS]PlayerBlockAction = undefined,
    block_action_count: u32 = 0,
    vehicle_rotation: Vector2f = Vector2f.zero(),
    client_predicted_vehicle: i64 = 0,
    analogue_motion: Vector2f = Vector2f.zero(),
    camera_orientation: Vector3f = Vector3f.zero(),
    raw_move_vector: Vector2f = Vector2f.zero(),

    const MAX_BLOCK_ACTIONS = 32;

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !PlayerAuthInputPacket {
        _ = try stream.readVarInt();

        const rotation_x = try stream.readFloat32(.Little);
        const rotation_y = try stream.readFloat32(.Little);
        const position = try Vector3f.read(stream);
        const motion = try Vector2f.read(stream);
        const rotation_z = try stream.readFloat32(.Little);

        const input_data = try PlayerAuthInputData.read(stream);
        const input_mode: InputMode = @enumFromInt(try stream.readVarInt());
        const play_mode: PlayMode = @enumFromInt(try stream.readVarInt());

        const interaction_mode_signed = try stream.readZigZag();

        const interaction_mode: InteractionMode = std.enums.fromInt(
            InteractionMode,
            interaction_mode_signed,
        ) orelse InteractionMode.Touch;

        const interact_rotation = try Vector2f.read(stream);
        const input_tick: u64 = @intCast(try stream.readVarLong());
        const position_delta = try Vector3f.read(stream);

        var item_transaction: ?ItemUseTransaction = null;
        if (try stream.readBool()) {
            if (try stream.readBool()) {
                item_transaction = try ItemUseTransaction.read(stream);
            }
        }

        var item_stack_request: ?ItemStackRequest = null;
        if (try stream.readBool()) {
            if (try stream.readBool()) {
                item_stack_request = try ItemStackRequest.read(stream, allocator);
                errdefer {
                    if (item_stack_request) |*item| item.deinit(allocator);
                }
            }
        }

        var block_actions: [MAX_BLOCK_ACTIONS]PlayerBlockAction = undefined;
        var block_action_count: u32 = 0;
        if (try stream.readBool()) {
            if (try stream.readBool()) {
                const count: u32 = try stream.readVarInt();
                const read_count = @min(count, MAX_BLOCK_ACTIONS);
                for (0..read_count) |i| {
                    block_actions[i] = try PlayerBlockAction.read(stream);
                }
                for (read_count..count) |_| {
                    _ = try PlayerBlockAction.read(stream);
                }
                block_action_count = read_count;
            }
        }

        var vehicle_rotation = Vector2f.zero();
        if (try stream.readBool()) {
            if (try stream.readBool()) {
                vehicle_rotation = try Vector2f.read(stream);
            }
        }

        var client_predicted_vehicle: i64 = 0;
        if (try stream.readBool()) {
            if (try stream.readBool()) {
                client_predicted_vehicle = try stream.readZigZong();
            }
        }

        const analogue_motion = try Vector2f.read(stream);
        const camera_orientation = try Vector3f.read(stream);
        const raw_move_vector = try Vector2f.read(stream);

        return PlayerAuthInputPacket{
            .rotation = Vector3f.init(rotation_x, rotation_y, rotation_z),
            .position = position,
            .motion = motion,
            .input_data = input_data,
            .input_mode = input_mode,
            .play_mode = play_mode,
            .interaction_mode = interaction_mode,
            .interact_rotation = interact_rotation,
            .input_tick = input_tick,
            .position_delta = position_delta,
            .item_transaction = item_transaction,
            .item_stack_request = item_stack_request,
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

        try stream.writeFloat32(self.rotation.x, .Little);
        try stream.writeFloat32(self.rotation.y, .Little);
        try Vector3f.write(stream, self.position);
        try Vector2f.write(stream, self.motion);
        try stream.writeFloat32(self.rotation.z, .Little);

        try PlayerAuthInputData.write(stream, self.input_data);
        try stream.writeVarInt(@intFromEnum(self.input_mode));
        try stream.writeVarInt(@intFromEnum(self.play_mode));

        try stream.writeZigZag(@intFromEnum(self.interaction_mode));
        try Vector2f.write(stream, self.interact_rotation);
        try stream.writeVarLong(@intCast(self.input_tick));
        try Vector3f.write(stream, self.position_delta);

        try stream.writeBool(true);
        if (self.item_transaction) |tx| {
            try stream.writeBool(true);
            try ItemUseTransaction.write(stream, tx);
        } else {
            try stream.writeBool(false);
        }

        try stream.writeBool(true);
        if (self.item_stack_request) |req| {
            try stream.writeBool(true);
            try ItemStackRequest.write(stream, req);
        } else {
            try stream.writeBool(false);
        }

        try stream.writeBool(true);
        if (self.block_action_count > 0) {
            try stream.writeBool(true);
            try stream.writeVarInt(self.block_action_count);
            for (0..self.block_action_count) |i| {
                try PlayerBlockAction.write(stream, self.block_actions[i]);
            }
        } else {
            try stream.writeBool(false);
        }

        try stream.writeBool(true);
        if (self.client_predicted_vehicle != 0) {
            try stream.writeBool(true);
            try Vector2f.write(stream, self.vehicle_rotation);
        } else {
            try stream.writeBool(false);
        }

        try stream.writeBool(true);
        if (self.client_predicted_vehicle != 0) {
            try stream.writeBool(true);
            try stream.writeZigZong(self.client_predicted_vehicle);
        } else {
            try stream.writeBool(false);
        }

        try Vector2f.write(stream, self.analogue_motion);
        try Vector3f.write(stream, self.camera_orientation);
        try Vector2f.write(stream, self.raw_move_vector);

        return stream.getBuffer();
    }

    pub fn getBlockActions(self: *const PlayerAuthInputPacket) []const PlayerBlockAction {
        return self.block_actions[0..self.block_action_count];
    }

    pub fn deinit(self: *PlayerAuthInputPacket, allocator: std.mem.Allocator) void {
        if (self.item_stack_request) |*item| item.deinit(allocator);
    }
};

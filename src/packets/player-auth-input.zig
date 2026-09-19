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

    const MAX_BLOCK_ACTIONS = 64;

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !PlayerAuthInputPacket {
        _ = try stream.readVarInt();

        const rotation_x = try stream.readFloat32(.Little);
        const rotation_y = try stream.readFloat32(.Little);
        const position = try Vector3f.read(stream);
        const motion = try Vector2f.read(stream);
        const rotation_z = try stream.readFloat32(.Little);

        const input_data = try PlayerAuthInputData.read(stream);
        const input_mode: InputMode = std.enums.fromInt(
            InputMode,
            try stream.readVarInt(),
        ) orelse return error.UnknownInputMode;
        const play_mode: PlayMode = std.enums.fromInt(
            PlayMode,
            try stream.readVarInt(),
        ) orelse return error.UnknownPlayMode;

        const interaction_mode_signed = try stream.readZigZag();

        const interaction_mode: InteractionMode = std.enums.fromInt(
            InteractionMode,
            interaction_mode_signed,
        ) orelse InteractionMode.Touch;

        const interact_rotation = try Vector2f.read(stream);
        const input_tick: u64 = try stream.readVarLong();
        const position_delta = try Vector3f.read(stream);

        var item_transaction: ?ItemUseTransaction = null;
        errdefer {
            if (item_transaction) |*tx| tx.deinit(allocator);
        }
        if (try stream.readBool()) {
            item_transaction = try ItemUseTransaction.read(stream, allocator);
        }

        var item_stack_request: ?ItemStackRequest = null;
        errdefer {
            if (item_stack_request) |*item| item.deinit(allocator);
        }
        if (try stream.readBool()) {
            item_stack_request = try ItemStackRequest.read(stream, allocator);
        }

        var block_actions: [MAX_BLOCK_ACTIONS]PlayerBlockAction = undefined;
        var block_action_count: u32 = 0;
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

        var vehicle_rotation = Vector2f.zero();
        var client_predicted_vehicle: i64 = 0;
        if (try stream.readBool()) {
            vehicle_rotation = try Vector2f.read(stream);
        }
        if (try stream.readBool()) {
            client_predicted_vehicle = try stream.readZigZong();
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

        var input_data = self.input_data;
        input_data.setFlag(.PerformItemInteraction, self.item_transaction != null);
        input_data.setFlag(.PerformItemStackRequest, self.item_stack_request != null);
        input_data.setFlag(.PerformBlockActions, self.block_action_count > 0);
        input_data.setFlag(.IsInClientPredictedVehicle, self.client_predicted_vehicle != 0);
        try PlayerAuthInputData.write(stream, input_data);

        try stream.writeVarInt(@intCast(@intFromEnum(self.input_mode)));
        try stream.writeVarInt(@intCast(@intFromEnum(self.play_mode)));

        try stream.writeZigZag(@intFromEnum(self.interaction_mode));
        try Vector2f.write(stream, self.interact_rotation);
        try stream.writeVarLong(self.input_tick);
        try Vector3f.write(stream, self.position_delta);

        if (self.item_transaction) |tx| {
            try stream.writeBool(true);
            try ItemUseTransaction.write(tx, stream, stream.allocator);
        } else {
            try stream.writeBool(false);
        }

        if (self.item_stack_request) |req| {
            try stream.writeBool(true);
            try ItemStackRequest.write(stream, req);
        } else {
            try stream.writeBool(false);
        }

        if (self.block_action_count > 0) {
            try stream.writeBool(true);
            try stream.writeVarInt(self.block_action_count);
            for (0..self.block_action_count) |i| {
                try PlayerBlockAction.write(stream, self.block_actions[i]);
            }
        } else {
            try stream.writeBool(false);
        }

        const in_vehicle = self.client_predicted_vehicle != 0;
        try stream.writeBool(in_vehicle);
        if (in_vehicle) {
            try Vector2f.write(stream, self.vehicle_rotation);
        }
        try stream.writeBool(in_vehicle);
        if (in_vehicle) {
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

    pub fn deinit(self: *PlayerAuthInputPacket, allocator: std.mem.Allocator) void {
        if (self.item_transaction) |*tx| tx.deinit(allocator);
        if (self.item_stack_request) |*item| item.deinit(allocator);
    }
};

const testing = std.testing;

fn buildTestPacket() PlayerAuthInputPacket {
    var input_data = PlayerAuthInputData.init(0);
    input_data.setFlag(.Up, true);
    input_data.setFlag(.SneakDown, true);
    // Must be force-cleared on serialize because item_transaction is null.
    input_data.setFlag(.PerformItemInteraction, true);

    var packet = PlayerAuthInputPacket{
        .rotation = Vector3f.init(1.5, 10.0, -2.0),
        .position = Vector3f.init(100.0, 64.0, -200.0),
        .motion = Vector2f.init(0.5, -0.25),
        .input_data = input_data,
        .input_mode = .Mouse,
        .play_mode = .Normal,
        .interaction_mode = .Crosshair,
        .interact_rotation = Vector2f.init(30.0, 40.0),
        .input_tick = 77,
        .position_delta = Vector3f.init(0.5, -0.5, 1.5),
        .item_transaction = null,
        .item_stack_request = null,
        .block_actions = undefined,
        .block_action_count = 2,
        .vehicle_rotation = Vector2f.init(12.0, 24.0),
        .client_predicted_vehicle = 12345,
        .analogue_motion = Vector2f.init(0.25, 0.75),
        .camera_orientation = Vector3f.init(1.0, 2.0, 3.0),
        .raw_move_vector = Vector2f.init(-1.0, 0.0),
    };
    packet.block_actions[0] = .{
        .action = .StartBreak,
        .block_pos = BlockPosition.init(10, 64, -20),
        .face = 1,
    };
    packet.block_actions[1] = .{
        .action = .CrackBreak,
        .block_pos = BlockPosition.init(-5, 63, 7),
        .face = 0,
    };
    return packet;
}

fn writeTestWire(w: *BinaryStream, vehicle_actor_present: bool) !void {
    try w.writeVarInt(Packet.PlayerAuthInput);
    try w.writeFloat32(1.5, .Little);
    try w.writeFloat32(10.0, .Little);
    try Vector3f.write(w, Vector3f.init(100.0, 64.0, -200.0));
    try Vector2f.write(w, Vector2f.init(0.5, -0.25));
    try w.writeFloat32(-2.0, .Little);
    try w.writeVarInt(4); // SneakDown(9), Up(10), PerformBlockActions(35), IsInClientPredictedVehicle(45)
    try w.writeZigZag(9);
    try w.writeZigZag(10);
    try w.writeZigZag(35);
    try w.writeZigZag(45);
    try w.writeVarInt(1); // input mode: mouse
    try w.writeVarInt(0); // play mode: normal
    try w.writeZigZag(1); // interaction mode: crosshair
    try Vector2f.write(w, Vector2f.init(30.0, 40.0));
    try w.writeVarLong(77);
    try Vector3f.write(w, Vector3f.init(0.5, -0.5, 1.5));
    try w.writeBool(false); // item interaction absent
    try w.writeBool(false); // item stack request absent
    try w.writeBool(true); // block actions present
    try w.writeVarInt(2);
    try PlayerBlockAction.write(w, .{
        .action = .StartBreak,
        .block_pos = BlockPosition.init(10, 64, -20),
        .face = 1,
    });
    try PlayerBlockAction.write(w, .{
        .action = .CrackBreak,
        .block_pos = BlockPosition.init(-5, 63, 7),
        .face = 0,
    });
    try w.writeBool(vehicle_actor_present);
    if (vehicle_actor_present) try Vector2f.write(w, Vector2f.init(12.0, 24.0));
    try w.writeBool(vehicle_actor_present);
    if (vehicle_actor_present) try w.writeZigZong(12345);
    try Vector2f.write(w, Vector2f.init(0.25, 0.75));
    try Vector3f.write(w, Vector3f.init(1.0, 2.0, 3.0));
    try Vector2f.write(w, Vector2f.init(-1.0, 0.0));
}

test "player auth input serializes in pmmp wire order" {
    var expected = BinaryStream.init(testing.allocator, null, null);
    defer expected.deinit();
    try writeTestWire(&expected, true);

    var out = BinaryStream.init(testing.allocator, null, null);
    defer out.deinit();
    var packet = buildTestPacket();
    const bytes = try packet.serialize(&out);

    try testing.expectEqualSlices(u8, expected.getBuffer(), bytes);
}

test "player auth input roundtrips every field" {
    var out = BinaryStream.init(testing.allocator, null, null);
    defer out.deinit();
    var packet = buildTestPacket();
    const bytes = try packet.serialize(&out);

    var in = BinaryStream.init(testing.allocator, bytes, 0);
    var parsed = try PlayerAuthInputPacket.deserialize(&in, testing.allocator);
    defer parsed.deinit(testing.allocator);

    try testing.expectEqual(Vector3f.init(1.5, 10.0, -2.0), parsed.rotation);
    try testing.expectEqual(Vector3f.init(100.0, 64.0, -200.0), parsed.position);
    try testing.expectEqual(Vector2f.init(0.5, -0.25), parsed.motion);
    try testing.expect(parsed.input_data.hasFlag(.Up));
    try testing.expect(parsed.input_data.hasFlag(.SneakDown));
    try testing.expect(parsed.input_data.hasFlag(.PerformBlockActions));
    try testing.expect(parsed.input_data.hasFlag(.IsInClientPredictedVehicle));
    try testing.expect(!parsed.input_data.hasFlag(.PerformItemInteraction));
    try testing.expectEqual(InputMode.Mouse, parsed.input_mode);
    try testing.expectEqual(PlayMode.Normal, parsed.play_mode);
    try testing.expectEqual(InteractionMode.Crosshair, parsed.interaction_mode);
    try testing.expectEqual(@as(u64, 77), parsed.input_tick);
    try testing.expectEqual(Vector3f.init(0.5, -0.5, 1.5), parsed.position_delta);
    try testing.expectEqual(@as(u32, 2), parsed.block_action_count);
    try testing.expectEqual(@as(@TypeOf(parsed.block_actions[1].action), .CrackBreak), parsed.block_actions[1].action);
    try testing.expectEqual(BlockPosition.init(-5, 63, 7), parsed.block_actions[1].block_pos);
    try testing.expectEqual(Vector2f.init(12.0, 24.0), parsed.vehicle_rotation);
    try testing.expectEqual(@as(i64, 12345), parsed.client_predicted_vehicle);
    try testing.expectEqual(Vector2f.init(0.25, 0.75), parsed.analogue_motion);
    try testing.expectEqual(Vector3f.init(1.0, 2.0, 3.0), parsed.camera_orientation);
    try testing.expectEqual(Vector2f.init(-1.0, 0.0), parsed.raw_move_vector);
    try testing.expect(parsed.item_transaction == null);
    try testing.expect(parsed.item_stack_request == null);
}

test "player auth input vehicle info is optional per field" {
    var wire = BinaryStream.init(testing.allocator, null, null);
    defer wire.deinit();
    try writeTestWire(&wire, false);

    var in = BinaryStream.init(testing.allocator, wire.getBuffer(), 0);
    var parsed = try PlayerAuthInputPacket.deserialize(&in, testing.allocator);
    defer parsed.deinit(testing.allocator);

    try testing.expectEqual(@as(i64, 0), parsed.client_predicted_vehicle);
    try testing.expectEqual(Vector2f.zero(), parsed.vehicle_rotation);
}

test "player auth input rejects unknown input mode" {
    var wire = BinaryStream.init(testing.allocator, null, null);
    defer wire.deinit();
    try wire.writeVarInt(Packet.PlayerAuthInput);
    try wire.writeFloat32(0, .Little);
    try wire.writeFloat32(0, .Little);
    try Vector3f.write(&wire, Vector3f.zero());
    try Vector2f.write(&wire, Vector2f.zero());
    try wire.writeFloat32(0, .Little);
    try wire.writeBool(true); // dummy
    try wire.writeVarInt(0); // no flags
    try wire.writeVarInt(99); // invalid input mode

    var in = BinaryStream.init(testing.allocator, wire.getBuffer(), 0);
    try testing.expectError(
        error.UnknownInputMode,
        PlayerAuthInputPacket.deserialize(&in, testing.allocator),
    );
}

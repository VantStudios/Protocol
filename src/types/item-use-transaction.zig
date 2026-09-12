const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const BlockPosition = @import("block-position.zig").BlockPosition;
const Vector3f = @import("vector3f.zig").Vector3f;
const NetworkItemStackDescriptor = @import("network-item-stack-descriptor.zig").NetworkItemStackDescriptor;

pub const ItemUseTransaction = struct {
    legacy_request_id: i32,
    action_type: i32,
    trigger_type: u32,
    block_position: BlockPosition,
    block_face: i32,
    hot_bar_slot: i32,
    item_in_hand: NetworkItemStackDescriptor,
    position: Vector3f,
    clicked_position: Vector3f,
    block_runtime_id: u32,
    client_prediction: u32,
    client_cooldown_state: u8 = 0,

    pub fn read(stream: *BinaryStream, allocator: std.mem.Allocator) !ItemUseTransaction {
        const legacy_request_id = try stream.readZigZag();

        if (try stream.readBool()) {
            if (legacy_request_id < -1 and (@as(u32, @bitCast(legacy_request_id)) & 1) == 0) {
                const slot_count = try stream.readVarInt();
                for (0..slot_count) |_| {
                    _ = try stream.readUint8();
                    const byte_count = try stream.readVarInt();
                    for (0..byte_count) |_| {
                        _ = try stream.readUint8();
                    }
                }
            }
        }

        if ((try stream.readBool()) and (try stream.readBool())) {
            const action_count = try stream.readVarInt();
            for (0..action_count) |_| {
                try skipInventoryAction(stream);
            }
        }

        const action_type = try stream.readZigZag();
        const trigger_type = try stream.readUint8();
        const block_position = try BlockPosition.read(stream);
        const block_face = try stream.readUint8();
        const hot_bar_slot = try stream.readZigZag();
        const item_in_hand = try NetworkItemStackDescriptor.readShort(stream, allocator);
        const position = try Vector3f.read(stream);
        const clicked_position = try Vector3f.read(stream);
        const block_runtime_id = try stream.readVarInt();
        const client_prediction = try stream.readUint8();
        const client_cooldown_state = try stream.readUint8();

        return .{
            .legacy_request_id = legacy_request_id,
            .action_type = action_type,
            .trigger_type = trigger_type,
            .block_position = block_position,
            .block_face = block_face,
            .hot_bar_slot = hot_bar_slot,
            .item_in_hand = item_in_hand,
            .position = position,
            .clicked_position = clicked_position,
            .block_runtime_id = block_runtime_id,
            .client_prediction = client_prediction,
            .client_cooldown_state = client_cooldown_state,
        };
    }

    pub fn write(self: ItemUseTransaction, stream: *BinaryStream, allocator: std.mem.Allocator) !void {
        try stream.writeZigZag(self.legacy_request_id);

        if (self.legacy_request_id < -1 and (@as(u32, @bitCast(self.legacy_request_id)) & 1) == 0) {
            try stream.writeBool(true);
            // Legacy changed-slots are not tracked in this struct; the client
            // re-derives them from its own inventory state.
            try stream.writeVarInt(0);
        } else {
            try stream.writeBool(false);
        }

        try stream.writeBool(true);
        try stream.writeBool(true);
        try stream.writeVarInt(0);

        try stream.writeZigZag(self.action_type);
        try stream.writeUint8(@intCast(self.trigger_type & 0xFF));
        try BlockPosition.write(stream, self.block_position);
        try stream.writeUint8(@intCast(self.block_face & 0xFF));
        try stream.writeZigZag(self.hot_bar_slot);
        try NetworkItemStackDescriptor.writeShort(stream, self.item_in_hand, allocator);
        try Vector3f.write(stream, self.position);
        try Vector3f.write(stream, self.clicked_position);
        try stream.writeVarInt(self.block_runtime_id);
        try stream.writeUint8(@intCast(self.client_prediction & 0xFF));
        try stream.writeUint8(self.client_cooldown_state);
    }

    pub fn deinit(self: *ItemUseTransaction, allocator: std.mem.Allocator) void {
        self.item_in_hand.deinit(allocator);
    }
};

fn skipInventoryAction(stream: *BinaryStream) !void {
    _ = try stream.readVarInt();
    if (try stream.readBool()) {
        if (try stream.readBool()) {
            _ = try stream.readUint8();
        }
    }
    if (try stream.readBool()) {
        if (try stream.readBool()) {
            _ = try stream.readVarInt();
        }
    }
    _ = try stream.readVarInt();
    try NetworkItemStackDescriptor.skipShort(stream);
    try NetworkItemStackDescriptor.skipShort(stream);
}

const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

pub const TransactionType = @import("../enums/transaction-type.zig").TransactionType;
const Packet = @import("../root.zig").Packet;
const BlockPosition = @import("../types/block-position.zig").BlockPosition;
const TransactionTypes = @import("../types/inventory-transaction-data.zig");
pub const TransactionData = TransactionTypes.TransactionData;
pub const NormalTransactionData = TransactionTypes.NormalTransactionData;
pub const UseItemTransactionData = TransactionTypes.UseItemTransactionData;
pub const UseItemOnEntityTransactionData = TransactionTypes.UseItemOnEntityTransactionData;
pub const ReleaseItemTransactionData = TransactionTypes.ReleaseItemTransactionData;
pub const InventoryAction = TransactionTypes.InventoryAction;
pub const LegacySetItemSlot = TransactionTypes.LegacySetItemSlot;
const NetworkItemStackDescriptor = @import("../types/network-item-stack-descriptor.zig").NetworkItemStackDescriptor;
const Vector3f = @import("../types/vector3f.zig").Vector3f;

pub const InventoryTransactionPacket = struct {
    legacy_request_id: i32,
    transaction_type: TransactionType,
    action_count: u32,
    transaction_data: TransactionData,

    pub fn deserialize(stream: *BinaryStream) !InventoryTransactionPacket {
        _ = try stream.readVarInt();

        const legacy_request_id = try stream.readZigZag();

        const has_changed_slots = try stream.readBool();
        if (has_changed_slots) {
            const slot_count = try stream.readVarInt();
            for (0..slot_count) |_| {
                _ = try stream.readUint8();
                const byte_count = try stream.readVarInt();
                for (0..byte_count) |_| {
                    _ = try stream.readUint8();
                }
            }
        }

        const has_transaction_type = try stream.readBool();
        if (!has_transaction_type) return error.InvalidPacket;

        const transaction_type_raw = try stream.readVarInt();
        const transaction_type: TransactionType = std.enums.fromInt(TransactionType, transaction_type_raw) orelse return error.InvalidTransactionType;

        const transaction_data_has_value = try stream.readBool();
        if (!transaction_data_has_value) return error.InvalidPacket;

        const action_count = try stream.readVarInt();
        var normal_data = NormalTransactionData{};
        for (0..action_count) |_| {
            if (transaction_type == .Normal) {
                try readNormalAction(stream, &normal_data);
            } else {
                try skipInventoryAction(stream);
            }
        }

        const transaction_data: TransactionData = switch (transaction_type) {
            .Normal => .{ .normal = normal_data },
            .Mismatch => .{ .mismatch = {} },
            .UseItem => .{ .use_item = try readUseItem(stream) },
            .UseItemOnEntity => .{ .use_item_on_entity = try readUseItemOnEntity(stream) },
            .ReleaseItem => .{ .release_item = try readReleaseItem(stream) },
        };

        return .{
            .legacy_request_id = legacy_request_id,
            .transaction_type = transaction_type,
            .action_count = action_count,
            .transaction_data = transaction_data,
        };
    }
};

fn readUseItem(stream: *BinaryStream) !UseItemTransactionData {
    const action_type = try stream.readVarInt();
    const trigger_type = try stream.readUint8();
    const block_position = try BlockPosition.read(stream);
    const block_face = try stream.readByte();
    const hot_bar_slot = try stream.readZigZag();
    try NetworkItemStackDescriptor.skipShort(stream);
    const position = try Vector3f.read(stream);
    const clicked_position = try Vector3f.read(stream);
    const block_runtime_id = try stream.readVarInt();
    const client_prediction = try stream.readVarInt();
    const client_cooldown_state = try stream.readVarInt();

    return .{
        .action_type = action_type,
        .trigger_type = trigger_type,
        .block_position = block_position,
        .block_face = block_face,
        .hot_bar_slot = hot_bar_slot,
        .position = position,
        .clicked_position = clicked_position,
        .block_runtime_id = block_runtime_id,
        .client_prediction = client_prediction,
        .client_cooldown_state = client_cooldown_state,
    };
}

fn readUseItemOnEntity(stream: *BinaryStream) !UseItemOnEntityTransactionData {
    const target_entity_runtime_id = try stream.readVarLong();
    const action_type = try stream.readVarInt();
    const hot_bar_slot = try stream.readZigZag();
    try NetworkItemStackDescriptor.skipShort(stream);
    const position = try Vector3f.read(stream);
    const clicked_position = try Vector3f.read(stream);

    return .{
        .target_entity_runtime_id = target_entity_runtime_id,
        .action_type = action_type,
        .hot_bar_slot = hot_bar_slot,
        .position = position,
        .clicked_position = clicked_position,
    };
}

fn readReleaseItem(stream: *BinaryStream) !ReleaseItemTransactionData {
    const action_type = try stream.readVarInt();
    const hot_bar_slot = try stream.readZigZag();
    try NetworkItemStackDescriptor.skipShort(stream);
    const head_position = try Vector3f.read(stream);

    return .{
        .action_type = action_type,
        .hot_bar_slot = hot_bar_slot,
        .head_position = head_position,
    };
}

fn readNormalAction(stream: *BinaryStream, data: *NormalTransactionData) !void {
    const source_type = try stream.readVarInt();
    switch (source_type) {
        0, 99999 => _ = try stream.readZigZag(),
        2 => _ = try stream.readVarInt(),
        else => {},
    }
    const slot = try stream.readVarInt();

    try NetworkItemStackDescriptor.skipShort(stream);

    _ = try stream.readZigZag();
    const new_count = try stream.readUint16(.Little);
    _ = try stream.readVarInt();
    if (try stream.readBool()) _ = try stream.readZigZag();
    _ = try stream.readZigZag();
    const extra_len = try stream.readVarInt();
    for (0..extra_len) |_| _ = try stream.readUint8();

    if (source_type == 0) {
        data.drop_slot = slot;
    } else if (source_type == 2) {
        data.is_drop = true;
        data.drop_count = new_count;
    }
}

fn skipInventoryAction(stream: *BinaryStream) !void {
    const source_type = try stream.readVarInt();
    switch (source_type) {
        0, 99999 => _ = try stream.readZigZag(),
        2 => _ = try stream.readVarInt(),
        else => {},
    }
    _ = try stream.readVarInt();
    try NetworkItemStackDescriptor.skipShort(stream);
    try NetworkItemStackDescriptor.skipShort(stream);
}

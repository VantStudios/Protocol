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
    legacyRequestId: i32,
    transactionType: TransactionType,
    actionCount: u32,
    transactionData: TransactionData,

    pub fn deserialize(stream: *BinaryStream) !InventoryTransactionPacket {
        _ = try stream.readVarInt();

        const legacyRequestId = try stream.readZigZag();

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
        const transactionType: TransactionType = std.enums.fromInt(TransactionType, transaction_type_raw) orelse return error.InvalidTransactionType;

        const transaction_data_has_value = try stream.readBool();
        if (!transaction_data_has_value) return error.InvalidPacket;

        const actionCount = try stream.readVarInt();
        var normal_data = NormalTransactionData{};
        for (0..actionCount) |_| {
            if (transactionType == .Normal) {
                try readNormalAction(stream, &normal_data);
            } else {
                try skipInventoryAction(stream);
            }
        }

        const transactionData: TransactionData = switch (transactionType) {
            .Normal => .{ .normal = normal_data },
            .Mismatch => .{ .mismatch = {} },
            .UseItem => .{ .useItem = try readUseItem(stream) },
            .UseItemOnEntity => .{ .useItemOnEntity = try readUseItemOnEntity(stream) },
            .ReleaseItem => .{ .releaseItem = try readReleaseItem(stream) },
        };

        return .{
            .legacyRequestId = legacyRequestId,
            .transactionType = transactionType,
            .actionCount = actionCount,
            .transactionData = transactionData,
        };
    }
};

fn readUseItem(stream: *BinaryStream) !UseItemTransactionData {
    const actionType = try stream.readVarInt();
    const triggerType = try stream.readUint8();
    const blockPosition = try BlockPosition.read(stream);
    const blockFace = try stream.readByte();
    const hotBarSlot = try stream.readZigZag();
    try NetworkItemStackDescriptor.skipShort(stream);
    const position = try Vector3f.read(stream);
    const clickedPosition = try Vector3f.read(stream);
    const blockRuntimeId = try stream.readVarInt();
    const clientPrediction = try stream.readVarInt();
    const client_cooldown_state = try stream.readVarInt();

    return .{
        .actionType = actionType,
        .triggerType = triggerType,
        .blockPosition = blockPosition,
        .blockFace = blockFace,
        .hotBarSlot = hotBarSlot,
        .position = position,
        .clickedPosition = clickedPosition,
        .blockRuntimeId = blockRuntimeId,
        .clientPrediction = clientPrediction,
        .client_cooldown_state = client_cooldown_state,
    };
}

fn readUseItemOnEntity(stream: *BinaryStream) !UseItemOnEntityTransactionData {
    const targetEntityRuntimeId = try stream.readVarLong();
    const actionType = try stream.readVarInt();
    const hotBarSlot = try stream.readZigZag();
    try NetworkItemStackDescriptor.skipShort(stream);
    const position = try Vector3f.read(stream);
    const clickedPosition = try Vector3f.read(stream);

    return .{
        .targetEntityRuntimeId = targetEntityRuntimeId,
        .actionType = actionType,
        .hotBarSlot = hotBarSlot,
        .position = position,
        .clickedPosition = clickedPosition,
    };
}

fn readReleaseItem(stream: *BinaryStream) !ReleaseItemTransactionData {
    const actionType = try stream.readVarInt();
    const hotBarSlot = try stream.readZigZag();
    try NetworkItemStackDescriptor.skipShort(stream);
    const headPosition = try Vector3f.read(stream);

    return .{
        .actionType = actionType,
        .hotBarSlot = hotBarSlot,
        .headPosition = headPosition,
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

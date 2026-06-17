const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;
const NBT = @import("nbt");

const ContainerId = @import("../enums/container-id.zig").ContainerId;
const ContainerType = @import("../enums/container-type.zig").ContainerType;
const Packet = @import("../root.zig").Packet;

pub const UpdateTradePacket = struct {
    identifier: ContainerId,
    container_type: ContainerType,
    size: u32,
    trade_tier: u32,
    villager_unique_id: i64,
    entity_unique_id: i64,
    display_name: []const u8,
    new_trade_ui: bool,
    demand_based_price: bool,
    offers: NBT.Tag,

    pub fn serialize(self: *UpdateTradePacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.UpdateTrade);
        try stream.writeUint8(@bitCast(@intFromEnum(self.identifier)));
        try stream.writeUint8(@bitCast(@intFromEnum(self.container_type)));
        try stream.writeVarInt(self.size);
        try stream.writeVarInt(self.trade_tier);
        try stream.writeZigZong(self.villager_unique_id);
        try stream.writeZigZong(self.entity_unique_id);
        try stream.writeVarString(self.display_name);
        try stream.writeBool(self.new_trade_ui);
        try stream.writeBool(self.demand_based_price);
        try self.offers.write(stream, .{ .varint = true });

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !UpdateTradePacket {
        _ = try stream.readVarInt();
        const identifier_raw = try stream.readInt8();
        const container_type_raw = try stream.readInt8();
        const size = try stream.readVarInt();
        const trade_tier = try stream.readVarInt();
        const villager_unique_id = try stream.readZigZong();
        const entity_unique_id = try stream.readZigZong();
        const display_name = try stream.readVarString();
        const new_trade_ui = try stream.readBool();
        const demand_based_price = try stream.readBool();
        const offers = try NBT.Tag.read(stream, stream.allocator, .{ .varint = true });

        return .{
            .identifier = std.enums.fromInt(ContainerId, identifier_raw) catch return error.UnknownContainerId,
            .container_type = std.enums.fromInt(ContainerType, container_type_raw) catch return error.UnknownContainerType,
            .size = size,
            .trade_tier = trade_tier,
            .villager_unique_id = villager_unique_id,
            .entity_unique_id = entity_unique_id,
            .display_name = display_name,
            .new_trade_ui = new_trade_ui,
            .demand_based_price = demand_based_price,
            .offers = offers,
        };
    }

    pub fn deinit(self: *UpdateTradePacket, allocator: std.mem.Allocator) void {
        self.offers.deinit(allocator);
    }
};

const BinaryStream = @import("BinaryStream").BinaryStream;

pub const StackResponseSlotInfo = struct {
    slot: u8,
    hotbar_slot: u8,
    count: u8,
    stack_network_id: i32,
    custom_name: []const u8,
    filtered_custom_name: []const u8,
    durability_correction: i32,

    pub fn write(stream: *BinaryStream, value: StackResponseSlotInfo) !void {
        try stream.writeUint8(value.slot);
        try stream.writeUint8(value.hotbar_slot);
        try stream.writeUint8(value.count);
        try stream.writeZigZag(value.stack_network_id);
        try stream.writeVarString(value.custom_name);
        try stream.writeVarString(value.filtered_custom_name);
        try stream.writeZigZag(value.durability_correction);
    }
};

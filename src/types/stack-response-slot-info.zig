const BinaryStream = @import("BinaryStream").BinaryStream;

pub const StackResponseSlotInfo = struct {
    slot: u8,
    hotbar_slot: u8,
    count: u8,
    stack_network_id: i32,
    custom_name: []const u8,
    filtered_custom_name: ?[]const u8,
    durability_correction: i32,

    pub fn write(stream: *BinaryStream, value: StackResponseSlotInfo) !void {
        try stream.writeUint8(value.slot);
        try stream.writeUint8(value.hotbar_slot);
        try stream.writeUint8(value.count);
        try stream.writeBool(true);
        try stream.writeBool(value.stack_network_id > 0);
        if (value.stack_network_id > 0) {
            try stream.writeZigZag(value.stack_network_id);
        }
        try stream.writeVarString(value.custom_name);
        try stream.writeBool(value.filtered_custom_name != null);
        if (value.filtered_custom_name) |filtered_custom_name| {
            try stream.writeVarString(filtered_custom_name);
        }
        try stream.writeZigZag(value.durability_correction);
    }

    pub fn read(stream: *BinaryStream) !StackResponseSlotInfo {
        const slot = try stream.readUint8();
        const hotbar_slot = try stream.readUint8();
        const count = try stream.readUint8();
        var stack_network_id: i32 = 0;
        if (try stream.readBool()) {
            if (try stream.readBool()) {
                stack_network_id = try stream.readZigZag();
            }
        }
        const custom_name = try stream.readVarString();
        var filtered_custom_name: ?[]const u8 = null;
        if (try stream.readBool()) {
            filtered_custom_name = try stream.readVarString();
        }
        const durability_correction = try stream.readZigZag();

        return .{
            .slot = slot,
            .hotbar_slot = hotbar_slot,
            .count = count,
            .stack_network_id = stack_network_id,
            .custom_name = custom_name,
            .filtered_custom_name = filtered_custom_name,
            .durability_correction = durability_correction,
        };
    }
};

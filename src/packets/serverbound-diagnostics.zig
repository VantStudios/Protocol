const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../enums/packet.zig").Packet;

pub const SystemCategory = struct {
    category_name: []const u8 = "",
    system_index: i64 = 0,

    pub fn write(stream: *BinaryStream, value: SystemCategory) !void {
        try stream.writeVarString(value.category_name);
        try stream.writeInt64(value.system_index, .Little);
    }
};

pub const WhiskerScopeDataSummary = struct {
    label: []const u8 = "",
    indentation: []const u8 = "",
    total_high_cost_ns: i64 = 0,
    total_mid_cost_ns: i64 = 0,
    total_low_cost_ns: i64 = 0,

    pub fn write(stream: *BinaryStream, value: WhiskerScopeDataSummary) !void {
        try stream.writeVarString(value.label);
        try stream.writeVarString(value.indentation);
        try stream.writeInt64(value.total_high_cost_ns, .Little);
        try stream.writeInt64(value.total_mid_cost_ns, .Little);
        try stream.writeInt64(value.total_low_cost_ns, .Little);
    }
};

pub const ServerboundDiagnosticsPacket = struct {
    system_categories: []const SystemCategory = &.{},
    whisker_scopes: []const WhiskerScopeDataSummary = &.{},

    pub fn serialize(self: *const ServerboundDiagnosticsPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.ServerboundDiagnosticPacket);

        try stream.writeVarInt(@intCast(self.system_categories.len));
        for (self.system_categories) |sc| {
            try SystemCategory.write(stream, sc);
        }
        try stream.writeVarInt(@intCast(self.whisker_scopes.len));
        for (self.whisker_scopes) |ws| {
            try WhiskerScopeDataSummary.write(stream, ws);
        }
        return stream.getBuffer();
    }
};

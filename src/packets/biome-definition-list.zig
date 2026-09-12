const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;

pub const BiomeDefinition = struct {
    name: []const u8,
    id: u16,
    temperature: f32,
    downfall: f32,
    foliage_snow: f32,
    depth: f32,
    scale: f32,
    water_color: i32,
    can_precipitate: bool,
    tags: []const []const u8 = &.{},
};

pub const BiomeDefinitionListPacket = struct {
    definitions: []const BiomeDefinition,

    pub fn serialize(self: *const BiomeDefinitionListPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.BiomeDefinitionList);

        const allocator = stream.allocator;
        var strings = std.ArrayList([]const u8){ .items = &.{}, .capacity = 0 };
        defer strings.deinit(allocator);

        for (self.definitions) |definition| {
            _ = try internString(allocator, &strings, definition.name);
            for (definition.tags) |tag| {
                _ = try internString(allocator, &strings, tag);
            }
        }

        try stream.writeVarInt(@intCast(self.definitions.len));
        for (self.definitions) |definition| {
            try stream.writeUint16(@intCast(try internString(allocator, &strings, definition.name)), .Little);
            try stream.writeUint16(definition.id, .Little);
            try stream.writeFloat32(definition.temperature, .Little);
            try stream.writeFloat32(definition.downfall, .Little);
            try stream.writeFloat32(definition.foliage_snow, .Little);
            try stream.writeFloat32(definition.depth, .Little);
            try stream.writeFloat32(definition.scale, .Little);
            try stream.writeUint32(@bitCast(definition.water_color), .Little);
            try stream.writeBool(definition.can_precipitate);

            try stream.writeBool(true);
            try stream.writeVarInt(@intCast(definition.tags.len));
            for (definition.tags) |tag| {
                try stream.writeUint16(@intCast(try internString(allocator, &strings, tag)), .Little);
            }

            try stream.writeBool(false);
        }

        try stream.writeVarInt(@intCast(strings.items.len));
        for (strings.items) |string| {
            try stream.writeVarInt(@intCast(string.len));
            try stream.write(string);
        }

        return stream.getBuffer();
    }

    pub fn deinit(self: *const BiomeDefinitionListPacket, allocator: std.mem.Allocator) void {
        _ = self;
        _ = allocator;
    }
};

fn internString(allocator: std.mem.Allocator, strings: *std.ArrayList([]const u8), string: []const u8) !usize {
    for (strings.items, 0..) |existing, i| {
        if (std.mem.eql(u8, existing, string)) return i;
    }
    try strings.append(allocator, string);
    return strings.items.len - 1;
}

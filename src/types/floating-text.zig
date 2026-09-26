const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const ActorDataId = @import("../enums/actor-data-id.zig").ActorDataId;
const ActorFlags = @import("../enums/actor-flags.zig").ActorFlags;
const AddEntityPacket = @import("../packets/add-entity.zig").AddEntityPacket;
const RemoveEntityPacket = @import("../packets/remove-entity.zig").RemoveEntityPacket;
const DataItem = @import("./data-item.zig").DataItem;
const Packet = @import("../enums/packet.zig").Packet;
const PropertySyncData = @import("./property-sync-data.zig").PropertySyncData;
const Vector3f = @import("./vector3f.zig").Vector3f;

pub const FloatingText = struct {
    pub const entity_type: []const u8 = "minecraft:falling_block";
    pub const entity_flags: i64 = @as(i64, 1) << @intFromEnum(ActorFlags.NoAI);
    pub const scale: f32 = 0.01;
    pub const bounding_box_width: f32 = 0.0;
    pub const bounding_box_height: f32 = 0.0;
    pub const always_show_nametag: i8 = 1;
    pub const metadata_count: usize = 7;

    pub fn decodeEscapes(allocator: std.mem.Allocator, text: []const u8) ![]u8 {
        var decoded: std.ArrayList(u8) = .empty;
        errdefer decoded.deinit(allocator);
        try decoded.ensureTotalCapacity(allocator, text.len);

        var index: usize = 0;
        while (index < text.len) {
            const byte = text[index];
            if (byte == '\\' and index + 1 < text.len) {
                const escaped = text[index + 1];
                if (escaped == 'n') {
                    try decoded.append(allocator, '\n');
                    index += 2;
                    continue;
                }
                if (escaped == '\\') {
                    try decoded.append(allocator, '\\');
                    index += 2;
                    continue;
                }
            }
            try decoded.append(allocator, byte);
            index += 1;
        }

        return decoded.toOwnedSlice(allocator);
    }

    pub fn composeNameTag(allocator: std.mem.Allocator, title: []const u8, text: []const u8) ![]u8 {
        if (title.len == 0) return allocator.dupe(u8, text);
        if (text.len == 0) return allocator.dupe(u8, title);
        return std.fmt.allocPrint(allocator, "{s}\n{s}", .{ title, text });
    }

    pub fn buildMetadata(allocator: std.mem.Allocator, name_tag: []const u8, block_runtime_id: i32) ![]DataItem {
        const metadata = try allocator.alloc(DataItem, metadata_count);
        metadata[0] = DataItem.init(ActorDataId.Flags, .Long, .{ .Long = entity_flags });
        metadata[1] = DataItem.initFloat(ActorDataId.Scale, scale);
        metadata[2] = DataItem.initFloat(ActorDataId.Width, bounding_box_width);
        metadata[3] = DataItem.initFloat(ActorDataId.Height, bounding_box_height);
        metadata[4] = DataItem.init(ActorDataId.Name, .String, .{ .String = name_tag });
        metadata[5] = DataItem.initInt(ActorDataId.Variant, block_runtime_id);
        metadata[6] = DataItem.initByte(ActorDataId.AlwaysShowNameTag, always_show_nametag);
        return metadata;
    }

    pub fn encodeAdd(
        allocator: std.mem.Allocator,
        unique_entity_id: i64,
        runtime_entity_id: i64,
        position: Vector3f,
        name_tag: []const u8,
        block_runtime_id: i32,
    ) ![]const u8 {
        const metadata = try buildMetadata(allocator, name_tag, block_runtime_id);
        defer allocator.free(metadata);

        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();

        const packet = AddEntityPacket{
            .unique_entity_id = unique_entity_id,
            .runtime_entity_id = @bitCast(runtime_entity_id),
            .entity_type = entity_type,
            .position = position,
            .entity_metadata = metadata,
            .entity_properties = PropertySyncData.init(allocator),
        };
        const serialized = try packet.serialize(&stream);
        return allocator.dupe(u8, serialized);
    }

    pub fn encodeRemove(allocator: std.mem.Allocator, unique_entity_id: i64) ![]const u8 {
        var stream = BinaryStream.init(allocator, null, null);
        defer stream.deinit();

        const packet = RemoveEntityPacket{ .unique_entity_id = unique_entity_id };
        const serialized = try packet.serialize(&stream);
        return allocator.dupe(u8, serialized);
    }

    pub fn encodeUpdate(
        allocator: std.mem.Allocator,
        unique_entity_id: i64,
        runtime_entity_id: i64,
        position: Vector3f,
        name_tag: []const u8,
        block_runtime_id: i32,
    ) ![]const u8 {
        const remove = try encodeRemove(allocator, unique_entity_id);
        defer allocator.free(remove);
        const add = try encodeAdd(allocator, unique_entity_id, runtime_entity_id, position, name_tag, block_runtime_id);
        defer allocator.free(add);

        const buffer = try allocator.alloc(u8, remove.len + add.len);
        @memcpy(buffer[0..remove.len], remove);
        @memcpy(buffer[remove.len..], add);
        return buffer;
    }
};

test "decodeEscapes turns literal backslash n into line breaks" {
    const allocator = std.testing.allocator;

    const decoded = try FloatingText.decodeEscapes(allocator, "Linea 1\\nLinea 2");
    defer allocator.free(decoded);
    try std.testing.expectEqualStrings("Linea 1\nLinea 2", decoded);

    const literal = try FloatingText.decodeEscapes(allocator, "\\\\n");
    defer allocator.free(literal);
    try std.testing.expectEqualStrings("\\n", literal);

    const plain = try FloatingText.decodeEscapes(allocator, "\xc2\xa77Hola\\");
    defer allocator.free(plain);
    try std.testing.expectEqualStrings("\xc2\xa77Hola\\", plain);
}

test "composeNameTag keeps title and text on separate lines" {
    const allocator = std.testing.allocator;

    const both = try FloatingText.composeNameTag(allocator, "Title", "Body");
    defer allocator.free(both);
    try std.testing.expectEqualStrings("Title\nBody", both);

    const only_text = try FloatingText.composeNameTag(allocator, "", "Body");
    defer allocator.free(only_text);
    try std.testing.expectEqualStrings("Body", only_text);

    const only_title = try FloatingText.composeNameTag(allocator, "Title", "");
    defer allocator.free(only_title);
    try std.testing.expectEqualStrings("Title", only_title);
}

test "buildMetadata carries the falling block hologram fields" {
    const allocator = std.testing.allocator;

    const metadata = try FloatingText.buildMetadata(allocator, "\xc2\xa7aHola\nLinea", 7);
    defer allocator.free(metadata);

    try std.testing.expectEqual(FloatingText.metadata_count, metadata.len);
    try std.testing.expectEqual(ActorDataId.Flags, metadata[0].id);
    try std.testing.expectEqual(FloatingText.entity_flags, metadata[0].value.Long);
    try std.testing.expectEqual(FloatingText.scale, metadata[1].value.Float);
    try std.testing.expectEqual(FloatingText.bounding_box_width, metadata[2].value.Float);
    try std.testing.expectEqual(FloatingText.bounding_box_height, metadata[3].value.Float);
    try std.testing.expectEqualStrings("\xc2\xa7aHola\nLinea", metadata[4].value.String);
    try std.testing.expectEqual(@as(i32, 7), metadata[5].value.Int);
    try std.testing.expectEqual(FloatingText.always_show_nametag, metadata[6].value.Byte);
}

test "encodeAdd and encodeRemove write actor packets" {
    const allocator = std.testing.allocator;

    const add = try FloatingText.encodeAdd(allocator, 5, 5, Vector3f.init(1, 2, 3), "Hola", 0);
    defer allocator.free(add);
    try std.testing.expectEqual(@as(u8, @intCast(Packet.AddEntity)), add[0]);

    const remove = try FloatingText.encodeRemove(allocator, 5);
    defer allocator.free(remove);
    try std.testing.expectEqual(@as(u8, @intCast(Packet.RemoveActor)), remove[0]);

    const update = try FloatingText.encodeUpdate(allocator, 5, 5, Vector3f.init(1, 2, 3), "Hola", 0);
    defer allocator.free(update);
    try std.testing.expectEqual(remove.len + add.len, update.len);
    try std.testing.expectEqual(@as(u8, @intCast(Packet.RemoveActor)), update[0]);
    try std.testing.expectEqual(@as(u8, @intCast(Packet.AddEntity)), update[remove.len]);
}

const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const BiomeDefinitionListPacket = @import("../packets/biome-definition-list.zig").BiomeDefinitionListPacket;
const BiomeDefinition = @import("../packets/biome-definition-list.zig").BiomeDefinition;
const vanilla_json = @import("root.zig").biome_definitions_vanilla_json;

/// Builds a serialized BiomeDefinitionListPacket from the embedded vanilla
/// biome definitions. The returned bytes are owned by the caller.
pub fn loadVanillaSerialized(allocator: std.mem.Allocator) ![]const u8 {
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, vanilla_json, .{});
    defer parsed.deinit();
    const root = switch (parsed.value) {
        .object => |object| object,
        else => return error.InvalidBiomeJson,
    };

    var definitions = try std.ArrayList(BiomeDefinition).initCapacity(allocator, root.count());
    defer definitions.deinit(allocator);
    var tags_arena = std.heap.ArenaAllocator.init(allocator);
    defer tags_arena.deinit();

    var iterator = root.iterator();
    while (iterator.next()) |entry| {
        const name = entry.key_ptr.*;
        const object = switch (entry.value_ptr.*) {
            .object => |object| object,
            else => return error.InvalidBiomeJson,
        };

        var tags: []const []const u8 = &.{};
        if (object.get("tags")) |tags_value| {
            switch (tags_value) {
                .array => |array| {
                    const tag_list = try tags_arena.allocator().alloc([]const u8, array.items.len);
                    for (array.items, 0..) |item, i| {
                        tag_list[i] = switch (item) {
                            .string => |string| string,
                            else => "",
                        };
                    }
                    tags = tag_list;
                },
                else => {},
            }
        }

        try definitions.append(allocator, .{
            .name = name,
            .id = @intCast(getInt(object.get("id"), 65535)),
            .temperature = getFloat(object.get("temperature")),
            .downfall = getFloat(object.get("downfall")),
            .foliage_snow = getFloat(object.get("foliageSnow")),
            .depth = getFloat(object.get("depth")),
            .scale = getFloat(object.get("scale")),
            .water_color = waterColorArgb(object.get("mapWaterColour")),
            .can_precipitate = getBool(object.get("rain")),
            .tags = tags,
        });
    }

    var stream = BinaryStream.init(allocator, null, null);
    defer stream.deinit();
    const packet = BiomeDefinitionListPacket{ .definitions = definitions.items };
    const raw = try packet.serialize(&stream);
    return allocator.dupe(u8, raw);
}

fn getFloat(value: ?std.json.Value) f32 {
    const unwrapped = value orelse return 0;
    return switch (unwrapped) {
        .float => |f| @floatCast(f),
        .integer => |i| @floatFromInt(i),
        else => 0,
    };
}

fn getInt(value: ?std.json.Value, default: i64) i64 {
    const unwrapped = value orelse return default;
    return switch (unwrapped) {
        .integer => |i| i,
        .float => |f| @intFromFloat(f),
        else => default,
    };
}

fn getBool(value: ?std.json.Value) bool {
    const unwrapped = value orelse return false;
    return switch (unwrapped) {
        .bool => |b| b,
        else => false,
    };
}

/// mapWaterColour {a, b, g, r} into ARGB: (a << 24) | (r << 16) | (g << 8) | b.
fn waterColorArgb(value: ?std.json.Value) i32 {
    const object = switch (value orelse return 0) {
        .object => |object| object,
        else => return 0,
    };
    const a: u32 = @intCast(getInt(object.get("a"), 255) & 0xff);
    const r: u32 = @intCast(getInt(object.get("r"), 0) & 0xff);
    const g: u32 = @intCast(getInt(object.get("g"), 0) & 0xff);
    const b: u32 = @intCast(getInt(object.get("b"), 0) & 0xff);
    return @bitCast((a << 24) | (r << 16) | (g << 8) | b);
}

const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const NBT = @import("nbt");
const root = @import("root.zig");
const NetworkBlockTypeDefinition = @import("../types/network-block-type-definition.zig").NetworkBlockTypeDefinition;
const SerializableVoxelShape = @import("../types/serializable-voxel-shape.zig").SerializableVoxelShape;
const SerializableCells = @import("../types/serializable-cells.zig").SerializableCells;
const VoxelShapeNameEntry = @import("../packets/voxel-shapes.zig").VoxelShapeNameEntry;

pub const PreSpawnData = struct {
    jigsaw_nbt: []const u8,
    block_palette: []NetworkBlockTypeDefinition,
    block_palette_nbt: []NBT.Tag,
    voxel_shapes: []SerializableVoxelShape,
    voxel_shape_cells: [][]u8,
    voxel_shape_xs: [][]f32,
    voxel_shape_ys: [][]f32,
    voxel_shape_zs: [][]f32,
    voxel_name_map: []VoxelShapeNameEntry,
    arena: std.heap.ArenaAllocator,

    pub fn deinit(self: *PreSpawnData) void {
        self.arena.deinit();
    }
};

pub fn load(allocator: std.mem.Allocator) !PreSpawnData {
    var arena = std.heap.ArenaAllocator.init(allocator);
    errdefer arena.deinit();
    const a = arena.allocator();

    var jigsaw_stream = BinaryStream.init(allocator, root.jigsaw_structures_data_nbt, null);
    defer jigsaw_stream.deinit();
    const jigsaw_tag = try NBT.Tag.read(&jigsaw_stream, a, .{ .varint = true });
    var jigsaw_output = BinaryStream.init(a, null, null);
    try jigsaw_tag.write(&jigsaw_output, .{ .varint = true });
    const jigsaw_nbt = jigsaw_output.getBuffer();

    var block_palette_list = std.ArrayList(NetworkBlockTypeDefinition){ .items = &.{}, .capacity = 0 };
    var block_palette_nbt_list = std.ArrayList(NBT.Tag){ .items = &.{}, .capacity = 0 };

    {
        var stream = BinaryStream.init(allocator, root.data_driven_blocks_nbt, null);
        defer stream.deinit();
        const parsed = try NBT.Tag.read(&stream, a, .{ .varint = true });
        const root_compound = switch (parsed) {
            .Compound => |compound| compound,
            else => return error.InvalidDataDrivenBlocksNbt,
        };
        const palette_tag = root_compound.get("blockPalette") orelse return error.MissingBlockPalette;
        const palette_list = switch (palette_tag) {
            .List => |list| list,
            else => return error.InvalidBlockPalette,
        };
        for (palette_list.value) |entry_tag| {
            const entry = switch (entry_tag) {
                .Compound => |compound| compound,
                else => return error.InvalidBlockPaletteEntry,
            };
            const name_tag = entry.get("name") orelse return error.MissingBlockName;
            const name = switch (name_tag) {
                .String => |string| string.value,
                else => return error.InvalidBlockName,
            };
            const states_tag = entry.get("states") orelse return error.MissingBlockStates;
            switch (states_tag) {
                .Compound => {},
                else => return error.InvalidBlockStates,
            }

            try block_palette_nbt_list.append(a, states_tag);
            try block_palette_list.append(a, .{
                .identifier = name,
                .nbt = states_tag,
            });
        }
    }

    var voxel_shapes_list = std.ArrayList(SerializableVoxelShape){ .items = &.{}, .capacity = 0 };
    var voxel_shape_cells = std.ArrayList([]u8){ .items = &.{}, .capacity = 0 };
    var voxel_shape_xs = std.ArrayList([]f32){ .items = &.{}, .capacity = 0 };
    var voxel_shape_ys = std.ArrayList([]f32){ .items = &.{}, .capacity = 0 };
    var voxel_shape_zs = std.ArrayList([]f32){ .items = &.{}, .capacity = 0 };
    var voxel_name_map = std.ArrayList(VoxelShapeNameEntry){ .items = &.{}, .capacity = 0 };

    {
        const parsed = try std.json.parseFromSlice(std.json.Value, a, root.voxel_shapes_json, .{});
        const parsed_object = switch (parsed.value) {
            .object => |object| object,
            else => return error.InvalidVoxelShapesJson,
        };

        if (parsed_object.get("nameMap")) |name_map_value| {
            switch (name_map_value) {
                .object => |name_map| {
                    var it = name_map.iterator();
                    while (it.next()) |entry| {
                        const handle: i16 = switch (entry.value_ptr.*) {
                            .integer => |value| @intCast(value),
                            else => 0,
                        };
                        try voxel_name_map.append(a, .{
                            .name = entry.key_ptr.*,
                            .handle = handle,
                        });
                    }
                },
                else => {},
            }
        }

        if (parsed_object.get("shapes")) |shapes_value| {
            switch (shapes_value) {
                .array => |shapes| {
                    for (shapes.items) |shape_value| {
                        const shape = switch (shape_value) {
                            .object => |object| object,
                            else => return error.InvalidVoxelShape,
                        };

                        var x_size: u8 = 0;
                        var y_size: u8 = 0;
                        var z_size: u8 = 0;
                        var storage: []u8 = &.{};

                        if (shape.get("cells")) |cells_value| {
                            switch (cells_value) {
                                .object => |cells| {
                                    x_size = @intCast(getInt(cells.get("xSize")));
                                    y_size = @intCast(getInt(cells.get("ySize")));
                                    z_size = @intCast(getInt(cells.get("zSize")));
                                    if (cells.get("storage")) |storage_value| {
                                        switch (storage_value) {
                                            .array => |items| {
                                                const storage_buf = try a.alloc(u8, items.items.len);
                                                for (items.items, 0..) |item, i| {
                                                    storage_buf[i] = @intCast(getInt(item));
                                                }
                                                storage = storage_buf;
                                            },
                                            else => {},
                                        }
                                    }
                                },
                                else => {},
                            }
                        }

                        const xs = try readCoordinates(a, shape.get("x"));
                        const ys = try readCoordinates(a, shape.get("y"));
                        const zs = try readCoordinates(a, shape.get("z"));

                        try voxel_shape_cells.append(a, storage);
                        try voxel_shape_xs.append(a, xs);
                        try voxel_shape_ys.append(a, ys);
                        try voxel_shape_zs.append(a, zs);
                        try voxel_shapes_list.append(a, .{
                            .cells = SerializableCells.init(x_size, y_size, z_size, storage),
                            .x_coordinates = xs,
                            .y_coordinates = ys,
                            .z_coordinates = zs,
                        });
                    }
                },
                else => {},
            }
        }
    }

    return PreSpawnData{
        .jigsaw_nbt = jigsaw_nbt,
        .block_palette = block_palette_list.items,
        .block_palette_nbt = block_palette_nbt_list.items,
        .voxel_shapes = voxel_shapes_list.items,
        .voxel_shape_cells = voxel_shape_cells.items,
        .voxel_shape_xs = voxel_shape_xs.items,
        .voxel_shape_ys = voxel_shape_ys.items,
        .voxel_shape_zs = voxel_shape_zs.items,
        .voxel_name_map = voxel_name_map.items,
        .arena = arena,
    };
}

fn readCoordinates(a: std.mem.Allocator, value: ?std.json.Value) ![]f32 {
    const array = switch (value orelse return &.{}) {
        .array => |array| array,
        else => return &.{},
    };
    const coords = try a.alloc(f32, array.items.len);
    for (array.items, 0..) |item, i| {
        coords[i] = switch (item) {
            .integer => |number| @floatFromInt(number),
            .float => |number| @floatCast(number),
            else => 0,
        };
    }
    return coords;
}

fn getInt(value: ?std.json.Value) i64 {
    const unwrapped = value orelse return 0;
    return switch (unwrapped) {
        .integer => |number| number,
        .float => |number| @intFromFloat(number),
        else => 0,
    };
}

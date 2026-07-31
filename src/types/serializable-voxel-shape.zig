const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const SerializableCells = @import("./serializable-cells.zig").SerializableCells;

pub const SerializableVoxelShape = struct {
    cells: SerializableCells,
    x_coordinates: []f32,
    y_coordinates: []f32,
    z_coordinates: []f32,

    pub fn init(
        cells: SerializableCells,
        x_coordinates: []f32,
        y_coordinates: []f32,
        z_coordinates: []f32,
    ) SerializableVoxelShape {
        return SerializableVoxelShape{
            .cells = cells,
            .x_coordinates = x_coordinates,
            .y_coordinates = y_coordinates,
            .z_coordinates = z_coordinates,
        };
    }

    pub fn read(stream: *BinaryStream) !SerializableVoxelShape {
        const cells = try SerializableCells.read(stream);

        const xLength = try stream.readVarInt();
        const x_coordinates = try stream.allocator.alloc(f32, @intCast(xLength));
        for (0..@intCast(xLength)) |i| {
            x_coordinates[i] = try stream.readFloat32(.Little);
        }

        const yLength = try stream.readVarInt();
        const y_coordinates = try stream.allocator.alloc(f32, @intCast(yLength));
        for (0..@intCast(yLength)) |i| {
            y_coordinates[i] = try stream.readFloat32(.Little);
        }

        const zLength = try stream.readVarInt();
        const z_coordinates = try stream.allocator.alloc(f32, @intCast(zLength));
        for (0..@intCast(zLength)) |i| {
            z_coordinates[i] = try stream.readFloat32(.Little);
        }

        return SerializableVoxelShape{
            .cells = cells,
            .x_coordinates = x_coordinates,
            .y_coordinates = y_coordinates,
            .z_coordinates = z_coordinates,
        };
    }

    pub fn write(stream: *BinaryStream, value: SerializableVoxelShape) !void {
        try SerializableCells.write(stream, value.cells);

        try stream.writeVarInt(@intCast(value.x_coordinates.len));
        for (value.x_coordinates) |x| {
            try stream.writeFloat32(x, .Little);
        }

        try stream.writeVarInt(@intCast(value.y_coordinates.len));
        for (value.y_coordinates) |y| {
            try stream.writeFloat32(y, .Little);
        }

        try stream.writeVarInt(@intCast(value.z_coordinates.len));
        for (value.z_coordinates) |z| {
            try stream.writeFloat32(z, .Little);
        }
    }

    pub fn deinit(self: *SerializableVoxelShape, allocator: std.mem.Allocator) void {
        self.cells.deinit(allocator);
        allocator.free(self.x_coordinates);
        allocator.free(self.y_coordinates);
        allocator.free(self.z_coordinates);
    }
};

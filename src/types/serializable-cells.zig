const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;

pub const SerializableCells = struct {
    x_size: u8,
    y_size: u8,
    z_size: u8,
    storage: []u8,

    pub fn init(x_size: u8, y_size: u8, z_size: u8, storage: []u8) SerializableCells {
        return SerializableCells{
            .x_size = x_size,
            .y_size = y_size,
            .z_size = z_size,
            .storage = storage,
        };
    }

    pub fn read(stream: *BinaryStream) !SerializableCells {
        const x_size = try stream.readInt8();
        const y_size = try stream.readInt8();
        const z_size = try stream.readInt8();

        const length = try stream.readVarInt();
        const storage = try stream.allocator.alloc(u8, @intCast(length));

        for (0..@intCast(length)) |i| {
            storage[i] = @bitCast(try stream.readInt8());
        }

        return SerializableCells{
            .x_size = @bitCast(x_size),
            .y_size = @bitCast(y_size),
            .z_size = @bitCast(z_size),
            .storage = storage,
        };
    }

    pub fn write(stream: *BinaryStream, value: SerializableCells) !void {
        try stream.writeInt8(@bitCast(value.x_size));
        try stream.writeInt8(@bitCast(value.y_size));
        try stream.writeInt8(@bitCast(value.z_size));

        try stream.writeVarInt(@intCast(value.storage.len));
        for (value.storage) |cell| {
            try stream.writeInt8(@bitCast(cell));
        }
    }

    pub fn deinit(self: *SerializableCells, allocator: std.mem.Allocator) void {
        allocator.free(self.storage);
    }
};

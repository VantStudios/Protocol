const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../enums/packet.zig").Packet;

pub const HeightMapDataType = enum(u8) {
    None = 0,
    HasData = 1,
    AllData = 2,
};

pub const SubChunkRequestResult = enum(u8) {
    Undefined = 0,
    SuccessAllAir = 1,
    Success = 2,
    NoSuchChunk = 3,
    WrongDimension = 4,
};

pub const HEIGHT_MAP_LENGTH = 256;
const HEIGHT_MAP_SEGMENT = 16;

pub const SubChunkData = struct {
    offset_x: i8 = 0,
    offset_y: i8 = 0,
    offset_z: i8 = 0,
    result: SubChunkRequestResult = .Undefined,
    data: ?[]const u8 = null,
    height_map_type: HeightMapDataType = .None,
    height_map_data: ?[]const u8 = null,
    render_height_map_type: HeightMapDataType = .None,
    render_height_map_data: ?[]const u8 = null,
    blob_id: ?i64 = null,

    fn writeHeightMap(stream: *BinaryStream, height_map: []const u8) !void {
        var offset: usize = 0;
        while (offset < HEIGHT_MAP_LENGTH) : (offset += HEIGHT_MAP_SEGMENT) {
            try stream.writeVarInt(HEIGHT_MAP_SEGMENT);
            try stream.write(height_map[offset .. offset + HEIGHT_MAP_SEGMENT]);
        }
    }

    fn readHeightMap(stream: *BinaryStream, buffer: []u8) !void {
        var offset: usize = 0;
        while (offset < HEIGHT_MAP_LENGTH) : (offset += HEIGHT_MAP_SEGMENT) {
            const size = try stream.readVarInt();
            if (size != HEIGHT_MAP_SEGMENT) return error.InvalidHeightMapSegmentSize;
            for (0..HEIGHT_MAP_SEGMENT) |i| {
                buffer[offset + i] = @bitCast(try stream.readByte());
            }
        }
    }

    fn write(stream: *BinaryStream, sub: SubChunkData) !void {
        try stream.writeByte(@bitCast(sub.offset_x));
        try stream.writeByte(@bitCast(sub.offset_y));
        try stream.writeByte(@bitCast(sub.offset_z));
        try stream.writeUint8(@intFromEnum(sub.result));
        if (sub.data) |data| {
            try stream.writeBool(true);
            try stream.writeVarInt(@intCast(data.len));
            try stream.write(data);
        } else {
            try stream.writeBool(false);
        }

        try stream.writeUint8(@intFromEnum(sub.height_map_type));
        if (sub.height_map_data) |hm| {
            try stream.writeBool(true);
            try writeHeightMap(stream, hm);
        } else {
            try stream.writeBool(false);
        }

        try stream.writeUint8(@intFromEnum(sub.render_height_map_type));
        if (sub.render_height_map_data) |rhm| {
            try stream.writeBool(true);
            try writeHeightMap(stream, rhm);
        } else {
            try stream.writeBool(false);
        }

        if (sub.blob_id) |id| {
            try stream.writeBool(true);
            try stream.writeInt64(id, .Little);
        } else {
            try stream.writeBool(false);
        }
    }

    fn read(stream: *BinaryStream, allocator: std.mem.Allocator) !SubChunkData {
        var sub = SubChunkData{};
        sub.offset_x = @bitCast(try stream.readByte());
        sub.offset_y = @bitCast(try stream.readByte());
        sub.offset_z = @bitCast(try stream.readByte());
        sub.result = std.enums.fromInt(SubChunkRequestResult, try stream.readUint8()) orelse return error.InvalidSubChunkResult;

        if (try stream.readBool()) {
            const length = try stream.readVarInt();
            const data = try allocator.alloc(u8, @intCast(length));
            errdefer allocator.free(data);
            for (0..@intCast(length)) |i| {
                data[i] = @bitCast(try stream.readByte());
            }
            sub.data = data;
        }

        sub.height_map_type = std.enums.fromInt(HeightMapDataType, try stream.readUint8()) orelse return error.InvalidHeightMapType;
        if (try stream.readBool()) {
            const height_map = try allocator.alloc(u8, HEIGHT_MAP_LENGTH);
            errdefer allocator.free(height_map);
            try readHeightMap(stream, height_map);
            sub.height_map_data = height_map;
        }

        sub.render_height_map_type = std.enums.fromInt(HeightMapDataType, try stream.readUint8()) orelse return error.InvalidHeightMapType;
        if (try stream.readBool()) {
            const render_height_map = try allocator.alloc(u8, HEIGHT_MAP_LENGTH);
            errdefer allocator.free(render_height_map);
            try readHeightMap(stream, render_height_map);
            sub.render_height_map_data = render_height_map;
        }

        if (try stream.readBool()) {
            sub.blob_id = try stream.readInt64(.Little);
        }

        return sub;
    }
};

pub const SubChunkPacket = struct {
    cache_enabled: bool = false,
    dimension: i32 = 0,
    center_x: i32 = 0,
    center_y: i32 = 0,
    center_z: i32 = 0,
    sub_chunks: []const SubChunkData = &.{},

    pub fn serialize(self: *const SubChunkPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.SubChunk);
        try stream.writeBool(self.cache_enabled);
        try stream.writeZigZag(self.dimension);
        try stream.writeInt32(self.center_x, .Little);
        try stream.writeInt32(self.center_y, .Little);
        try stream.writeInt32(self.center_z, .Little);
        try stream.writeVarInt(@intCast(self.sub_chunks.len));
        for (self.sub_chunks) |sub_chunk| {
            try SubChunkData.write(stream, sub_chunk);
        }
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !SubChunkPacket {
        _ = try stream.readVarInt();
        var packet = SubChunkPacket{};
        packet.cache_enabled = try stream.readBool();
        packet.dimension = try stream.readZigZag();
        packet.center_x = try stream.readInt32(.Little);
        packet.center_y = try stream.readInt32(.Little);
        packet.center_z = try stream.readInt32(.Little);
        const count = try stream.readVarInt();
        const sub_chunks = try allocator.alloc(SubChunkData, @intCast(count));
        errdefer allocator.free(sub_chunks);
        for (0..@intCast(count)) |i| {
            sub_chunks[i] = try SubChunkData.read(stream, allocator);
        }
        packet.sub_chunks = sub_chunks;
        return packet;
    }

    pub fn deinit(self: *const SubChunkPacket, allocator: std.mem.Allocator) void {
        for (self.sub_chunks) |sub| {
            if (sub.data) |data| allocator.free(data);
            if (sub.height_map_data) |height_map| allocator.free(height_map);
            if (sub.render_height_map_data) |render_height_map| allocator.free(render_height_map);
        }
        allocator.free(self.sub_chunks);
    }
};

test "height map segments roundtrip with size prefixes" {
    const allocator = std.testing.allocator;

    var stream = BinaryStream.init(allocator, null, null);
    defer stream.deinit();

    var height_map: [HEIGHT_MAP_LENGTH]u8 = undefined;
    for (&height_map, 0..) |*byte, i| byte.* = @intCast(i % 251);

    const packet = SubChunkPacket{
        .cache_enabled = false,
        .dimension = 0,
        .center_x = 1,
        .center_y = 64,
        .center_z = -2,
        .sub_chunks = &[_]SubChunkData{
            .{
                .offset_x = -1,
                .offset_y = 3,
                .offset_z = 2,
                .result = .Success,
                .height_map_type = .HasData,
                .height_map_data = &height_map,
            },
        },
    };

    const buf = try packet.serialize(&stream);
    var read_stream = BinaryStream.init(allocator, buf, null);
    defer read_stream.deinit();

    var parsed = try SubChunkPacket.deserialize(&read_stream, allocator);
    defer parsed.deinit(allocator);

    try std.testing.expectEqual(@as(u32, 1), parsed.sub_chunks.len);
    const sub = parsed.sub_chunks[0];
    try std.testing.expectEqual(HeightMapDataType.HasData, sub.height_map_type);
    try std.testing.expectEqualSlices(u8, &height_map, sub.height_map_data.?);
    try std.testing.expect(sub.render_height_map_data == null);
    try std.testing.expectEqual(@as(i8, -1), sub.offset_x);
    try std.testing.expectEqual(SubChunkRequestResult.Success, sub.result);
}

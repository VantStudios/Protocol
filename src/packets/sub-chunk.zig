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
            try stream.write(hm);
        } else {
            try stream.writeBool(false);
        }

        try stream.writeUint8(@intFromEnum(sub.render_height_map_type));
        if (sub.render_height_map_data) |rhm| {
            try stream.writeBool(true);
            try stream.write(rhm);
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
};

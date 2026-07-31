const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const DimensionType = @import("../enums/dimension-type.zig").DimensionType;

pub const LevelChunk = struct {
    const MAX_BLOB_HASHES = 64;

    x: i32,
    z: i32,
    dimension: DimensionType,
    highest_sub_chunk_count: u16,
    sub_chunk_count: i32,
    cache_enabled: bool,
    blobs: []const u64,
    data: []const u8,

    pub fn serialize(self: *LevelChunk, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.LevelChunk);
        try stream.writeZigZag(self.x);
        try stream.writeZigZag(self.z);
        try stream.writeZigZag(@intFromEnum(self.dimension));
        try stream.writeVarInt(@intCast(self.sub_chunk_count));

        if (self.sub_chunk_count == -2) {
            try stream.writeUint16(self.highest_sub_chunk_count, .Little);
        }

        try stream.writeBool(self.cache_enabled);

        if (self.cache_enabled) {
            if (self.blobs.len == 0) {
                return error.BlobsRequiredWhenCacheEnabled;
            }
            try stream.writeVarInt(@intCast(self.blobs.len));
            for (self.blobs) |hash| {
                try stream.writeUint64(hash, .Little);
            }
        }

        try stream.writeVarInt(@intCast(self.data.len));
        try stream.write(self.data);

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !LevelChunk {
        _ = try stream.readVarInt();
        const x = try stream.readZigZag();
        const z = try stream.readZigZag();
        const dimension_raw = try stream.readZigZag();
        const dimension: DimensionType = @enumFromInt(dimension_raw);

        var sub_chunk_count = try stream.readVarInt();
        if (sub_chunk_count == 4_294_967_294) {
            sub_chunk_count = -2;
        }

        var highest_sub_chunk_count: u16 = 0;
        if (sub_chunk_count == -2) {
            highest_sub_chunk_count = try stream.readUint16(.Little);
        }

        const cache_enabled = try stream.readBool();

        var blobs: []const u64 = &[_]u64{};
        if (cache_enabled) {
            const blobCount = try stream.readVarInt();
            if (blobCount > MAX_BLOB_HASHES) {
                return error.TooManyBlobHashes;
            }

            const blob_array = try stream.allocator.alloc(u64, @intCast(blobCount));
            for (0..@intCast(blobCount)) |i| {
                blob_array[i] = try stream.readUint64(.Little);
            }
            blobs = blob_array;
        }

        const dataLength = try stream.readVarInt();
        const data = stream.read(@intCast(dataLength));

        return LevelChunk{
            .x = x,
            .z = z,
            .dimension = dimension,
            .highest_sub_chunk_count = highest_sub_chunk_count,
            .sub_chunk_count = sub_chunk_count,
            .cache_enabled = cache_enabled,
            .blobs = blobs,
            .data = data,
        };
    }
};

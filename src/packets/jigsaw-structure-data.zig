const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;

pub const JigsawStructureDataPacket = struct {
    nbt: []const u8,

    pub fn init(nbt: []const u8) JigsawStructureDataPacket {
        return JigsawStructureDataPacket{
            .nbt = nbt,
        };
    }

    pub fn serialize(self: *JigsawStructureDataPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.JigsawStructureData);
        try stream.write(self.nbt);
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !JigsawStructureDataPacket {
        _ = try stream.readVarInt();
        const length = stream.remainingBytes();
        const nbt = try allocator.dupe(u8, stream.read(length));
        return JigsawStructureDataPacket{
            .nbt = nbt,
        };
    }

    pub fn deinit(self: *JigsawStructureDataPacket, allocator: std.mem.Allocator) void {
        allocator.free(self.nbt);
    }
};

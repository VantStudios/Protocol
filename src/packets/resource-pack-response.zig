const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const ResourcePackResponse = @import("../root.zig").ResourcePackResponse;

pub const ResourcePackClientResponsePacket = struct {
    response: ResourcePackResponse,
    downloading_packs: []const []const u8 = &.{},

    pub fn serialize(self: *const ResourcePackClientResponsePacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.ResourcePackResponse);
        try stream.writeUint8(@intFromEnum(self.response));

        if (self.response == .Downloading) {
            try stream.writeVarInt(@intCast(self.downloading_packs.len));
            for (self.downloading_packs) |pack_name| {
                try stream.writeVarString(pack_name);
            }
        }

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !ResourcePackClientResponsePacket {
        _ = try stream.readVarInt();

        const response: ResourcePackResponse = @enumFromInt(try stream.readUint8());

        var packs: []const []const u8 = &.{};
        if (response == .Downloading) {
            const count = try stream.readVarInt();
            const pack_array = try allocator.alloc([]const u8, @intCast(count));
            for (0..@intCast(count)) |i| {
                pack_array[i] = try stream.allocator.dupe(u8, try stream.readVarString());
            }
            packs = pack_array;
        }

        return ResourcePackClientResponsePacket{
            .response = response,
            .downloading_packs = packs,
        };
    }

    pub fn deinit(self: *const ResourcePackClientResponsePacket, allocator: std.mem.Allocator) void {
        for (self.downloading_packs) |pack_name| {
            allocator.free(pack_name);
        }
        allocator.free(self.downloading_packs);
    }
};

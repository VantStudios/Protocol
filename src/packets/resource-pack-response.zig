const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../root.zig").Packet;
const ResourcePackResponse = @import("../root.zig").ResourcePackResponse;

fn wireOrdinalAndString(status: ResourcePackResponse) struct { ordinal: u8, label: []const u8 } {
    return switch (status) {
        .None => .{ .ordinal = 0, .label = "cancel" },
        .Refused => .{ .ordinal = 0, .label = "cancel" },
        .SendPacks => .{ .ordinal = 1, .label = "downloading" },
        .HaveAllPacks => .{ .ordinal = 2, .label = "downloadingfinished" },
        .Completed => .{ .ordinal = 3, .label = "resourcepackstackfinished" },
    };
}

pub const ResourcePackClientResponsePacket = struct {
    response: ResourcePackResponse,
    packs: []const []const u8 = &.{},

    pub fn serialize(self: *const ResourcePackClientResponsePacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.ResourcePackResponse);

        const mapping = wireOrdinalAndString(self.response);
        try stream.writeVarInt(mapping.ordinal);
        try stream.writeVarString(mapping.label);

        if (self.response == .SendPacks) {
            try stream.writeVarInt(@intCast(self.packs.len));
            for (self.packs) |pack_id| {
                try stream.writeVarString(pack_id);
            }
        }

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream, allocator: std.mem.Allocator) !ResourcePackClientResponsePacket {
        _ = try stream.readVarInt();

        const wire = try stream.readVarInt();
        _ = try stream.readVarString(); // status string; ignored on the wire

        const response: ResourcePackResponse = switch (wire) {
            0 => .Refused,
            1 => .SendPacks,
            2 => .HaveAllPacks,
            3 => .Completed,
            else => .Refused,
        };

        var packs: []const []const u8 = &.{};
        if (response == .SendPacks) {
            const count = try stream.readVarInt();
            const pack_array = try allocator.alloc([]const u8, @intCast(count));
            for (0..@intCast(count)) |i| {
                pack_array[i] = try stream.allocator.dupe(u8, try stream.readVarString());
            }
            packs = pack_array;
        }

        return ResourcePackClientResponsePacket{
            .response = response,
            .packs = packs,
        };
    }

    pub fn deinit(self: *const ResourcePackClientResponsePacket, allocator: std.mem.Allocator) void {
        for (self.packs) |pack_id| {
            allocator.free(pack_id);
        }
        allocator.free(@constCast(self.packs));
    }
};

const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const ResourceIdVersions = @import("../types/resource-id-versions.zig").ResourceIdVersions;
const Experiments = @import("../types/experiments.zig").Experiments;
const Packet = @import("../root.zig").Packet;

pub const ResourcePackStackPacket = struct {
    must_accept: bool,
    texture_packs: []ResourceIdVersions,
    game_version: []const u8,
    experiments: []Experiments,
    experiments_previously_toggled: bool,
    has_editor_packs: bool,

    pub fn serialize(self: *ResourcePackStackPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.ResourcePackStack);

        try stream.writeBool(self.must_accept);
        try ResourceIdVersions.write(stream, self.texture_packs);
        try stream.writeVarString(self.game_version);
        try Experiments.write(stream, self.experiments);
        try stream.writeBool(self.experiments_previously_toggled);
        try stream.writeBool(self.has_editor_packs);

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !ResourcePackStackPacket {
        _ = try stream.readVarInt();

        const must_accept = try stream.readBool();
        const texture_packs = try ResourceIdVersions.read(stream);
        const game_version = try stream.readVarString();
        const experiments = try Experiments.read(stream);
        const experiments_previously_toggled = try stream.readBool();
        const has_editor_packs = try stream.readBool();

        return ResourcePackStackPacket{
            .must_accept = must_accept,
            .texture_packs = texture_packs,
            .game_version = game_version,
            .experiments = experiments,
            .experiments_previously_toggled = experiments_previously_toggled,
            .has_editor_packs = has_editor_packs,
        };
    }

    pub fn deinit(self: *ResourcePackStackPacket, allocator: std.mem.Allocator) void {
        for (self.texture_packs) |*pack| {
            pack.deinit(allocator);
        }
        allocator.free(self.texture_packs);

        for (self.experiments) |*experiment| {
            experiment.deinit(allocator);
        }
        allocator.free(self.experiments);
    }
};

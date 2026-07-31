const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Uuid = @import("../types/uuid.zig").Uuid;
const ResourcePackDescriptor = @import("../types/resource-pack-descriptor.zig").ResourcePackDescriptor;
const Packet = @import("../root.zig").Packet;

pub const ResourcePacksInfoPacket = struct {
    must_accept: bool,
    has_addons: bool,
    has_scripts: bool,
    force_disable_vibrant_visuals: bool,
    world_template_uuid: []const u8,
    world_template_version: []const u8,
    packs: []ResourcePackDescriptor,

    pub fn serialize(self: *ResourcePacksInfoPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.ResourcePackInfo);

        try stream.writeBool(self.must_accept);
        try stream.writeBool(self.has_addons);
        try stream.writeBool(self.has_scripts);
        try stream.writeBool(self.force_disable_vibrant_visuals);
        try Uuid.write(stream, self.world_template_uuid);
        try stream.writeVarString(self.world_template_version);
        try ResourcePackDescriptor.write(stream, self.packs);

        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !ResourcePacksInfoPacket {
        _ = try stream.readVarInt();

        const must_accept = try stream.readBool();
        const has_addons = try stream.readBool();
        const has_scripts = try stream.readBool();
        const force_disable_vibrant_visuals = try stream.readBool();
        const world_template_uuid = try Uuid.read(stream);
        const world_template_version = try stream.readVarString();
        const packs = try ResourcePackDescriptor.read(stream);

        return ResourcePacksInfoPacket{
            .must_accept = must_accept,
            .has_addons = has_addons,
            .has_scripts = has_scripts,
            .force_disable_vibrant_visuals = force_disable_vibrant_visuals,
            .world_template_uuid = world_template_uuid,
            .world_template_version = world_template_version,
            .packs = packs,
        };
    }

    pub fn deinit(self: *ResourcePacksInfoPacket, allocator: std.mem.Allocator) void {
        for (self.packs) |*pack| {
            pack.deinit(allocator);
        }
        allocator.free(self.packs);
    }
};

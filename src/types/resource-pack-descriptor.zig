const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Uuid = @import("uuid.zig").Uuid;

pub const ResourcePackDescriptor = struct {
    uuid: []const u8,
    version: []const u8,
    size: u64,
    content_key: []const u8,
    subpack_name: []const u8,
    content_identity: []const u8,
    has_scripts: bool,
    is_addon_pack: bool,
    has_rtx_capabilities: bool,
    cdn_url: []const u8,

    pub fn init(
        uuid: []const u8,
        version: []const u8,
        size: u64,
        content_key: []const u8,
        subpack_name: []const u8,
        content_identity: []const u8,
        has_scripts: bool,
        is_addon_pack: bool,
        has_rtx_capabilities: bool,
        cdn_url: []const u8,
    ) ResourcePackDescriptor {
        return ResourcePackDescriptor{
            .uuid = uuid,
            .version = version,
            .size = size,
            .content_key = content_key,
            .subpack_name = subpack_name,
            .content_identity = content_identity,
            .has_scripts = has_scripts,
            .is_addon_pack = is_addon_pack,
            .has_rtx_capabilities = has_rtx_capabilities,
            .cdn_url = cdn_url,
        };
    }

    pub fn read(stream: *BinaryStream) ![]ResourcePackDescriptor {
        const amount = try stream.readInt16(.Little);
        const packs = try stream.allocator.alloc(ResourcePackDescriptor, @intCast(amount));

        for (0..@intCast(amount)) |i| {
            const uuid = try Uuid.read(stream);
            const version = try stream.readVarString();
            const size = try stream.readUint64(.Little);
            const content_key = try stream.readVarString();
            const subpack_name = try stream.readVarString();
            const content_identity = try stream.readVarString();
            const has_scripts = try stream.readBool();
            const is_addon_pack = try stream.readBool();
            const has_rtx_capabilities = try stream.readBool();
            const cdn_url = try stream.readVarString();

            packs[i] = ResourcePackDescriptor{
                .uuid = uuid,
                .version = version,
                .size = size,
                .content_key = content_key,
                .subpack_name = subpack_name,
                .content_identity = content_identity,
                .has_scripts = has_scripts,
                .is_addon_pack = is_addon_pack,
                .has_rtx_capabilities = has_rtx_capabilities,
                .cdn_url = cdn_url,
            };
        }

        return packs;
    }

    pub fn write(stream: *BinaryStream, packs: []const ResourcePackDescriptor) !void {
        try stream.writeInt16(@intCast(packs.len), .Little);

        for (packs) |pack| {
            try Uuid.write(stream, pack.uuid);
            try stream.writeVarString(pack.version);
            try stream.writeUint64(pack.size, .Little);
            try stream.writeVarString(pack.content_key);
            try stream.writeVarString(pack.subpack_name);
            try stream.writeVarString(pack.content_identity);
            try stream.writeBool(pack.has_scripts);
            try stream.writeBool(pack.is_addon_pack);
            try stream.writeBool(pack.has_rtx_capabilities);
            try stream.writeVarString(pack.cdn_url);
        }
    }

    pub fn deinit(self: *ResourcePackDescriptor, allocator: std.mem.Allocator) void {
        _ = self;
        _ = allocator;
    }
};

const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Uuid = @import("uuid.zig").Uuid;
const ClientData = @import("../login/types.zig").ClientData;
const SerializedSkin = @import("serialized-skin.zig").SerializedSkin;
const PlayerListAction = @import("../enums/player-list-action.zig").PlayerListAction;

pub const PlayerListEntry = struct {
    action: PlayerListAction,
    uuid: []const u8,
    entity_unique_id: i64 = 0,
    username: []const u8 = "",
    xuid: []const u8 = "",
    platform_chat_id: []const u8 = "",
    build_platform: i32 = 0,
    skin: ?*const ClientData = null,
    teacher: bool = false,
    host: bool = false,
    sub_client: bool = false,

    pub fn write(stream: *BinaryStream, entry: PlayerListEntry, allocator: std.mem.Allocator) !void {
        try stream.writeUint8(@intFromEnum(entry.action));
        try Uuid.write(stream, entry.uuid);

        if (entry.action == .Remove) {
            return;
        }

        try stream.writeZigZong(entry.entity_name);
        try stream.writeVarString(entry.username);
        try stream.writeVarString(entry.xuid);
        try stream.writeVarString(entry.platform_chat_id);
        try stream.writeInt32(entry.build_platform, .Little);
        if (entry.skin) |skin| {
            try SerializedSkin.write(stream, skin, allocator);
        }
        try stream.writeBool(entry.teacher);
        try stream.writeBool(entry.host);
        try stream.writeBool(entry.sub_client);
        try stream.writeInt32(0, .Little);
    }
};

const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const Uuid = @import("../types/uuid.zig").Uuid;

pub const CommandOriginType = enum(u8) {
    Player = 0,
    DevConsole = 1,
    Test = 2,
    AutomationPlayer = 3,
    _,
};

pub const CommandRequestPacket = struct {
    command_line: []const u8,
    origin_type: CommandOriginType,
    uuid: [16]u8,
    request_id: []const u8,
    player_unique_id: i64,
    internal: bool,
    version: i32,

    pub fn deserialize(stream: *BinaryStream) !CommandRequestPacket {
        _ = try stream.readVarInt();
        const command_line = try stream.readVarString();

        const origin_type_raw = try stream.readUint8();
        const origin_type: CommandOriginType = std.enums.fromInt(CommandOriginType, origin_type_raw) orelse return error.UnknownCommandOriginType;

        const uuid_slice = Uuid.read(stream);
        var uuid: [16]u8 = undefined;
        @memcpy(&uuid, uuid_slice[0..16]);

        const request_id = try stream.readVarString();
        const player_unique_id = try stream.readInt64(.Little);

        const internal = try stream.readBool();
        const version = try stream.readInt32(.Little);

        return CommandRequestPacket{
            .command_line = command_line,
            .origin_type = origin_type,
            .uuid = uuid,
            .request_id = request_id,
            .player_unique_id = player_unique_id,
            .internal = internal,
            .version = version,
        };
    }
};

const std = @import("std");

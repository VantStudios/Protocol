const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../root.zig").Packet;
const Uuid = @import("../types/uuid.zig").Uuid;

pub const CommandOriginType = enum {
    Player,
    Block,
    MinecartBlock,
    DevConsole,
    Test,
    AutomationPlayer,
    ClientAutomation,
    DedicatedServer,
    Entity,
    Virtual,
    GameArgument,
    EntityServer,
    Precompiled,
    GameDirectorEntityServer,
    Scripting,
    ExecuteContext,
    Unknown,

    pub fn fromString(str: []const u8) CommandOriginType {
        const map = std.StaticStringMap(CommandOriginType).initComptime(.{
            .{ "player", .Player },
            .{ "commandblock", .Block },
            .{ "minecartcommandblock", .MinecartBlock },
            .{ "devconsole", .DevConsole },
            .{ "test", .Test },
            .{ "automationplayer", .AutomationPlayer },
            .{ "clientautomation", .ClientAutomation },
            .{ "dedicatedserver", .DedicatedServer },
            .{ "entity", .Entity },
            .{ "virtual", .Virtual },
            .{ "gameargument", .GameArgument },
            .{ "entityserver", .EntityServer },
            .{ "precompiled", .Precompiled },
            .{ "gamedirectorentityserver", .GameDirectorEntityServer },
            .{ "scripting", .Scripting },
            .{ "executecontext", .ExecuteContext },
        });
        return map.get(str) orelse .Unknown;
    }

    pub fn toString(self: CommandOriginType) []const u8 {
        return switch (self) {
            .Player => "player",
            .Block => "commandblock",
            .MinecartBlock => "minecartcommandblock",
            .DevConsole => "devconsole",
            .Test => "test",
            .AutomationPlayer => "automationplayer",
            .ClientAutomation => "clientautomation",
            .DedicatedServer => "dedicatedserver",
            .Entity => "entity",
            .Virtual => "virtual",
            .GameArgument => "gameargument",
            .EntityServer => "entityserver",
            .Precompiled => "precompiled",
            .GameDirectorEntityServer => "gamedirectorentityserver",
            .Scripting => "scripting",
            .ExecuteContext => "executecontext",
            .Unknown => "unknown",
        };
    }
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

        const origin_type_str = try stream.readVarString();
        const origin_type = CommandOriginType.fromString(origin_type_str);

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

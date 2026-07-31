const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;

pub const ServerTelemetryData = struct {
    server_id: []const u8,
    scenario_id: []const u8,
    world_id: []const u8,
    owner_id: []const u8,

    pub fn init(server_id: []const u8, scenario_id: []const u8, world_id: []const u8, owner_id: []const u8) ServerTelemetryData {
        return ServerTelemetryData{
            .server_id = server_id,
            .scenario_id = scenario_id,
            .world_id = world_id,
            .owner_id = owner_id,
        };
    }

    pub fn read(stream: *BinaryStream) !ServerTelemetryData {
        const server_id = try stream.readVarString();
        const scenario_id = try stream.readVarString();
        const world_id = try stream.readVarString();
        const owner_id = try stream.readVarString();

        return ServerTelemetryData{
            .server_id = server_id,
            .scenario_id = scenario_id,
            .world_id = world_id,
            .owner_id = owner_id,
        };
    }

    pub fn write(stream: *BinaryStream, value: ServerTelemetryData) !void {
        try stream.writeVarString(value.server_id);
        try stream.writeVarString(value.scenario_id);
        try stream.writeVarString(value.world_id);
        try stream.writeVarString(value.owner_id);
    }

    pub fn deinit(self: *ServerTelemetryData, allocator: std.mem.Allocator) void {
        _ = self;
        _ = allocator;
    }
};

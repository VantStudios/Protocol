const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const Packet = @import("../enums/packet.zig").Packet;
const BlockPosition = @import("../types/block-position.zig").BlockPosition;

pub const StructureBlockType = enum(i32) {
    Data = 0,
    Save = 1,
    Load = 2,
    Corner = 3,
    Export = 4,
};

pub const StructureRedstoneSaveMode = enum(u8) {
    Memory = 0,
    Disk = 1,
};

pub const StructureSettings = struct {
    palette_name: []const u8 = "",
    ignore_entities: bool = false,
    ignore_blocks: bool = false,
    non_ticking_player_blocks_only: bool = false,
    size: BlockPosition = BlockPosition.init(0, 0, 0),
    offset: BlockPosition = BlockPosition.init(0, 0, 0),
    last_edit_player: i64 = 0,
    rotation: u8 = 0,
    mirror: u8 = 0,
    animation_mode: u8 = 0,
    animation_duration: f32 = 0.0,
    integrity: f32 = 1.0,
    seed: i32 = 0,
    pivot: BlockPosition = BlockPosition.init(0, 0, 0),

    pub fn write(stream: *BinaryStream, value: StructureSettings) !void {
        try stream.writeVarString(value.palette_name);
        try stream.writeBool(value.ignore_entities);
        try stream.writeBool(value.ignore_blocks);
        try stream.writeBool(value.non_ticking_player_blocks_only);
        try BlockPosition.write(stream, value.size);
        try BlockPosition.write(stream, value.offset);
        try stream.writeZigZong(value.last_edit_player);
        try stream.writeUint8(value.rotation);
        try stream.writeUint8(value.mirror);
        try stream.writeUint8(value.animation_mode);
        try stream.writeFloat32(value.animation_duration, .Little);
        try stream.writeFloat32(value.integrity, .Little);
        try stream.writeZigZag(value.seed);
        try BlockPosition.write(stream, value.pivot);
    }

    pub fn read(stream: *BinaryStream) !StructureSettings {
        const palette_name = try stream.readVarString();
        const ignore_entities = try stream.readBool();
        const ignore_blocks = try stream.readBool();
        const non_ticking_player_blocks_only = try stream.readBool();
        const size = try BlockPosition.read(stream);
        const offset = try BlockPosition.read(stream);
        const last_edit_player = try stream.readZigZong();
        const rotation = try stream.readUint8();
        const mirror = try stream.readUint8();
        const animation_mode = try stream.readUint8();
        const animation_duration = try stream.readFloat32(.Little);
        const integrity = try stream.readFloat32(.Little);
        const seed = try stream.readZigZag();
        const pivot = try BlockPosition.read(stream);
        return .{
            .palette_name = palette_name,
            .ignore_entities = ignore_entities,
            .ignore_blocks = ignore_blocks,
            .non_ticking_player_blocks_only = non_ticking_player_blocks_only,
            .size = size,
            .offset = offset,
            .last_edit_player = last_edit_player,
            .rotation = rotation,
            .mirror = mirror,
            .animation_mode = animation_mode,
            .animation_duration = animation_duration,
            .integrity = integrity,
            .seed = seed,
            .pivot = pivot,
        };
    }
};

pub const StructureEditorData = struct {
    name: []const u8 = "",
    filtered_name: []const u8 = "",
    data_field: []const u8 = "",
    including_players: bool = false,
    bounding_box_visible: bool = false,
    block_type: StructureBlockType = .Data,
    settings: StructureSettings = .{},
    redstone_save_mode: StructureRedstoneSaveMode = .Memory,

    pub fn write(stream: *BinaryStream, value: StructureEditorData) !void {
        try stream.writeVarString(value.name);
        try stream.writeVarString(value.filtered_name);
        try stream.writeVarString(value.data_field);
        try stream.writeBool(value.including_players);
        try stream.writeBool(value.bounding_box_visible);
        try stream.writeZigZag(@intFromEnum(value.block_type));
        try StructureSettings.write(stream, value.settings);
        try stream.writeUint8(@intFromEnum(value.redstone_save_mode));
    }

    pub fn read(stream: *BinaryStream) !StructureEditorData {
        const name = try stream.readVarString();
        const filtered_name = try stream.readVarString();
        const data_field = try stream.readVarString();
        const including_players = try stream.readBool();
        const bounding_box_visible = try stream.readBool();
        const block_type_raw = try stream.readZigZag();
        const block_type: StructureBlockType = std.enums.fromInt(StructureBlockType, block_type_raw) orelse .Data;
        const settings = try StructureSettings.read(stream);
        const redstone_save_mode_raw = try stream.readUint8();
        const redstone_save_mode: StructureRedstoneSaveMode = std.enums.fromInt(
            StructureRedstoneSaveMode,
            redstone_save_mode_raw,
        ) orelse .Memory;

        return .{
            .name = name,
            .filtered_name = filtered_name,
            .data_field = data_field,
            .including_players = including_players,
            .bounding_box_visible = bounding_box_visible,
            .block_type = block_type,
            .settings = settings,
            .redstone_save_mode = redstone_save_mode,
        };
    }
};

pub const StructureBlockUpdatePacket = struct {
    position: BlockPosition = BlockPosition.init(0, 0, 0),
    structure_editor_data: StructureEditorData = .{},
    powered: bool = false,

    pub fn serialize(self: *const StructureBlockUpdatePacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.StructureBlockUpdate);
        try BlockPosition.write(stream, self.position);
        try StructureEditorData.write(stream, self.structure_editor_data);
        try stream.writeBool(self.powered);
        return stream.getBuffer();
    }

    pub fn deserialize(stream: *BinaryStream) !StructureBlockUpdatePacket {
        _ = try stream.readVarInt();
        const position = try BlockPosition.read(stream);
        const structure_editor_data = try StructureEditorData.read(stream);
        const powered = try stream.readBool();
        return .{
            .position = position,
            .structure_editor_data = structure_editor_data,
            .powered = powered,
        };
    }
};

const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const InputData = @import("../enums/input-data.zig").InputData;

pub const MAX_INPUT_DATA_FLAGS = 66;

pub const PlayerAuthInputData = struct {
    flags: u128,

    pub fn init(flags: u64) PlayerAuthInputData {
        return PlayerAuthInputData{ .flags = flags };
    }

    pub fn setFlag(self: *PlayerAuthInputData, flag: InputData, value: bool) void {
        const flag_value: u128 = @intFromEnum(flag);
        const flag_bit: u128 = @as(u128, 1) << @intCast(flag_value);

        if (value) {
            self.flags |= flag_bit;
        } else {
            self.flags &= ~flag_bit;
        }
    }

    pub fn hasFlag(self: PlayerAuthInputData, flag: InputData) bool {
        const flag_value: u128 = @intFromEnum(flag);
        const flag_bit: u128 = @as(u128, 1) << @intCast(flag_value);
        return (self.flags & flag_bit) != 0;
    }

    pub fn read(stream: *BinaryStream) !PlayerAuthInputData {
        if (!try stream.readBool()) return error.InvalidDummyOptional;

        var flags: u128 = 0;
        const count = try stream.readVarInt();
        for (0..count) |_| {
            const ordinal = try stream.readZigZag();
            if (ordinal < 0 or ordinal >= MAX_INPUT_DATA_FLAGS) {
                return error.InvalidInputDataFlagOrdinal;
            }
            const shift: u7 = @intCast(ordinal);
            flags |= @as(u128, 1) << shift;
        }

        return PlayerAuthInputData{ .flags = flags };
    }

    pub fn write(stream: *BinaryStream, value: PlayerAuthInputData) !void {
        try stream.writeBool(true);

        var ordinals: [MAX_INPUT_DATA_FLAGS]u8 = undefined;
        var count: u32 = 0;
        var bits = value.flags;
        var i: u8 = 0;

        while (bits != 0 and i < MAX_INPUT_DATA_FLAGS) : (i += 1) {
            if ((bits & 1) != 0) {
                ordinals[count] = i;
                count += 1;
            }
            bits >>= 1;
        }

        try stream.writeVarInt(count);
        for (ordinals[0..count]) |ord| {
            try stream.writeZigZag(ord);
        }
    }
};

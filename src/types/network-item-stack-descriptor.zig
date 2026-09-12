const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const ItemInstanceUserData = @import("item-instance-user-data.zig").ItemInstanceUserData;

pub const NetworkItemStackDescriptor = struct {
    network: i32,
    stack_size: ?u16 = null,
    metadata: ?u32 = null,
    item_stack_id: ?i32 = null,
    network_block_id: ?i32 = null,
    extras: ?ItemInstanceUserData = null,

    pub fn deinit(self: *NetworkItemStackDescriptor, allocator: std.mem.Allocator) void {
        if (self.extras) |*extras| extras.deinit(allocator);
    }

    pub fn skip(stream: *BinaryStream) !void {
        const network = try stream.readZigZag();
        if (network == 0) return;
        _ = try stream.readUint16(.Little);
        _ = try stream.readVarInt();
        if (try stream.readBool()) _ = try stream.readZigZag();
        _ = try stream.readZigZag();
        const length = try stream.readVarInt();
        stream.offset += length;
    }

    pub fn skipShort(stream: *BinaryStream) !void {
        _ = try stream.readShort(.Little);
        _ = try stream.readUint16(.Little);
        _ = try stream.readVarInt();
        if (try stream.readBool()) _ = try stream.readZigZag();
        _ = try stream.readVarInt();
        const length = try stream.readVarInt();
        stream.offset += length;
    }

    pub fn read(stream: *BinaryStream, allocator: std.mem.Allocator) !NetworkItemStackDescriptor {
        const network = try stream.readZigZag();
        if (network == 0) return .{
            .network = network,
            .stack_size = null,
            .metadata = null,
            .item_stack_id = null,
            .network_block_id = null,
            .extras = null,
        };

        const stack_size = try stream.readUint16(.Little);
        const metadata = try stream.readVarInt();
        const item_stack_id: ?i32 = if (try stream.readBool()) try stream.readZigZag() else null;
        const network_block_id = try stream.readZigZag();

        const length = try stream.readVarInt();
        const extras: ?ItemInstanceUserData = if (length > 0) blk: {
            const start = stream.offset;
            const result = ItemInstanceUserData.read(stream, allocator, network) catch {
                stream.offset = start + length;
                break :blk null;
            };
            stream.offset = start + length;
            break :blk result;
        } else null;

        return .{
            .network = network,
            .stack_size = stack_size,
            .metadata = metadata,
            .item_stack_id = item_stack_id,
            .network_block_id = network_block_id,
            .extras = extras,
        };
    }

    pub fn readShort(stream: *BinaryStream, allocator: std.mem.Allocator) !NetworkItemStackDescriptor {
        const network = try stream.readShort(.Little);
        const stack_size = try stream.readUint16(.Little);
        const metadata = try stream.readVarInt();
        const hasNetId = try stream.readBool();
        var item_stack_id: ?i32 = null;
        if (hasNetId) {
            item_stack_id = try stream.readZigZag();
        }
        const network_block_id: i32 = @bitCast(try stream.readVarInt());

        const length = try stream.readVarInt();
        const extras: ?ItemInstanceUserData = if (length > 0) blk: {
            const start = stream.offset;
            const result = ItemInstanceUserData.read(stream, allocator, network) catch {
                stream.offset = start + length;
                break :blk null;
            };
            stream.offset = start + length;
            break :blk result;
        } else null;

        return .{
            .network = network,
            .stack_size = stack_size,
            .metadata = metadata,
            .item_stack_id = item_stack_id,
            .network_block_id = network_block_id,
            .extras = extras,
        };
    }

    pub fn write(stream: *BinaryStream, value: NetworkItemStackDescriptor, allocator: std.mem.Allocator) !void {
        try stream.writeZigZag(value.network);
        if (value.network == 0) return;

        try stream.writeUint16(value.stack_size orelse 0, .Little);
        try stream.writeVarInt(value.metadata orelse 0);

        if (value.item_stack_id) |id| {
            try stream.writeBool(true);
            try stream.writeZigZag(id);
        } else {
            try stream.writeBool(false);
        }

        try stream.writeZigZag(value.network_block_id orelse 0);

        if (value.extras) |extras| {
            var sub = BinaryStream.init(allocator, null, null);
            defer sub.deinit();
            try ItemInstanceUserData.write(&sub, extras, value.network);
            const buf = sub.getBuffer();
            try stream.writeVarInt(@intCast(buf.len));
            try stream.write(buf);
        } else {
            try stream.writeVarInt(0);
        }
    }

    pub fn writeShort(stream: *BinaryStream, value: NetworkItemStackDescriptor, allocator: std.mem.Allocator) !void {
        try stream.writeShort(@intCast(value.network), .Little);
        if (value.network == 0) {
            try stream.writeUint16(0, .Little);
            try stream.writeVarInt(0);
            try stream.writeBool(false);
            try stream.writeZigZag(0);
            try stream.writeVarInt(0);
            return;
        }

        try stream.writeUint16(value.stack_size orelse 0, .Little);
        try stream.writeVarInt(value.metadata orelse 0);

        if (value.item_stack_id) |id| {
            try stream.writeBool(true);
            try stream.writeZigZag(id);
        } else {
            try stream.writeBool(false);
        }

        try stream.writeVarInt(@bitCast(value.network_block_id orelse 0));

        if (value.extras) |extras| {
            var sub = BinaryStream.init(allocator, null, null);
            defer sub.deinit();
            try ItemInstanceUserData.write(&sub, extras, value.network);
            const buf = sub.getBuffer();
            try stream.writeVarInt(@intCast(buf.len));
            try stream.write(buf);
        } else {
            try stream.writeVarInt(0);
        }
    }
};

const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const ItemInstanceUserData = @import("item-instance-user-data.zig").ItemInstanceUserData;

pub const NetworkItemInstanceDescriptor = struct {
    network: i32,
    stack_size: ?u16,
    metadata: ?u32,
    network_block_id: ?i32,
    extras: ?ItemInstanceUserData,

    pub fn read(stream: *BinaryStream, allocator: std.mem.Allocator) !NetworkItemInstanceDescriptor {
        const network = try stream.readZigZag();
        if (network == 0) return .{
            .network = network,
            .stack_size = null,
            .metadata = null,
            .network_block_id = null,
            .extras = null,
        };

        const stack_size = try stream.readUint16(.Little);
        const metadata = try stream.readVarInt();
        const network_block_id = try stream.readZigZag();

        const length = try stream.readVarInt();
        const extras: ?ItemInstanceUserData = if (length > 0)
            try ItemInstanceUserData.read(stream, allocator, network)
        else
            null;

        return .{
            .network = network,
            .stack_size = stack_size,
            .metadata = metadata,
            .network_block_id = network_block_id,
            .extras = extras,
        };
    }

    pub fn write(stream: *BinaryStream, value: NetworkItemInstanceDescriptor, allocator: std.mem.Allocator) !void {
        try stream.writeZigZag(value.network);
        if (value.network == 0) return;

        try stream.writeUint16(value.stack_size orelse 0, .Little);
        try stream.writeVarInt(value.metadata orelse 0);
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
};

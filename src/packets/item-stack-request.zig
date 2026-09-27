const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../root.zig").Packet;
const ItemStackRequestType = @import("../types/item-stack-request.zig");

pub const ItemStackRequest = ItemStackRequestType.ItemStackRequest;
pub const StackRequestAction = ItemStackRequestType.StackRequestAction;
pub const StackRequestSlotInfo = ItemStackRequestType.StackRequestSlotInfo;

pub const ItemStackRequestPacket = struct {
    requests: []ItemStackRequest,

    pub fn deinit(self: *ItemStackRequestPacket, allocator: std.mem.Allocator) void {
        for (self.requests) |*req| {
            req.deinit(allocator);
        }
        allocator.free(self.requests);
    }

    pub fn deserialize(stream: *BinaryStream) !ItemStackRequestPacket {
        _ = try stream.readVarInt();

        const count = try stream.readVarInt();
        var requests = try stream.allocator.alloc(ItemStackRequest, count);
        var parsed: usize = 0;
        errdefer {
            for (requests[0..parsed]) |*req| req.deinit(stream.allocator);
            stream.allocator.free(requests);
        }
        for (0..count) |i| {
            requests[i] = try ItemStackRequest.read(stream, stream.allocator);
            parsed += 1;
        }

        return .{ .requests = requests };
    }
};

const testing = std.testing;

fn writeRequest(w: *BinaryStream, action_type: i32) !void {
    try w.writeZigZag(1);
    try w.writeVarInt(1);
    try w.writeVarInt(@intCast(action_type));
    try w.writeUint8(@intCast(action_type & 0xFF));
    try w.writeVarInt(0);
    try w.writeInt32(0, .Little);
}

test "a request that fails to parse does not strand the ones before it" {
    var wire = BinaryStream.init(testing.allocator, null, null);
    defer wire.deinit();
    try wire.writeVarInt(Packet.ItemStackRequest);
    try wire.writeVarInt(2);
    try writeRequest(&wire, 7);
    try writeRequest(&wire, 999);

    var in = BinaryStream.init(testing.allocator, wire.getBuffer(), 0);
    try testing.expectError(error.UnknownStackRequestActionType, ItemStackRequestPacket.deserialize(&in));
}

test "the requests of a well formed packet are freed by deinit" {
    var wire = BinaryStream.init(testing.allocator, null, null);
    defer wire.deinit();
    try wire.writeVarInt(Packet.ItemStackRequest);
    try wire.writeVarInt(2);
    try writeRequest(&wire, 7);
    try writeRequest(&wire, 16);

    var in = BinaryStream.init(testing.allocator, wire.getBuffer(), 0);
    var packet = try ItemStackRequestPacket.deserialize(&in);
    defer packet.deinit(testing.allocator);

    try testing.expectEqual(@as(usize, 2), packet.requests.len);
    try testing.expectEqual(@as(usize, 1), packet.requests[1].actions.len);
    try testing.expect(packet.requests[1].actions[0] == .craft_non_implemented_deprecated);
}

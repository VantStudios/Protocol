const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;
const Vector3f = @import("../types/vector3f.zig").Vector3f;
const DataItem = @import("../types/data-item.zig").DataItem;
const NetworkItemStackDescriptor = @import("../types/network-item-stack-descriptor.zig").NetworkItemStackDescriptor;
const std = @import("std");

pub const AddItemActorPacket = struct {
    unique_entity_id: i64,
    runtime_entity_id: u64,
    item: NetworkItemStackDescriptor,
    position: Vector3f,
    velocity: Vector3f = Vector3f.init(0, 0, 0),
    entity_metadata: []const DataItem = &[_]DataItem{},
    from_fishing: bool = false,

    pub fn serialize(self: *const AddItemActorPacket, stream: *BinaryStream, allocator: std.mem.Allocator) ![]const u8 {
        try stream.writeVarInt(Packet.AddItemActor);
        try stream.writeZigZong(self.unique_entity_id);
        try stream.writeVarLong(self.runtime_entity_id);
        try NetworkItemStackDescriptor.writeShort(stream, self.item, allocator);
        try Vector3f.write(stream, self.position);
        try Vector3f.write(stream, self.velocity);
        try stream.writeVarInt(@intCast(self.entity_metadata.len));
        for (self.entity_metadata) |item| {
            try item.write(stream);
        }
        try stream.writeUint8(if (self.from_fishing) 1 else 0);
        return stream.getBuffer();
    }
};

const testing = std.testing;

test "add item actor serializes the item as an ItemStackWrapper (2169)" {
    var stream = BinaryStream.init(testing.allocator, null, null);
    defer stream.deinit();

    const packet = AddItemActorPacket{
        .unique_entity_id = -42,
        .runtime_entity_id = 77,
        .item = .{
            .network = 745,
            .stack_size = 3,
            .metadata = 0,
            .item_stack_id = 12345,
            .network_block_id = 179,
            .extras = null,
        },
        .position = Vector3f.init(1, 2, 3),
    };
    const buf = try packet.serialize(&stream, testing.allocator);

    var in = BinaryStream.init(testing.allocator, buf, 0);
    defer in.deinit();
    try testing.expectEqual(Packet.AddItemActor, try in.readVarInt());
    try testing.expectEqual(@as(i64, -42), try in.readZigZong());
    try testing.expectEqual(@as(u64, 77), try in.readVarLong());

    // ItemStackWrapper: id i16 LE, count u16 LE, meta uvarint, optional zigzag
    // net id, unsigned varint block runtime id, extras string.
    try testing.expectEqual(@as(i16, 745), try in.readShort(.Little));
    try testing.expectEqual(@as(u16, 3), try in.readUint16(.Little));
    try testing.expectEqual(@as(u32, 0), try in.readVarInt());
    try testing.expectEqual(true, try in.readBool());
    try testing.expectEqual(@as(i32, 12345), try in.readZigZag());
    try testing.expectEqual(@as(u32, 179), try in.readVarInt());
    try testing.expectEqual(@as(u32, 0), try in.readVarInt());

    _ = try Vector3f.read(&in);
    _ = try Vector3f.read(&in);
    try testing.expectEqual(@as(u32, 0), try in.readVarInt());
    try testing.expectEqual(@as(u8, 0), try in.readUint8());
    try testing.expectEqual(in.offset, buf.len);
}

test "add item actor serializes an empty item as the 8-byte empty wrapper" {
    var stream = BinaryStream.init(testing.allocator, null, null);
    defer stream.deinit();

    const packet = AddItemActorPacket{
        .unique_entity_id = 1,
        .runtime_entity_id = 2,
        .item = .{ .network = 0 },
        .position = Vector3f.zero(),
    };
    const buf = try packet.serialize(&stream, testing.allocator);

    var in = BinaryStream.init(testing.allocator, buf, 0);
    defer in.deinit();
    _ = try in.readVarInt();
    _ = try in.readZigZong();
    _ = try in.readVarLong();

    // id(2) + count(2) + meta(1) + hasNetId(1) + block runtime id(1) + string len(1)
    const wrapper_start = in.offset;
    const expected = [_]u8{0} ** 8;
    try testing.expectEqualSlices(u8, &expected, buf[wrapper_start .. wrapper_start + 8]);
}

const BinaryStream = @import("BinaryStream").BinaryStream;
const FullContainerName = @import("full-container-name.zig").FullContainerName;
const StackResponseSlotInfo = @import("stack-response-slot-info.zig").StackResponseSlotInfo;

pub const StackResponseContainerInfo = struct {
    container: FullContainerName,
    slot_info: []const StackResponseSlotInfo,

    pub fn write(stream: *BinaryStream, value: StackResponseContainerInfo) !void {
        try FullContainerName.write(stream, value.container);
        try stream.writeVarInt(@intCast(value.slot_info.len));
        for (value.slot_info) |slot_info| {
            try StackResponseSlotInfo.write(stream, slot_info);
        }
    }
};

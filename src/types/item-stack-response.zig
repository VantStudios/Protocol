const BinaryStream = @import("BinaryStream").BinaryStream;

const ItemStackResponseStatus = @import("../enums/item-stack-response-status.zig").ItemStackResponseStatus;
const StackResponseContainerInfo = @import("stack-response-container-info.zig").StackResponseContainerInfo;

pub const ItemStackResponse = struct {
    status: ItemStackResponseStatus,
    request_id: i32,
    container_info: []const StackResponseContainerInfo,

    pub fn write(stream: *BinaryStream, value: ItemStackResponse) !void {
        try stream.writeUint8(@intFromEnum(value.status));
        try stream.writeZigZag(value.request_id);

        if (value.container_info.len > 0) {
            try stream.writeBool(true);
            try stream.writeVarInt(@intCast(value.container_info.len));
            for (value.container_info) |container_info| {
                try StackResponseContainerInfo.write(stream, container_info);
            }
        } else {
            try stream.writeBool(false);
        }
    }
};

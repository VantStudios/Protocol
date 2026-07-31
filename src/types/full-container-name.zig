const BinaryStream = @import("BinaryStream").BinaryStream;
const ContainerName = @import("../enums/container-name.zig").ContainerName;

pub const FullContainerName = struct {
    identifier: ContainerName,
    dynamic_identifier: ?u32,

    pub fn init(identifier: ContainerName, dynamic_identifier: ?u32) FullContainerName {
        return FullContainerName{ .identifier = identifier, .dynamic_identifier = dynamic_identifier };
    }

    pub fn isLegacy(self: FullContainerName) bool {
        return self.identifier == .AnvilInput and
            (self.dynamic_identifier == null or self.dynamic_identifier == 0);
    }

    pub fn legacy() FullContainerName {
        return .{
            .identifier = .AnvilInput,
            .dynamic_identifier = 0,
        };
    }

    pub fn read(stream: *BinaryStream) !FullContainerName {
        const identifier: ContainerName = @enumFromInt(try stream.readUint8());
        const isDynamic = try stream.readBool();
        const dynamic_identifier: ?u32 = if (isDynamic) try stream.readUint32(.Little) else null;
        return FullContainerName{ .identifier = identifier, .dynamic_identifier = dynamic_identifier };
    }

    pub fn write(stream: *BinaryStream, value: FullContainerName) !void {
        try stream.writeUint8(@intFromEnum(value.identifier));
        if (value.dynamic_identifier) |dynId| {
            try stream.writeBool(true);
            try stream.writeUint32(dynId, .Little);
        } else {
            try stream.writeBool(false);
        }
    }
};

const std = @import("std");
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
        const identifier_raw = try stream.readUint8();
        const identifier: ContainerName = std.enums.fromInt(ContainerName, identifier_raw) orelse return error.UnknownContainerName;
        const dynamic_identifier = try stream.readUint32(.Little);
        return FullContainerName{ .identifier = identifier, .dynamic_identifier = dynamic_identifier };
    }

    pub fn write(stream: *BinaryStream, value: FullContainerName) !void {
        try stream.writeUint8(@intFromEnum(value.identifier));
        try stream.writeUint32(value.dynamic_identifier orelse 0, .Little);
    }
};

# Protocol

Minecraft Bedrock protocol library for Zig 0.16.0.

## Installation

Add the dependency with `zig fetch`:

```sh
zig fetch --save git+https://github.com/VantStudios/Protocol.git
```

Then in your `build.zig`:

```zig
const protocol_dep = b.dependency("protocol", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("Protocol", protocol_dep.module("Protocol"));
```

## Usage

```zig
const std = @import("std");
const protocol = @import("Protocol");
const BinaryStream = @import("BinaryStream").BinaryStream;

fn serializePacket(gpa: std.mem.Allocator) ![]u8 {
    var packet = protocol.TextPacket{
        .text_type = .Raw,
        .message = "Hello, world!",
    };

    var stream = BinaryStream.init(gpa, null, null);
    defer stream.deinit();

    const payload = try packet.serialize(&stream);

    // Dupe the buffer slice before the stream is deallocated.
    return try gpa.dupe(u8, payload);
}

fn deserializePacket(gpa: std.mem.Allocator, bytes: []const u8) !protocol.TextPacket {
    var stream = BinaryStream.init(gpa, bytes, null);
    defer stream.deinit();

    return try protocol.TextPacket.deserialize(&stream);
}

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    // 1. Create and serialize the packet into bytes.
    const bytes = try serializePacket(gpa);
    defer gpa.free(bytes);

    // 2. Deserialize the packet back from the payload.
    const received = try deserializePacket(gpa, bytes);

    std.debug.print("{s}\n", .{received.message});
}
```

> Note: Deserialized strings are zero-copy slices pointing into `bytes` and are not allocated. Keep `bytes` alive while using the packet.

## License

[MIT](LICENCE)

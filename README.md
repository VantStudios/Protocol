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
const protocol = @import("Protocol");
```

## License

[MIT](LICENCE)

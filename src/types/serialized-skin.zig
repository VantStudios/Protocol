const std = @import("std");

const BinaryStream = @import("BinaryStream").BinaryStream;

const ClientData = @import("../login/types.zig").ClientData;
const SkinAnimation = @import("../login/types.zig").SkinAnimation;
const Uuid = @import("uuid.zig").Uuid;

pub const SerializedSkin = struct {
    pub fn write(stream: *BinaryStream, skin: *const ClientData, allocator: std.mem.Allocator) !void {
        try stream.writeVarString(skin.skin_id);
        try stream.writeVarString(skin.play_fab_id);

        try writeBase64Decoded(stream, skin.skin_resource_patch, allocator);

        try writeSkinImage(stream, skin.skin_image_width, skin.skin_image_height, skin.skin_data, allocator);

        try stream.writeVarInt(@intCast(skin.animated_image_data.len));
        for (skin.animated_image_data) |anim| {
            try writeAnimation(stream, &anim, allocator);
        }

        try writeSkinImage(stream, skin.cape_image_width, skin.cape_image_height, skin.cape_data, allocator);

        try writeBase64Decoded(stream, skin.skin_geometry_data, allocator);
        try writeBase64Decoded(stream, skin.skin_geometry_data_engine_version, allocator);

        try stream.writeVarString(skin.skin_animation_data);
        try stream.writeVarString(skin.cape_id);
        try stream.writeVarString("");

        try stream.writeUint8(if (std.ascii.eqlIgnoreCase(skin.arm_size, "slim")) 0 else 1);
        try stream.writeInt32(@bitCast(parseHexColor(skin.skin_color)), .Little);

        try stream.writeVarInt(@intCast(skin.persona_pieces.len));
        for (skin.persona_pieces) |piece| {
            try stream.writeVarString(piece.piece_id);
            try stream.writeInt32(@bitCast(pieceTypeOrdinal(piece.piece_type)), .Little);
            // A malformed pack id must not abort the whole skin packet; write
            // a nil UUID instead.
            writePackId(stream, piece.pack_id) catch {
                try stream.write(&[_]u8{0} ** 16);
            };
            try stream.writeBool(piece.is_default);
            try stream.writeVarString(piece.product_id);
        }

        try stream.writeVarInt(@intCast(skin.piece_tint_colors.len));
        for (skin.piece_tint_colors) |tint| {
            try stream.writeVarString(tint.piece_type);
            for (tint.colors) |colour| {
                try stream.writeInt32(@bitCast(parseHexColor(colour)), .Little);
            }
        }

        try stream.writeBool(skin.premium_skin);
        try stream.writeBool(skin.persona_skin);
        try stream.writeBool(skin.cape_on_classic_skin);
        try stream.writeBool(true);
        try stream.writeBool(true);

        try stream.writeVarString(if (skin.trusted_skin) "true" else "false");

        try stream.writeVarString(skin.profile_hash);
    }

    fn writeAnimation(stream: *BinaryStream, anim: *const SkinAnimation, allocator: std.mem.Allocator) !void {
        try stream.writeUint32(@intCast(anim.image_width), .Little);
        try stream.writeUint32(@intCast(anim.image_height), .Little);
        const decoded = try decodeBase64String(allocator, anim.image);
        defer allocator.free(decoded);
        try stream.writeVarInt(@intCast(decoded.len));
        try stream.write(decoded);
        try stream.writeVarInt(@intCast(anim.animation_type));
        try stream.writeFloat32(@floatCast(anim.frames), .Little);
        try stream.writeVarInt(@intCast(anim.expression_type));
    }

    fn writeSkinImage(stream: *BinaryStream, width: i64, height: i64, data: []const u8, allocator: std.mem.Allocator) !void {
        try stream.writeUint32(@intCast(width), .Little);
        try stream.writeUint32(@intCast(height), .Little);
        if (data.len == 0) {
            try stream.writeVarInt(0);
            return;
        }
        const decoded = try decodeBase64String(allocator, data);
        defer allocator.free(decoded);
        try stream.writeVarInt(@intCast(decoded.len));
        try stream.write(decoded);
    }

    fn writeBase64Decoded(stream: *BinaryStream, data: []const u8, allocator: std.mem.Allocator) !void {
        if (data.len == 0) {
            try stream.writeVarInt(0);
            return;
        }
        const decoded = try decodeBase64String(allocator, data);
        defer allocator.free(decoded);
        try stream.writeVarString(decoded);
    }

    fn decodeBase64String(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
        if (data.len == 0) {
            return try allocator.alloc(u8, 0);
        }
        if (std.base64.standard.Decoder.calcSizeForSlice(data)) |decoded_len| {
            const decoded = try allocator.alloc(u8, decoded_len);
            if (std.base64.standard.Decoder.decode(decoded, data)) |_| {
                return decoded;
            } else |_| {
                allocator.free(decoded);
            }
        } else |_| {}
        if (std.base64.standard_no_pad.Decoder.calcSizeForSlice(data)) |decoded_len| {
            const decoded = try allocator.alloc(u8, decoded_len);
            if (std.base64.standard_no_pad.Decoder.decode(decoded, data)) |_| {
                return decoded;
            } else |_| {
                allocator.free(decoded);
            }
        } else |_| {}
        std.log.warn("[SKIN-B64] fallback to raw, len={d}", .{data.len});
        return try allocator.dupe(u8, data);
    }
};

/// Converts a login-data hex colour into the ARGB integer the skin codec
/// writes. SkinColor is "#rrggbb" while tint colors are ARGB ("#ffa12722")
/// and may omit leading digits entirely ("#0").
fn parseHexColor(hex: []const u8) u32 {
    var digits: []const u8 = hex;
    if (digits.len > 0 and digits[0] == '#') {
        digits = digits[1..];
    }

    const value = std.fmt.parseInt(u32, digits, 16) catch return 0;
    return value;
}

fn writePackId(stream: *BinaryStream, pack_id: []const u8) !void {
    if (pack_id.len == 36 or pack_id.len == 16) {
        try Uuid.write(stream, pack_id);
        return;
    }
    return error.InvalidUuidLength;
}

const PersonaPieceTypeEntry = struct { name: []const u8, ordinal: u32 };

const persona_piece_types = [_]PersonaPieceTypeEntry{
    .{ .name = "unknown", .ordinal = 0 },
    .{ .name = "skeleton", .ordinal = 1 },
    .{ .name = "body", .ordinal = 2 },
    .{ .name = "skin", .ordinal = 3 },
    .{ .name = "bottom", .ordinal = 4 },
    .{ .name = "feet", .ordinal = 5 },
    .{ .name = "dress", .ordinal = 6 },
    .{ .name = "top", .ordinal = 7 },
    .{ .name = "high_pants", .ordinal = 8 },
    .{ .name = "hands", .ordinal = 9 },
    .{ .name = "outerwear", .ordinal = 10 },
    .{ .name = "facialhair", .ordinal = 11 },
    .{ .name = "mouth", .ordinal = 12 },
    .{ .name = "eyes", .ordinal = 13 },
    .{ .name = "hair", .ordinal = 14 },
    .{ .name = "hood", .ordinal = 15 },
    .{ .name = "back", .ordinal = 16 },
    .{ .name = "faceaccessory", .ordinal = 17 },
    .{ .name = "head", .ordinal = 18 },
    .{ .name = "legs", .ordinal = 19 },
    .{ .name = "leftleg", .ordinal = 20 },
    .{ .name = "rightleg", .ordinal = 21 },
    .{ .name = "arms", .ordinal = 22 },
    .{ .name = "leftarm", .ordinal = 23 },
    .{ .name = "rightarm", .ordinal = 24 },
    .{ .name = "capes", .ordinal = 25 },
    .{ .name = "classicskin", .ordinal = 26 },
    .{ .name = "emote", .ordinal = 27 },
    .{ .name = "unsupported", .ordinal = 28 },
};

fn pieceTypeOrdinal(name: []const u8) u32 {
    var short: []const u8 = name;
    if (std.mem.startsWith(u8, name, "persona_")) {
        short = name["persona_".len..];
    }
    // Login data uses the singular "hand" where the wire name is plural.
    if (std.mem.eql(u8, short, "hand")) {
        short = "hands";
    }
    for (persona_piece_types) |entry| {
        if (std.mem.eql(u8, short, entry.name)) {
            return entry.ordinal;
        }
    }
    return 0;
}

test "parseHexColor keeps six digit rgb with alpha 0 like pmmp" {
    try std.testing.expectEqual(@as(u32, 0x00B37B62), parseHexColor("#b37b62"));
    try std.testing.expectEqual(@as(u32, 0xFFA12722), parseHexColor("#ffa12722"));
    try std.testing.expectEqual(@as(u32, 0), parseHexColor("#0"));
    try std.testing.expectEqual(@as(u32, 0), parseHexColor(""));
}

test "pieceTypeOrdinal maps login names to wire ordinals" {
    try std.testing.expectEqual(@as(u32, 13), pieceTypeOrdinal("persona_eyes"));
    try std.testing.expectEqual(@as(u32, 13), pieceTypeOrdinal("eyes"));
    try std.testing.expectEqual(@as(u32, 9), pieceTypeOrdinal("persona_hand"));
    try std.testing.expectEqual(@as(u32, 28), pieceTypeOrdinal("unsupported"));
}

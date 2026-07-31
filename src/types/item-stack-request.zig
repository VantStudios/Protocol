const std = @import("std");
const BinaryStream = @import("BinaryStream").BinaryStream;
const FullContainerName = @import("full-container-name.zig").FullContainerName;
pub const StackRequestActionType = @import("../enums/stack-request-action-type.zig").StackRequestActionType;

pub const StackRequestSlotInfo = struct {
    container: FullContainerName,
    slot: u8,
    stack_network_id: i32,
};

pub const TransferAction = struct {
    count: u8,
    source: StackRequestSlotInfo,
    destination: StackRequestSlotInfo,
};

pub const DropAction = struct {
    count: u8,
    source: StackRequestSlotInfo,
    randomly: bool,
};

pub const DestroyAction = struct {
    count: u8,
    source: StackRequestSlotInfo,
};

pub const CreateAction = struct {
    results_slot: u8,
};

pub const BeaconPaymentAction = struct {
    primary_effect: i32,
    secondary_effect: i32,
};

pub const MineBlockAction = struct {
    hotbar_slot: i32,
    predicted_durability: i32,
    stack_network_id: i32,
};

pub const CraftRecipeAction = struct {
    recipe_network_id: u32,
    number_of_crafts: u8,
};

pub const CraftCreativeAction = struct {
    creative_item_network_id: u32,
    number_of_crafts: u8,
};

pub const CraftRecipeOptionalAction = struct {
    recipe_network_id: u32,
    filter_string_index: i32,
};

pub const CraftGrindstoneAction = struct {
    recipe_network_id: u32,
    number_of_crafts: u8,
    cost: i32,
};

pub const CraftLoomAction = struct {
    pattern: []const u8,
    times_crafted: u8,
};

pub const StackRequestAction = union(enum) {
    take: TransferAction,
    place: TransferAction,
    swap: struct { source: StackRequestSlotInfo, destination: StackRequestSlotInfo },
    drop: DropAction,
    destroy: DestroyAction,
    consume: DestroyAction,
    create: CreateAction,
    place_in_container: TransferAction,
    take_out_container: TransferAction,
    lab_table_combine: void,
    beacon_payment: BeaconPaymentAction,
    mine_block: MineBlockAction,
    craft_recipe: CraftRecipeAction,
    craft_recipe_auto: CraftRecipeAction,
    craft_creative: CraftCreativeAction,
    craft_recipe_optional: CraftRecipeOptionalAction,
    craft_grindstone: CraftGrindstoneAction,
    craft_loom: CraftLoomAction,
    craft_non_implemented_deprecated: void,
    craft_results_deprecated: void,
    unknown: void,
};

pub const ItemStackRequest = struct {
    request_id: i32,
    actions: []StackRequestAction,
    filter_strings: [][]const u8,
    filter_cause: i32,

    pub fn skip(stream: *BinaryStream) !void {
        _ = try stream.readZigZag();
        const action_count = try stream.readVarInt();
        for (0..action_count) |_| {
            try skipAction(stream);
        }
        const filter_count = try stream.readVarInt();
        for (0..filter_count) |_| {
            _ = try stream.readVarString();
        }
        _ = try stream.readInt32(.Little);
    }

    pub fn read(stream: *BinaryStream, allocator: std.mem.Allocator) !ItemStackRequest {
        const request_id = try stream.readZigZag();
        const action_count = try stream.readVarInt();
        var actions = try allocator.alloc(StackRequestAction, action_count);
        for (0..action_count) |i| {
            actions[i] = try readAction(stream);
        }
        const filter_count = try stream.readVarInt();
        var filter_strings = try allocator.alloc([]const u8, filter_count);
        for (0..filter_count) |i| {
            filter_strings[i] = try stream.readVarString();
        }
        const filter_cause = try stream.readInt32(.Little);
        return .{
            .request_id = request_id,
            .actions = actions,
            .filter_strings = filter_strings,
            .filter_cause = filter_cause,
        };
    }
};

fn readSlotInfo(stream: *BinaryStream) !StackRequestSlotInfo {
    const container = try FullContainerName.read(stream);
    const slot = try stream.readUint8();
    const stack_network_id = try stream.readZigZag();
    return .{ .container = container, .slot = slot, .stack_network_id = stack_network_id };
}

fn readTransferAction(stream: *BinaryStream) !TransferAction {
    const count = try stream.readUint8();
    const source = try readSlotInfo(stream);
    const destination = try readSlotInfo(stream);
    return .{ .count = count, .source = source, .destination = destination };
}

fn readAction(stream: *BinaryStream) !StackRequestAction {
    const action_type: StackRequestActionType = @enumFromInt(try stream.readUint8());
    return switch (action_type) {
        .Take => .{ .take = try readTransferAction(stream) },
        .Place => .{ .place = try readTransferAction(stream) },
        .Swap => {
            const source = try readSlotInfo(stream);
            const destination = try readSlotInfo(stream);
            return .{ .swap = .{ .source = source, .destination = destination } };
        },
        .Drop => {
            const count = try stream.readUint8();
            const source = try readSlotInfo(stream);
            const randomly = try stream.readBool();
            return .{ .drop = .{ .count = count, .source = source, .randomly = randomly } };
        },
        .Destroy => {
            const count = try stream.readUint8();
            const source = try readSlotInfo(stream);
            return .{ .destroy = .{ .count = count, .source = source } };
        },
        .Consume => {
            const count = try stream.readUint8();
            const source = try readSlotInfo(stream);
            return .{ .consume = .{ .count = count, .source = source } };
        },
        .Create => .{ .create = .{ .results_slot = try stream.readUint8() } },
        .PlaceInContainer => .{ .place_in_container = try readTransferAction(stream) },
        .TakeOutContainer => .{ .take_out_container = try readTransferAction(stream) },
        .LabTableCombine => .{ .lab_table_combine = {} },
        .BeaconPayment => .{ .beacon_payment = .{
            .primary_effect = try stream.readZigZag(),
            .secondary_effect = try stream.readZigZag(),
        } },
        .MineBlock => .{ .mine_block = .{
            .hotbar_slot = try stream.readZigZag(),
            .predicted_durability = try stream.readZigZag(),
            .stack_network_id = try stream.readZigZag(),
        } },
        .CraftRecipe => .{ .craft_recipe = .{
            .recipe_network_id = try stream.readVarInt(),
            .number_of_crafts = try stream.readUint8(),
        } },
        .CraftRecipeAuto => blk: {
            const rid = try stream.readVarInt();
            const nc = try stream.readUint8();
            _ = try stream.readUint8();
            const ic = try stream.readVarInt();
            for (0..ic) |_| try skipItemDescriptorCount(stream);
            break :blk .{ .craft_recipe_auto = .{ .recipe_network_id = rid, .number_of_crafts = nc } };
        },
        .CraftCreative => .{ .craft_creative = .{
            .creative_item_network_id = try stream.readVarInt(),
            .number_of_crafts = try stream.readUint8(),
        } },
        .CraftRecipeOptional => .{ .craft_recipe_optional = .{
            .recipe_network_id = try stream.readVarInt(),
            .filter_string_index = try stream.readInt32(.Little),
        } },
        .CraftGrindstone => .{ .craft_grindstone = .{
            .recipe_network_id = try stream.readVarInt(),
            .number_of_crafts = try stream.readUint8(),
            .cost = try stream.readZigZag(),
        } },
        .CraftLoom => .{ .craft_loom = .{
            .pattern = try stream.readVarString(),
            .times_crafted = try stream.readUint8(),
        } },
        .CraftNonImplementedDeprecated => .{ .craft_non_implemented_deprecated = {} },
        .CraftResultsDeprecated => blk: {
            const c = try stream.readVarInt();
            for (0..c) |_| try skipItemStack(stream);
            _ = try stream.readUint8();
            break :blk .{ .craft_results_deprecated = {} };
        },
        _ => .{ .unknown = {} },
    };
}

fn skipAction(stream: *BinaryStream) !void {
    const action_type = try stream.readUint8();
    switch (action_type) {
        0, 1, 7, 8 => try skipTransferAction(stream),
        2 => {
            try skipSlotInfo(stream);
            try skipSlotInfo(stream);
        },
        3 => try skipDropAction(stream),
        4, 5 => try skipDestroyAction(stream),
        6 => _ = try stream.readUint8(),
        9 => {},
        10 => {
            _ = try stream.readZigZag();
            _ = try stream.readZigZag();
        },
        11 => {
            _ = try stream.readZigZag();
            _ = try stream.readZigZag();
            _ = try stream.readZigZag();
        },
        12 => {
            _ = try stream.readVarInt();
            _ = try stream.readUint8();
        },
        13 => {
            _ = try stream.readVarInt();
            _ = try stream.readUint8();
            _ = try stream.readUint8();
            const c = try stream.readVarInt();
            for (0..c) |_| try skipItemDescriptorCount(stream);
        },
        14 => {
            _ = try stream.readVarInt();
            _ = try stream.readUint8();
        },
        15 => {
            _ = try stream.readVarInt();
            _ = try stream.readInt32(.Little);
        },
        16 => {
            _ = try stream.readVarInt();
            _ = try stream.readUint8();
            _ = try stream.readZigZag();
        },
        17 => {
            _ = try stream.readVarString();
            _ = try stream.readUint8();
        },
        18 => {},
        19 => {
            const c = try stream.readVarInt();
            for (0..c) |_| try skipItemStack(stream);
            _ = try stream.readUint8();
        },
        else => {},
    }
}

fn skipSlotInfo(stream: *BinaryStream) !void {
    _ = try FullContainerName.read(stream);
    _ = try stream.readUint8();
    _ = try stream.readZigZag();
}

fn skipTransferAction(stream: *BinaryStream) !void {
    _ = try stream.readUint8();
    try skipSlotInfo(stream);
    try skipSlotInfo(stream);
}

fn skipDropAction(stream: *BinaryStream) !void {
    _ = try stream.readUint8();
    try skipSlotInfo(stream);
    _ = try stream.readBool();
}

fn skipDestroyAction(stream: *BinaryStream) !void {
    _ = try stream.readUint8();
    try skipSlotInfo(stream);
}

fn skipItemDescriptorCount(stream: *BinaryStream) !void {
    const dt = try stream.readUint8();
    switch (dt) {
        0 => {},
        1 => {
            _ = try stream.readInt16(.Little);
            _ = try stream.readInt16(.Little);
        },
        2 => {
            _ = try stream.readVarString();
            _ = try stream.readInt16(.Little);
        },
        3, 4 => _ = try stream.readVarString(),
        5 => {
            _ = try stream.readVarString();
            _ = try stream.readUint8();
        },
        6 => _ = try stream.readZigZag(),
        else => {},
    }
    _ = try stream.readZigZag();
}

fn skipItemStack(stream: *BinaryStream) !void {
    const nid = try stream.readZigZag();
    if (nid == 0) return;
    _ = try stream.readUint16(.Little);
    _ = try stream.readVarInt();
    _ = try stream.readZigZag();
    const el = try stream.readVarInt();
    for (0..el) |_| _ = try stream.readUint8();
}

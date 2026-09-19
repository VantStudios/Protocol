const std = @import("std");

pub const block_permutations_json = @embedFile("json/block_permutations.json");
pub const block_types_json = @embedFile("json/block_types.json");
pub const block_states_json = @embedFile("json/block_states.json");
pub const block_drops_json = @embedFile("json/block_drops.json");
pub const block_metadata_json = @embedFile("json/block_metadata.json");
pub const biome_types_json = @embedFile("json/biome_types.json");
pub const biome_definitions_vanilla_json = @embedFile("json/biome_definitions_vanilla.json");
pub const entity_types_json = @embedFile("json/entity_types.json");
pub const item_types_json = @embedFile("json/item_types.json");
pub const item_metadata_json = @embedFile("json/item_metadata.json");
pub const creative_content_json = @embedFile("json/creative_content.json");
pub const creative_groups_json = @embedFile("json/creative_groups.json");
pub const shaped_json = @embedFile("json/shaped.json");
pub const shapeless_json = @embedFile("json/shapeless.json");
pub const tool_types_json = @embedFile("json/tool_types.json");
pub const jigsaw_structures_data_nbt = @embedFile("json/jigsaw_structures_data.nbt");
pub const data_driven_blocks_nbt = @embedFile("json/data_driven_blocks.nbt");
pub const voxel_shapes_json = @embedFile("json/voxel_shapes.json");

pub const BlockPermutationLoader = @import("loaders/block-permutation-loader.zig").BlockPermutationLoader;

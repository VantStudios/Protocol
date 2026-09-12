const std = @import("std");

/// Sound events are serialized as their wire string since protocol 2169; the
/// variant names below are the wire strings with "." replaced by "_".
pub const SoundEvent = enum {
    item_use_on,
    hit,
    step,
    fly,
    jump,
    @"break",
    place,
    heavy_step,
    gallop,
    fall,
    ambient,
    ambient_baby,
    ambient_in_water,
    breathe,
    death,
    death_in_water,
    death_to_zombie,
    hurt,
    hurt_in_water,
    mad,
    boost,
    bow,
    squish_big,
    squish_small,
    fall_big,
    fall_small,
    splash,
    fizz,
    flap,
    swim,
    drink,
    eat,
    takeoff,
    shake,
    plop,
    land,
    saddle,
    armor,
    mob_armor_stand_place,
    add_chest,
    throw,
    attack,
    attack_nodamage,
    attack_strong,
    warn,
    shear,
    milk,
    thunder,
    explode,
    fire,
    ignite,
    fuse,
    stare,
    spawn,
    shoot,
    break_block,
    launch,
    blast,
    large_blast,
    twinkle,
    remedy,
    unfect,
    levelup,
    bow_hit,
    bullet_hit,
    extinguish_fire,
    item_fizz,
    chest_open,
    chest_closed,
    shulkerbox_open,
    shulkerbox_closed,
    enderchest_open,
    enderchest_closed,
    power_on,
    power_off,
    attach,
    detach,
    deny,
    tripod,
    pop,
    drop_slot,
    note,
    thorns,
    piston_in,
    piston_out,
    portal,
    water,
    lava_pop,
    lava,
    burp,
    bucket_fill_water,
    bucket_fill_lava,
    bucket_empty_water,
    bucket_empty_lava,
    armor_equip_chain,
    armor_equip_diamond,
    armor_equip_generic,
    armor_equip_gold,
    armor_equip_iron,
    armor_equip_leather,
    armor_equip_elytra,
    record_13,
    record_cat,
    record_blocks,
    record_chirp,
    record_far,
    record_mall,
    record_mellohi,
    record_stal,
    record_strad,
    record_ward,
    record_11,
    record_wait,
    record_null,
    flop,
    elderguardian_curse,
    mob_warning,
    mob_warning_baby,
    teleport,
    shulker_open,
    shulker_close,
    haggle,
    haggle_yes,
    haggle_no,
    haggle_idle,
    chorusgrow,
    chorusdeath,
    glass,
    potion_brewed,
    cast_spell,
    prepare_attack,
    prepare_summon,
    prepare_wololo,
    fang,
    charge,
    camera_take_picture,
    leashknot_place,
    leashknot_break,
    growl,
    whine,
    pant,
    purr,
    purreow,
    death_min_volume,
    death_mid_volume,
    imitate_blaze,
    imitate_cave_spider,
    imitate_creeper,
    imitate_elder_guardian,
    imitate_ender_dragon,
    imitate_enderman,
    imitate_endermite,
    imitate_evocation_illager,
    imitate_ghast,
    imitate_husk,
    imitate_magma_cube,
    imitate_polar_bear,
    imitate_shulker,
    imitate_silverfish,
    imitate_skeleton,
    imitate_slime,
    imitate_spider,
    imitate_stray,
    imitate_vex,
    imitate_vindication_illager,
    imitate_witch,
    imitate_wither,
    imitate_wither_skeleton,
    imitate_wolf,
    imitate_zombie,
    imitate_zombie_pigman,
    imitate_zombie_villager,
    block_end_portal_frame_fill,
    block_end_portal_spawn,
    random_anvil_use,
    bottle_dragonbreath,
    portal_travel,
    item_trident_hit,
    item_trident_return,
    item_trident_riptide_1,
    item_trident_riptide_2,
    item_trident_riptide_3,
    item_trident_throw,
    item_trident_thunder,
    item_trident_hit_ground,
    default,
    block_fletching_table_use,
    elemconstruct_open,
    icebomb_hit,
    balloonpop,
    lt_reaction_icebomb,
    lt_reaction_bleach,
    lt_reaction_epaste,
    lt_reaction_epaste2,
    lt_reaction_glow_stick,
    lt_reaction_glow_stick_2,
    lt_reaction_luminol,
    lt_reaction_salt,
    lt_reaction_fertilizer,
    lt_reaction_fireball,
    lt_reaction_mgsalt,
    lt_reaction_miscfire,
    lt_reaction_fire,
    lt_reaction_miscexplosion,
    lt_reaction_miscmystical,
    lt_reaction_miscmystical2,
    lt_reaction_product,
    sparkler_use,
    glowstick_use,
    sparkler_active,
    convert_to_drowned,
    bucket_fill_fish,
    bucket_empty_fish,
    bubble_up,
    bubble_down,
    bubble_pop,
    bubble_upinside,
    bubble_downinside,
    hurt_baby,
    death_baby,
    step_baby,
    spawn_baby,
    born,
    block_turtle_egg_break,
    block_turtle_egg_crack,
    block_turtle_egg_hatch,
    lay_egg,
    block_turtle_egg_attack,
    beacon_activate,
    beacon_ambient,
    beacon_deactivate,
    beacon_power,
    conduit_activate,
    conduit_ambient,
    conduit_attack,
    conduit_deactivate,
    conduit_short,
    swoop,
    block_bamboo_sapling_place,
    presneeze,
    sneeze,
    ambient_tame,
    scared,
    block_scaffolding_climb,
    crossbow_loading_start,
    crossbow_loading_middle,
    crossbow_loading_end,
    crossbow_shoot,
    crossbow_quick_charge_start,
    crossbow_quick_charge_middle,
    crossbow_quick_charge_end,
    ambient_aggressive,
    ambient_worried,
    cant_breed,
    item_shield_block,
    item_book_put,
    block_grindstone_use,
    block_bell_hit,
    block_campfire_crackle,
    roar,
    stun,
    block_sweet_berry_bush_hurt,
    block_sweet_berry_bush_pick,
    block_cartography_table_use,
    block_stonecutter_use,
    block_composter_empty,
    block_composter_fill,
    block_composter_fill_success,
    block_composter_ready,
    block_barrel_open,
    block_barrel_close,
    raid_horn,
    block_loom_use,
    ambient_in_raid,
    ui_cartography_table_take_result,
    ui_stonecutter_take_result,
    ui_loom_take_result,
    block_smoker_smoke,
    block_blastfurnace_fire_crackle,
    block_smithing_table_use,
    screech,
    sleep,
    block_furnace_lit,
    convert_mooshroom,
    milk_suspiciously,
    celebrate,
    jump_prevent,
    ambient_pollinate,
    block_beehive_drip,
    block_beehive_enter,
    block_beehive_exit,
    block_beehive_work,
    block_beehive_shear,
    drink_honey,
    ambient_cave,
    retreat,
    converted_to_zombified,
    admire,
    step_lava,
    tempt,
    panic,
    angry,
    ambient_warped_forest_mood,
    ambient_soulsand_valley_mood,
    ambient_nether_wastes_mood,
    ambient_basalt_deltas_mood,
    ambient_crimson_forest_mood,
    respawn_anchor_charge,
    respawn_anchor_deplete,
    respawn_anchor_set_spawn,
    respawn_anchor_ambient,
    particle_soul_escape_quiet,
    particle_soul_escape_loud,
    record_pigstep,
    lodestone_compass_link_compass_to_lodestone,
    smithing_table_use,
    armor_equip_netherite,
    ambient_warped_forest_loop,
    ambient_soulsand_valley_loop,
    ambient_nether_wastes_loop,
    ambient_basalt_deltas_loop,
    ambient_crimson_forest_loop,
    ambient_warped_forest_additions,
    ambient_soulsand_valley_additions,
    ambient_nether_wastes_additions,
    ambient_basalt_deltas_additions,
    ambient_crimson_forest_additions,
    power_on_sculk_sensor,
    power_off_sculk_sensor,
    bucket_fill_powder_snow,
    bucket_empty_powder_snow,
    cauldron_drip_water_pointed_dripstone,
    cauldron_drip_lava_pointed_dripstone,
    drip_water_pointed_dripstone,
    drip_lava_pointed_dripstone,
    pick_berries_cave_vines,
    tilt_down_big_dripleaf,
    tilt_up_big_dripleaf,
    copper_wax_on,
    copper_wax_off,
    scrape,
    mob_player_hurt_drown,
    mob_player_hurt_on_fire,
    mob_player_hurt_freeze,
    item_spyglass_use,
    item_spyglass_stop_using,
    chime_amethyst_block,
    ambient_screamer,
    hurt_screamer,
    death_screamer,
    milk_screamer,
    jump_to_block,
    pre_ram,
    pre_ram_screamer,
    ram_impact,
    ram_impact_screamer,
    squid_ink_squirt,
    glow_squid_ink_squirt,
    convert_to_stray,
    cake_add_candle,
    extinguish_candle,
    ambient_candle,
    block_click,
    block_click_fail,
    block_sculk_catalyst_bloom,
    block_sculk_shrieker_shriek,
    nearby_close,
    nearby_closer,
    nearby_closest,
    agitated,
    record_otherside,
    tongue,
    irongolem_crack,
    irongolem_repair,
    listening,
    heartbeat,
    horn_break,
    block_sculk_spread,
    charge_sculk,
    block_sculk_sensor_place,
    block_sculk_shrieker_place,
    horn_call0,
    horn_call1,
    horn_call2,
    horn_call3,
    horn_call4,
    horn_call5,
    horn_call6,
    horn_call7,
    imitate_warden,
    listening_angry,
    item_given,
    item_taken,
    disappeared,
    reappeared,
    drink_milk,
    block_frog_spawn_hatch,
    lay_spawn,
    block_frog_spawn_break,
    sonic_boom,
    sonic_charge,
    item_thrown,
    record_5,
    convert_to_frog,
    block_enchanting_table_use,
    step_sand,
    dash_ready,
    bundle_drop_contents,
    bundle_insert,
    bundle_remove_one,
    pressure_plate_click_off,
    pressure_plate_click_on,
    button_click_off,
    button_click_on,
    door_open,
    door_close,
    trapdoor_open,
    trapdoor_close,
    fence_gate_open,
    fence_gate_close,
    insert,
    pickup,
    insert_enchanted,
    pickup_enchanted,
    brush,
    brush_completed,
    shatter_pot,
    break_pot,
    block_sniffer_egg_crack,
    block_sniffer_egg_hatch,
    block_sign_waxed_interact_fail,
    record_relic,
    note_bass,
    pumpkin_carve,
    mob_husk_convert_to_zombie,
    mob_pig_death,
    mob_hoglin_converted_to_zombified,
    ambient_underwater_enter,
    ambient_underwater_exit,
    bottle_fill,
    bottle_empty,
    crafter_craft,
    crafter_fail,
    block_decorated_pot_insert,
    block_decorated_pot_insert_fail,
    crafter_disable_slot,
    trial_spawner_open_shutter,
    trial_spawner_eject_item,
    trial_spawner_detect_player,
    trial_spawner_spawn_mob,
    trial_spawner_close_shutter,
    trial_spawner_ambient,
    block_copper_bulb_turn_on,
    block_copper_bulb_turn_off,
    ambient_in_air,
    breeze_wind_charge_burst,
    imitate_breeze,
    mob_armadillo_brush,
    mob_armadillo_scute_drop,
    armor_equip_wolf,
    armor_unequip_wolf,
    reflect,
    vault_open_shutter,
    vault_close_shutter,
    vault_eject_item,
    vault_insert_item,
    vault_insert_item_fail,
    vault_ambient,
    vault_activate,
    vault_deactivate,
    hurt_reduced,
    wind_charge_burst,
    imitate_bogged,
    armor_crack_wolf,
    armor_break_wolf,
    armor_repair_wolf,
    mace_smash_air,
    mace_smash_ground,
    trial_spawner_charge_activate,
    trial_spawner_ambient_ominous,
    ominous_item_spawner_spawn_item,
    ominous_bottle_end_use,
    mace_heavy_smash_ground,
    ominous_item_spawner_spawn_item_begin,
    apply_effect_bad_omen,
    apply_effect_raid_omen,
    apply_effect_trial_omen,
    ominous_item_spawner_about_to_spawn_item,
    record_creator,
    record_creator_music_box,
    record_precipice,
    vault_reject_rewarded_player,
    imitate_drowned,
    imitate_creaking,
    bundle_insert_fail,
    sponge_absorb,
    block_creaking_heart_trail,
    creaking_heart_spawn,
    activate,
    deactivate,
    freeze,
    unfreeze,
    open,
    open_long,
    close,
    close_long,
    imitate_phantom,
    imitate_zoglin,
    imitate_guardian,
    imitate_ravager,
    imitate_pillager,
    place_in_water,
    state_change,
    imitate_happy_ghast,
    armor_unequip_generic,
    record_tears,
    ambient_weather_the_end_light_flash,
    lead_leash,
    lead_unleash,
    lead_break,
    unsaddle,
    armor_equip_copper,
    record_lava_chicken,
    place_item,
    single_swap,
    multi_swap,
    item_enchant_lunge1,
    item_enchant_lunge2,
    item_enchant_lunge3,
    attack_critical,
    item_spear_attack_hit,
    item_spear_attack_miss,
    item_wooden_spear_attack_hit,
    item_wooden_spear_attack_miss,
    imitate_parched,
    imitate_camel_husk,
    item_spear_use,
    item_wooden_spear_use,
    saddle_in_water,
    item_stone_spear_attack_hit,
    item_iron_spear_attack_hit,
    item_copper_spear_attack_hit,
    item_golden_spear_attack_hit,
    item_diamond_spear_attack_hit,
    item_netherite_spear_attack_hit,
    item_stone_spear_attack_miss,
    item_iron_spear_attack_miss,
    item_copper_spear_attack_miss,
    item_golden_spear_attack_miss,
    item_diamond_spear_attack_miss,
    item_netherite_spear_attack_miss,
    item_stone_spear_use,
    item_iron_spear_use,
    item_copper_spear_use,
    item_golden_spear_use,
    item_diamond_spear_use,
    item_netherite_spear_use,
    pause_growth,
    reset_growth,
    pushed_by_player,
    bounce,
    slime_landing,
    absorb_block,
    eject_block,
    geyser_eruption_start,
    geyser_eruption_active,
    record_bounce,
    bucket_fill_land_animal,
    bucket_empty_land_animal,
    geyser_continuous_eruption_start,
    geyser_continuous_eruption_active,
    mount,
    dismount,
    straw_bed_break_leave,

    pub fn wire_name(self: SoundEvent) []const u8 {
        return switch (self) {
            .item_use_on => "item.use.on",
            .hit => "hit",
            .step => "step",
            .fly => "fly",
            .jump => "jump",
            .@"break" => "break",
            .place => "place",
            .heavy_step => "heavy.step",
            .gallop => "gallop",
            .fall => "fall",
            .ambient => "ambient",
            .ambient_baby => "ambient.baby",
            .ambient_in_water => "ambient.in.water",
            .breathe => "breathe",
            .death => "death",
            .death_in_water => "death.in.water",
            .death_to_zombie => "death.to.zombie",
            .hurt => "hurt",
            .hurt_in_water => "hurt.in.water",
            .mad => "mad",
            .boost => "boost",
            .bow => "bow",
            .squish_big => "squish.big",
            .squish_small => "squish.small",
            .fall_big => "fall.big",
            .fall_small => "fall.small",
            .splash => "splash",
            .fizz => "fizz",
            .flap => "flap",
            .swim => "swim",
            .drink => "drink",
            .eat => "eat",
            .takeoff => "takeoff",
            .shake => "shake",
            .plop => "plop",
            .land => "land",
            .saddle => "saddle",
            .armor => "armor",
            .mob_armor_stand_place => "mob.armor_stand.place",
            .add_chest => "add.chest",
            .throw => "throw",
            .attack => "attack",
            .attack_nodamage => "attack.nodamage",
            .attack_strong => "attack.strong",
            .warn => "warn",
            .shear => "shear",
            .milk => "milk",
            .thunder => "thunder",
            .explode => "explode",
            .fire => "fire",
            .ignite => "ignite",
            .fuse => "fuse",
            .stare => "stare",
            .spawn => "spawn",
            .shoot => "shoot",
            .break_block => "break.block",
            .launch => "launch",
            .blast => "blast",
            .large_blast => "large.blast",
            .twinkle => "twinkle",
            .remedy => "remedy",
            .unfect => "unfect",
            .levelup => "levelup",
            .bow_hit => "bow.hit",
            .bullet_hit => "bullet.hit",
            .extinguish_fire => "extinguish.fire",
            .item_fizz => "item.fizz",
            .chest_open => "chest.open",
            .chest_closed => "chest.closed",
            .shulkerbox_open => "shulkerbox.open",
            .shulkerbox_closed => "shulkerbox.closed",
            .enderchest_open => "enderchest.open",
            .enderchest_closed => "enderchest.closed",
            .power_on => "power.on",
            .power_off => "power.off",
            .attach => "attach",
            .detach => "detach",
            .deny => "deny",
            .tripod => "tripod",
            .pop => "pop",
            .drop_slot => "drop.slot",
            .note => "note",
            .thorns => "thorns",
            .piston_in => "piston.in",
            .piston_out => "piston.out",
            .portal => "portal",
            .water => "water",
            .lava_pop => "lava.pop",
            .lava => "lava",
            .burp => "burp",
            .bucket_fill_water => "bucket.fill.water",
            .bucket_fill_lava => "bucket.fill.lava",
            .bucket_empty_water => "bucket.empty.water",
            .bucket_empty_lava => "bucket.empty.lava",
            .armor_equip_chain => "armor.equip_chain",
            .armor_equip_diamond => "armor.equip_diamond",
            .armor_equip_generic => "armor.equip_generic",
            .armor_equip_gold => "armor.equip_gold",
            .armor_equip_iron => "armor.equip_iron",
            .armor_equip_leather => "armor.equip_leather",
            .armor_equip_elytra => "armor.equip_elytra",
            .record_13 => "record.13",
            .record_cat => "record.cat",
            .record_blocks => "record.blocks",
            .record_chirp => "record.chirp",
            .record_far => "record.far",
            .record_mall => "record.mall",
            .record_mellohi => "record.mellohi",
            .record_stal => "record.stal",
            .record_strad => "record.strad",
            .record_ward => "record.ward",
            .record_11 => "record.11",
            .record_wait => "record.wait",
            .record_null => "record.null",
            .flop => "flop",
            .elderguardian_curse => "elderguardian.curse",
            .mob_warning => "mob.warning",
            .mob_warning_baby => "mob.warning.baby",
            .teleport => "teleport",
            .shulker_open => "shulker.open",
            .shulker_close => "shulker.close",
            .haggle => "haggle",
            .haggle_yes => "haggle.yes",
            .haggle_no => "haggle.no",
            .haggle_idle => "haggle.idle",
            .chorusgrow => "chorusgrow",
            .chorusdeath => "chorusdeath",
            .glass => "glass",
            .potion_brewed => "potion.brewed",
            .cast_spell => "cast.spell",
            .prepare_attack => "prepare.attack",
            .prepare_summon => "prepare.summon",
            .prepare_wololo => "prepare.wololo",
            .fang => "fang",
            .charge => "charge",
            .camera_take_picture => "camera.take_picture",
            .leashknot_place => "leashknot.place",
            .leashknot_break => "leashknot.break",
            .growl => "growl",
            .whine => "whine",
            .pant => "pant",
            .purr => "purr",
            .purreow => "purreow",
            .death_min_volume => "death.min.volume",
            .death_mid_volume => "death.mid.volume",
            .imitate_blaze => "imitate.blaze",
            .imitate_cave_spider => "imitate.cave_spider",
            .imitate_creeper => "imitate.creeper",
            .imitate_elder_guardian => "imitate.elder_guardian",
            .imitate_ender_dragon => "imitate.ender_dragon",
            .imitate_enderman => "imitate.enderman",
            .imitate_endermite => "imitate.endermite",
            .imitate_evocation_illager => "imitate.evocation_illager",
            .imitate_ghast => "imitate.ghast",
            .imitate_husk => "imitate.husk",
            .imitate_magma_cube => "imitate.magma_cube",
            .imitate_polar_bear => "imitate.polar_bear",
            .imitate_shulker => "imitate.shulker",
            .imitate_silverfish => "imitate.silverfish",
            .imitate_skeleton => "imitate.skeleton",
            .imitate_slime => "imitate.slime",
            .imitate_spider => "imitate.spider",
            .imitate_stray => "imitate.stray",
            .imitate_vex => "imitate.vex",
            .imitate_vindication_illager => "imitate.vindication_illager",
            .imitate_witch => "imitate.witch",
            .imitate_wither => "imitate.wither",
            .imitate_wither_skeleton => "imitate.wither_skeleton",
            .imitate_wolf => "imitate.wolf",
            .imitate_zombie => "imitate.zombie",
            .imitate_zombie_pigman => "imitate.zombie_pigman",
            .imitate_zombie_villager => "imitate.zombie_villager",
            .block_end_portal_frame_fill => "block.end_portal_frame.fill",
            .block_end_portal_spawn => "block.end_portal.spawn",
            .random_anvil_use => "random.anvil_use",
            .bottle_dragonbreath => "bottle.dragonbreath",
            .portal_travel => "portal.travel",
            .item_trident_hit => "item.trident.hit",
            .item_trident_return => "item.trident.return",
            .item_trident_riptide_1 => "item.trident.riptide_1",
            .item_trident_riptide_2 => "item.trident.riptide_2",
            .item_trident_riptide_3 => "item.trident.riptide_3",
            .item_trident_throw => "item.trident.throw",
            .item_trident_thunder => "item.trident.thunder",
            .item_trident_hit_ground => "item.trident.hit_ground",
            .default => "default",
            .block_fletching_table_use => "block.fletching_table.use",
            .elemconstruct_open => "elemconstruct.open",
            .icebomb_hit => "icebomb.hit",
            .balloonpop => "balloonpop",
            .lt_reaction_icebomb => "lt.reaction.icebomb",
            .lt_reaction_bleach => "lt.reaction.bleach",
            .lt_reaction_epaste => "lt.reaction.epaste",
            .lt_reaction_epaste2 => "lt.reaction.epaste2",
            .lt_reaction_glow_stick => "lt.reaction.glow_stick",
            .lt_reaction_glow_stick_2 => "lt.reaction.glow_stick_2",
            .lt_reaction_luminol => "lt.reaction.luminol",
            .lt_reaction_salt => "lt.reaction.salt",
            .lt_reaction_fertilizer => "lt.reaction.fertilizer",
            .lt_reaction_fireball => "lt.reaction.fireball",
            .lt_reaction_mgsalt => "lt.reaction.mgsalt",
            .lt_reaction_miscfire => "lt.reaction.miscfire",
            .lt_reaction_fire => "lt.reaction.fire",
            .lt_reaction_miscexplosion => "lt.reaction.miscexplosion",
            .lt_reaction_miscmystical => "lt.reaction.miscmystical",
            .lt_reaction_miscmystical2 => "lt.reaction.miscmystical2",
            .lt_reaction_product => "lt.reaction.product",
            .sparkler_use => "sparkler.use",
            .glowstick_use => "glowstick.use",
            .sparkler_active => "sparkler.active",
            .convert_to_drowned => "convert_to_drowned",
            .bucket_fill_fish => "bucket.fill.fish",
            .bucket_empty_fish => "bucket.empty.fish",
            .bubble_up => "bubble.up",
            .bubble_down => "bubble.down",
            .bubble_pop => "bubble.pop",
            .bubble_upinside => "bubble.upinside",
            .bubble_downinside => "bubble.downinside",
            .hurt_baby => "hurt.baby",
            .death_baby => "death.baby",
            .step_baby => "step.baby",
            .spawn_baby => "spawn.baby",
            .born => "born",
            .block_turtle_egg_break => "block.turtle_egg.break",
            .block_turtle_egg_crack => "block.turtle_egg.crack",
            .block_turtle_egg_hatch => "block.turtle_egg.hatch",
            .lay_egg => "lay_egg",
            .block_turtle_egg_attack => "block.turtle_egg.attack",
            .beacon_activate => "beacon.activate",
            .beacon_ambient => "beacon.ambient",
            .beacon_deactivate => "beacon.deactivate",
            .beacon_power => "beacon.power",
            .conduit_activate => "conduit.activate",
            .conduit_ambient => "conduit.ambient",
            .conduit_attack => "conduit.attack",
            .conduit_deactivate => "conduit.deactivate",
            .conduit_short => "conduit.short",
            .swoop => "swoop",
            .block_bamboo_sapling_place => "block.bamboo_sapling.place",
            .presneeze => "presneeze",
            .sneeze => "sneeze",
            .ambient_tame => "ambient.tame",
            .scared => "scared",
            .block_scaffolding_climb => "block.scaffolding.climb",
            .crossbow_loading_start => "crossbow.loading.start",
            .crossbow_loading_middle => "crossbow.loading.middle",
            .crossbow_loading_end => "crossbow.loading.end",
            .crossbow_shoot => "crossbow.shoot",
            .crossbow_quick_charge_start => "crossbow.quick_charge.start",
            .crossbow_quick_charge_middle => "crossbow.quick_charge.middle",
            .crossbow_quick_charge_end => "crossbow.quick_charge.end",
            .ambient_aggressive => "ambient.aggressive",
            .ambient_worried => "ambient.worried",
            .cant_breed => "cant_breed",
            .item_shield_block => "item.shield.block",
            .item_book_put => "item.book.put",
            .block_grindstone_use => "block.grindstone.use",
            .block_bell_hit => "block.bell.hit",
            .block_campfire_crackle => "block.campfire.crackle",
            .roar => "roar",
            .stun => "stun",
            .block_sweet_berry_bush_hurt => "block.sweet_berry_bush.hurt",
            .block_sweet_berry_bush_pick => "block.sweet_berry_bush.pick",
            .block_cartography_table_use => "block.cartography_table.use",
            .block_stonecutter_use => "block.stonecutter.use",
            .block_composter_empty => "block.composter.empty",
            .block_composter_fill => "block.composter.fill",
            .block_composter_fill_success => "block.composter.fill_success",
            .block_composter_ready => "block.composter.ready",
            .block_barrel_open => "block.barrel.open",
            .block_barrel_close => "block.barrel.close",
            .raid_horn => "raid.horn",
            .block_loom_use => "block.loom.use",
            .ambient_in_raid => "ambient.in.raid",
            .ui_cartography_table_take_result => "ui.cartography_table.take_result",
            .ui_stonecutter_take_result => "ui.stonecutter.take_result",
            .ui_loom_take_result => "ui.loom.take_result",
            .block_smoker_smoke => "block.smoker.smoke",
            .block_blastfurnace_fire_crackle => "block.blastfurnace.fire_crackle",
            .block_smithing_table_use => "block.smithing_table.use",
            .screech => "screech",
            .sleep => "sleep",
            .block_furnace_lit => "block.furnace.lit",
            .convert_mooshroom => "convert_mooshroom",
            .milk_suspiciously => "milk_suspiciously",
            .celebrate => "celebrate",
            .jump_prevent => "jump.prevent",
            .ambient_pollinate => "ambient.pollinate",
            .block_beehive_drip => "block.beehive.drip",
            .block_beehive_enter => "block.beehive.enter",
            .block_beehive_exit => "block.beehive.exit",
            .block_beehive_work => "block.beehive.work",
            .block_beehive_shear => "block.beehive.shear",
            .drink_honey => "drink.honey",
            .ambient_cave => "ambient.cave",
            .retreat => "retreat",
            .converted_to_zombified => "converted_to_zombified",
            .admire => "admire",
            .step_lava => "step_lava",
            .tempt => "tempt",
            .panic => "panic",
            .angry => "angry",
            .ambient_warped_forest_mood => "ambient.warped_forest.mood",
            .ambient_soulsand_valley_mood => "ambient.soulsand_valley.mood",
            .ambient_nether_wastes_mood => "ambient.nether_wastes.mood",
            .ambient_basalt_deltas_mood => "ambient.basalt_deltas.mood",
            .ambient_crimson_forest_mood => "ambient.crimson_forest.mood",
            .respawn_anchor_charge => "respawn_anchor.charge",
            .respawn_anchor_deplete => "respawn_anchor.deplete",
            .respawn_anchor_set_spawn => "respawn_anchor.set_spawn",
            .respawn_anchor_ambient => "respawn_anchor.ambient",
            .particle_soul_escape_quiet => "particle.soul_escape.quiet",
            .particle_soul_escape_loud => "particle.soul_escape.loud",
            .record_pigstep => "record.pigstep",
            .lodestone_compass_link_compass_to_lodestone => "lodestone_compass.link_compass_to_lodestone",
            .smithing_table_use => "smithing_table.use",
            .armor_equip_netherite => "armor.equip_netherite",
            .ambient_warped_forest_loop => "ambient.warped_forest.loop",
            .ambient_soulsand_valley_loop => "ambient.soulsand_valley.loop",
            .ambient_nether_wastes_loop => "ambient.nether_wastes.loop",
            .ambient_basalt_deltas_loop => "ambient.basalt_deltas.loop",
            .ambient_crimson_forest_loop => "ambient.crimson_forest.loop",
            .ambient_warped_forest_additions => "ambient.warped_forest.additions",
            .ambient_soulsand_valley_additions => "ambient.soulsand_valley.additions",
            .ambient_nether_wastes_additions => "ambient.nether_wastes.additions",
            .ambient_basalt_deltas_additions => "ambient.basalt_deltas.additions",
            .ambient_crimson_forest_additions => "ambient.crimson_forest.additions",
            .power_on_sculk_sensor => "power.on.sculk_sensor",
            .power_off_sculk_sensor => "power.off.sculk_sensor",
            .bucket_fill_powder_snow => "bucket.fill.powder_snow",
            .bucket_empty_powder_snow => "bucket.empty.powder_snow",
            .cauldron_drip_water_pointed_dripstone => "cauldron_drip.water.pointed_dripstone",
            .cauldron_drip_lava_pointed_dripstone => "cauldron_drip.lava.pointed_dripstone",
            .drip_water_pointed_dripstone => "drip.water.pointed_dripstone",
            .drip_lava_pointed_dripstone => "drip.lava.pointed_dripstone",
            .pick_berries_cave_vines => "pick_berries.cave_vines",
            .tilt_down_big_dripleaf => "tilt_down.big_dripleaf",
            .tilt_up_big_dripleaf => "tilt_up.big_dripleaf",
            .copper_wax_on => "copper.wax.on",
            .copper_wax_off => "copper.wax.off",
            .scrape => "scrape",
            .mob_player_hurt_drown => "mob.player.hurt_drown",
            .mob_player_hurt_on_fire => "mob.player.hurt_on_fire",
            .mob_player_hurt_freeze => "mob.player.hurt_freeze",
            .item_spyglass_use => "item.spyglass.use",
            .item_spyglass_stop_using => "item.spyglass.stop_using",
            .chime_amethyst_block => "chime.amethyst_block",
            .ambient_screamer => "ambient.screamer",
            .hurt_screamer => "hurt.screamer",
            .death_screamer => "death.screamer",
            .milk_screamer => "milk.screamer",
            .jump_to_block => "jump_to_block",
            .pre_ram => "pre_ram",
            .pre_ram_screamer => "pre_ram.screamer",
            .ram_impact => "ram_impact",
            .ram_impact_screamer => "ram_impact.screamer",
            .squid_ink_squirt => "squid.ink_squirt",
            .glow_squid_ink_squirt => "glow_squid.ink_squirt",
            .convert_to_stray => "convert_to_stray",
            .cake_add_candle => "cake.add_candle",
            .extinguish_candle => "extinguish.candle",
            .ambient_candle => "ambient.candle",
            .block_click => "block.click",
            .block_click_fail => "block.click.fail",
            .block_sculk_catalyst_bloom => "block.sculk_catalyst.bloom",
            .block_sculk_shrieker_shriek => "block.sculk_shrieker.shriek",
            .nearby_close => "nearby_close",
            .nearby_closer => "nearby_closer",
            .nearby_closest => "nearby_closest",
            .agitated => "agitated",
            .record_otherside => "record.otherside",
            .tongue => "tongue",
            .irongolem_crack => "irongolem.crack",
            .irongolem_repair => "irongolem.repair",
            .listening => "listening",
            .heartbeat => "heartbeat",
            .horn_break => "horn_break",
            .block_sculk_spread => "block.sculk.spread",
            .charge_sculk => "charge.sculk",
            .block_sculk_sensor_place => "block.sculk_sensor.place",
            .block_sculk_shrieker_place => "block.sculk_shrieker.place",
            .horn_call0 => "horn_call0",
            .horn_call1 => "horn_call1",
            .horn_call2 => "horn_call2",
            .horn_call3 => "horn_call3",
            .horn_call4 => "horn_call4",
            .horn_call5 => "horn_call5",
            .horn_call6 => "horn_call6",
            .horn_call7 => "horn_call7",
            .imitate_warden => "imitate.warden",
            .listening_angry => "listening_angry",
            .item_given => "item_given",
            .item_taken => "item_taken",
            .disappeared => "disappeared",
            .reappeared => "reappeared",
            .drink_milk => "drink.milk",
            .block_frog_spawn_hatch => "block.frog_spawn.hatch",
            .lay_spawn => "lay_spawn",
            .block_frog_spawn_break => "block.frog_spawn.break",
            .sonic_boom => "sonic_boom",
            .sonic_charge => "sonic_charge",
            .item_thrown => "item_thrown",
            .record_5 => "record.5",
            .convert_to_frog => "convert_to_frog",
            .block_enchanting_table_use => "block.enchanting_table.use",
            .step_sand => "step_sand",
            .dash_ready => "dash_ready",
            .bundle_drop_contents => "bundle.drop_contents",
            .bundle_insert => "bundle.insert",
            .bundle_remove_one => "bundle.remove_one",
            .pressure_plate_click_off => "pressure_plate.click_off",
            .pressure_plate_click_on => "pressure_plate.click_on",
            .button_click_off => "button.click_off",
            .button_click_on => "button.click_on",
            .door_open => "door.open",
            .door_close => "door.close",
            .trapdoor_open => "trapdoor.open",
            .trapdoor_close => "trapdoor.close",
            .fence_gate_open => "fence_gate.open",
            .fence_gate_close => "fence_gate.close",
            .insert => "insert",
            .pickup => "pickup",
            .insert_enchanted => "insert_enchanted",
            .pickup_enchanted => "pickup_enchanted",
            .brush => "brush",
            .brush_completed => "brush_completed",
            .shatter_pot => "shatter_pot",
            .break_pot => "break_pot",
            .block_sniffer_egg_crack => "block.sniffer_egg.crack",
            .block_sniffer_egg_hatch => "block.sniffer_egg.hatch",
            .block_sign_waxed_interact_fail => "block.sign.waxed_interact_fail",
            .record_relic => "record.relic",
            .note_bass => "note.bass",
            .pumpkin_carve => "pumpkin.carve",
            .mob_husk_convert_to_zombie => "mob.husk.convert_to_zombie",
            .mob_pig_death => "mob.pig.death",
            .mob_hoglin_converted_to_zombified => "mob.hoglin.converted_to_zombified",
            .ambient_underwater_enter => "ambient.underwater.enter",
            .ambient_underwater_exit => "ambient.underwater.exit",
            .bottle_fill => "bottle.fill",
            .bottle_empty => "bottle.empty",
            .crafter_craft => "crafter.craft",
            .crafter_fail => "crafter.fail",
            .block_decorated_pot_insert => "block.decorated_pot.insert",
            .block_decorated_pot_insert_fail => "block.decorated_pot.insert_fail",
            .crafter_disable_slot => "crafter.disable_slot",
            .trial_spawner_open_shutter => "trial_spawner.open_shutter",
            .trial_spawner_eject_item => "trial_spawner.eject_item",
            .trial_spawner_detect_player => "trial_spawner.detect_player",
            .trial_spawner_spawn_mob => "trial_spawner.spawn_mob",
            .trial_spawner_close_shutter => "trial_spawner.close_shutter",
            .trial_spawner_ambient => "trial_spawner.ambient",
            .block_copper_bulb_turn_on => "block.copper_bulb.turn_on",
            .block_copper_bulb_turn_off => "block.copper_bulb.turn_off",
            .ambient_in_air => "ambient.in.air",
            .breeze_wind_charge_burst => "breeze_wind_charge.burst",
            .imitate_breeze => "imitate.breeze",
            .mob_armadillo_brush => "mob.armadillo.brush",
            .mob_armadillo_scute_drop => "mob.armadillo.scute_drop",
            .armor_equip_wolf => "armor.equip_wolf",
            .armor_unequip_wolf => "armor.unequip_wolf",
            .reflect => "reflect",
            .vault_open_shutter => "vault.open_shutter",
            .vault_close_shutter => "vault.close_shutter",
            .vault_eject_item => "vault.eject_item",
            .vault_insert_item => "vault.insert_item",
            .vault_insert_item_fail => "vault.insert_item_fail",
            .vault_ambient => "vault.ambient",
            .vault_activate => "vault.activate",
            .vault_deactivate => "vault.deactivate",
            .hurt_reduced => "hurt.reduced",
            .wind_charge_burst => "wind_charge.burst",
            .imitate_bogged => "imitate.bogged",
            .armor_crack_wolf => "armor.crack_wolf",
            .armor_break_wolf => "armor.break_wolf",
            .armor_repair_wolf => "armor.repair_wolf",
            .mace_smash_air => "mace.smash_air",
            .mace_smash_ground => "mace.smash_ground",
            .trial_spawner_charge_activate => "trial_spawner.charge_activate",
            .trial_spawner_ambient_ominous => "trial_spawner.ambient_ominous",
            .ominous_item_spawner_spawn_item => "ominous_item_spawner.spawn_item",
            .ominous_bottle_end_use => "ominous_bottle.end_use",
            .mace_heavy_smash_ground => "mace.heavy_smash_ground",
            .ominous_item_spawner_spawn_item_begin => "ominous_item_spawner.spawn_item_begin",
            .apply_effect_bad_omen => "apply_effect.bad_omen",
            .apply_effect_raid_omen => "apply_effect.raid_omen",
            .apply_effect_trial_omen => "apply_effect.trial_omen",
            .ominous_item_spawner_about_to_spawn_item => "ominous_item_spawner.about_to_spawn_item",
            .record_creator => "record.creator",
            .record_creator_music_box => "record.creator_music_box",
            .record_precipice => "record.precipice",
            .vault_reject_rewarded_player => "vault.reject_rewarded_player",
            .imitate_drowned => "imitate.drowned",
            .imitate_creaking => "imitate.creaking",
            .bundle_insert_fail => "bundle.insert_fail",
            .sponge_absorb => "sponge.absorb",
            .block_creaking_heart_trail => "block.creaking_heart.trail",
            .creaking_heart_spawn => "creaking_heart_spawn",
            .activate => "activate",
            .deactivate => "deactivate",
            .freeze => "freeze",
            .unfreeze => "unfreeze",
            .open => "open",
            .open_long => "open_long",
            .close => "close",
            .close_long => "close_long",
            .imitate_phantom => "imitate.phantom",
            .imitate_zoglin => "imitate.zoglin",
            .imitate_guardian => "imitate.guardian",
            .imitate_ravager => "imitate.ravager",
            .imitate_pillager => "imitate.pillager",
            .place_in_water => "place_in_water",
            .state_change => "state_change",
            .imitate_happy_ghast => "imitate.happy_ghast",
            .armor_unequip_generic => "armor.unequip_generic",
            .record_tears => "record.tears",
            .ambient_weather_the_end_light_flash => "ambient.weather.the_end_light_flash",
            .lead_leash => "lead.leash",
            .lead_unleash => "lead.unleash",
            .lead_break => "lead.break",
            .unsaddle => "unsaddle",
            .armor_equip_copper => "armor.equip_copper",
            .record_lava_chicken => "record.lava_chicken",
            .place_item => "place_item",
            .single_swap => "single_swap",
            .multi_swap => "multi_swap",
            .item_enchant_lunge1 => "item.enchant.lunge1",
            .item_enchant_lunge2 => "item.enchant.lunge2",
            .item_enchant_lunge3 => "item.enchant.lunge3",
            .attack_critical => "attack.critical",
            .item_spear_attack_hit => "item.spear.attack_hit",
            .item_spear_attack_miss => "item.spear.attack_miss",
            .item_wooden_spear_attack_hit => "item.wooden_spear.attack_hit",
            .item_wooden_spear_attack_miss => "item.wooden_spear.attack_miss",
            .imitate_parched => "imitate.parched",
            .imitate_camel_husk => "imitate.camel_husk",
            .item_spear_use => "item.spear.use",
            .item_wooden_spear_use => "item.wooden_spear.use",
            .saddle_in_water => "saddle_in_water",
            .item_stone_spear_attack_hit => "item.stone_spear.attack_hit",
            .item_iron_spear_attack_hit => "item.iron_spear.attack_hit",
            .item_copper_spear_attack_hit => "item.copper_spear.attack_hit",
            .item_golden_spear_attack_hit => "item.golden_spear.attack_hit",
            .item_diamond_spear_attack_hit => "item.diamond_spear.attack_hit",
            .item_netherite_spear_attack_hit => "item.netherite_spear.attack_hit",
            .item_stone_spear_attack_miss => "item.stone_spear.attack_miss",
            .item_iron_spear_attack_miss => "item.iron_spear.attack_miss",
            .item_copper_spear_attack_miss => "item.copper_spear.attack_miss",
            .item_golden_spear_attack_miss => "item.golden_spear.attack_miss",
            .item_diamond_spear_attack_miss => "item.diamond_spear.attack_miss",
            .item_netherite_spear_attack_miss => "item.netherite_spear.attack_miss",
            .item_stone_spear_use => "item.stone_spear.use",
            .item_iron_spear_use => "item.iron_spear.use",
            .item_copper_spear_use => "item.copper_spear.use",
            .item_golden_spear_use => "item.golden_spear.use",
            .item_diamond_spear_use => "item.diamond_spear.use",
            .item_netherite_spear_use => "item.netherite_spear.use",
            .pause_growth => "pause_growth",
            .reset_growth => "reset_growth",
            .pushed_by_player => "pushed_by_player",
            .bounce => "bounce",
            .slime_landing => "slime_landing",
            .absorb_block => "absorb_block",
            .eject_block => "eject_block",
            .geyser_eruption_start => "geyser_eruption_start",
            .geyser_eruption_active => "geyser_eruption_active",
            .record_bounce => "record.bounce",
            .bucket_fill_land_animal => "bucket.fill.land_animal",
            .bucket_empty_land_animal => "bucket.empty.land_animal",
            .geyser_continuous_eruption_start => "geyser_continuous_eruption_start",
            .geyser_continuous_eruption_active => "geyser_continuous_eruption_active",
            .mount => "mount",
            .dismount => "dismount",
            .straw_bed_break_leave => "straw_bed.break_leave",
        };
    }

    pub fn from_wire_name(name: []const u8) ?SoundEvent {
        if (std.mem.eql(u8, name, "item.use.on")) return .item_use_on;
        if (std.mem.eql(u8, name, "hit")) return .hit;
        if (std.mem.eql(u8, name, "step")) return .step;
        if (std.mem.eql(u8, name, "fly")) return .fly;
        if (std.mem.eql(u8, name, "jump")) return .jump;
        if (std.mem.eql(u8, name, "break")) return .@"break";
        if (std.mem.eql(u8, name, "place")) return .place;
        if (std.mem.eql(u8, name, "heavy.step")) return .heavy_step;
        if (std.mem.eql(u8, name, "gallop")) return .gallop;
        if (std.mem.eql(u8, name, "fall")) return .fall;
        if (std.mem.eql(u8, name, "ambient")) return .ambient;
        if (std.mem.eql(u8, name, "ambient.baby")) return .ambient_baby;
        if (std.mem.eql(u8, name, "ambient.in.water")) return .ambient_in_water;
        if (std.mem.eql(u8, name, "breathe")) return .breathe;
        if (std.mem.eql(u8, name, "death")) return .death;
        if (std.mem.eql(u8, name, "death.in.water")) return .death_in_water;
        if (std.mem.eql(u8, name, "death.to.zombie")) return .death_to_zombie;
        if (std.mem.eql(u8, name, "hurt")) return .hurt;
        if (std.mem.eql(u8, name, "hurt.in.water")) return .hurt_in_water;
        if (std.mem.eql(u8, name, "mad")) return .mad;
        if (std.mem.eql(u8, name, "boost")) return .boost;
        if (std.mem.eql(u8, name, "bow")) return .bow;
        if (std.mem.eql(u8, name, "squish.big")) return .squish_big;
        if (std.mem.eql(u8, name, "squish.small")) return .squish_small;
        if (std.mem.eql(u8, name, "fall.big")) return .fall_big;
        if (std.mem.eql(u8, name, "fall.small")) return .fall_small;
        if (std.mem.eql(u8, name, "splash")) return .splash;
        if (std.mem.eql(u8, name, "fizz")) return .fizz;
        if (std.mem.eql(u8, name, "flap")) return .flap;
        if (std.mem.eql(u8, name, "swim")) return .swim;
        if (std.mem.eql(u8, name, "drink")) return .drink;
        if (std.mem.eql(u8, name, "eat")) return .eat;
        if (std.mem.eql(u8, name, "takeoff")) return .takeoff;
        if (std.mem.eql(u8, name, "shake")) return .shake;
        if (std.mem.eql(u8, name, "plop")) return .plop;
        if (std.mem.eql(u8, name, "land")) return .land;
        if (std.mem.eql(u8, name, "saddle")) return .saddle;
        if (std.mem.eql(u8, name, "armor")) return .armor;
        if (std.mem.eql(u8, name, "mob.armor_stand.place")) return .mob_armor_stand_place;
        if (std.mem.eql(u8, name, "add.chest")) return .add_chest;
        if (std.mem.eql(u8, name, "throw")) return .throw;
        if (std.mem.eql(u8, name, "attack")) return .attack;
        if (std.mem.eql(u8, name, "attack.nodamage")) return .attack_nodamage;
        if (std.mem.eql(u8, name, "attack.strong")) return .attack_strong;
        if (std.mem.eql(u8, name, "warn")) return .warn;
        if (std.mem.eql(u8, name, "shear")) return .shear;
        if (std.mem.eql(u8, name, "milk")) return .milk;
        if (std.mem.eql(u8, name, "thunder")) return .thunder;
        if (std.mem.eql(u8, name, "explode")) return .explode;
        if (std.mem.eql(u8, name, "fire")) return .fire;
        if (std.mem.eql(u8, name, "ignite")) return .ignite;
        if (std.mem.eql(u8, name, "fuse")) return .fuse;
        if (std.mem.eql(u8, name, "stare")) return .stare;
        if (std.mem.eql(u8, name, "spawn")) return .spawn;
        if (std.mem.eql(u8, name, "shoot")) return .shoot;
        if (std.mem.eql(u8, name, "break.block")) return .break_block;
        if (std.mem.eql(u8, name, "launch")) return .launch;
        if (std.mem.eql(u8, name, "blast")) return .blast;
        if (std.mem.eql(u8, name, "large.blast")) return .large_blast;
        if (std.mem.eql(u8, name, "twinkle")) return .twinkle;
        if (std.mem.eql(u8, name, "remedy")) return .remedy;
        if (std.mem.eql(u8, name, "unfect")) return .unfect;
        if (std.mem.eql(u8, name, "levelup")) return .levelup;
        if (std.mem.eql(u8, name, "bow.hit")) return .bow_hit;
        if (std.mem.eql(u8, name, "bullet.hit")) return .bullet_hit;
        if (std.mem.eql(u8, name, "extinguish.fire")) return .extinguish_fire;
        if (std.mem.eql(u8, name, "item.fizz")) return .item_fizz;
        if (std.mem.eql(u8, name, "chest.open")) return .chest_open;
        if (std.mem.eql(u8, name, "chest.closed")) return .chest_closed;
        if (std.mem.eql(u8, name, "shulkerbox.open")) return .shulkerbox_open;
        if (std.mem.eql(u8, name, "shulkerbox.closed")) return .shulkerbox_closed;
        if (std.mem.eql(u8, name, "enderchest.open")) return .enderchest_open;
        if (std.mem.eql(u8, name, "enderchest.closed")) return .enderchest_closed;
        if (std.mem.eql(u8, name, "power.on")) return .power_on;
        if (std.mem.eql(u8, name, "power.off")) return .power_off;
        if (std.mem.eql(u8, name, "attach")) return .attach;
        if (std.mem.eql(u8, name, "detach")) return .detach;
        if (std.mem.eql(u8, name, "deny")) return .deny;
        if (std.mem.eql(u8, name, "tripod")) return .tripod;
        if (std.mem.eql(u8, name, "pop")) return .pop;
        if (std.mem.eql(u8, name, "drop.slot")) return .drop_slot;
        if (std.mem.eql(u8, name, "note")) return .note;
        if (std.mem.eql(u8, name, "thorns")) return .thorns;
        if (std.mem.eql(u8, name, "piston.in")) return .piston_in;
        if (std.mem.eql(u8, name, "piston.out")) return .piston_out;
        if (std.mem.eql(u8, name, "portal")) return .portal;
        if (std.mem.eql(u8, name, "water")) return .water;
        if (std.mem.eql(u8, name, "lava.pop")) return .lava_pop;
        if (std.mem.eql(u8, name, "lava")) return .lava;
        if (std.mem.eql(u8, name, "burp")) return .burp;
        if (std.mem.eql(u8, name, "bucket.fill.water")) return .bucket_fill_water;
        if (std.mem.eql(u8, name, "bucket.fill.lava")) return .bucket_fill_lava;
        if (std.mem.eql(u8, name, "bucket.empty.water")) return .bucket_empty_water;
        if (std.mem.eql(u8, name, "bucket.empty.lava")) return .bucket_empty_lava;
        if (std.mem.eql(u8, name, "armor.equip_chain")) return .armor_equip_chain;
        if (std.mem.eql(u8, name, "armor.equip_diamond")) return .armor_equip_diamond;
        if (std.mem.eql(u8, name, "armor.equip_generic")) return .armor_equip_generic;
        if (std.mem.eql(u8, name, "armor.equip_gold")) return .armor_equip_gold;
        if (std.mem.eql(u8, name, "armor.equip_iron")) return .armor_equip_iron;
        if (std.mem.eql(u8, name, "armor.equip_leather")) return .armor_equip_leather;
        if (std.mem.eql(u8, name, "armor.equip_elytra")) return .armor_equip_elytra;
        if (std.mem.eql(u8, name, "record.13")) return .record_13;
        if (std.mem.eql(u8, name, "record.cat")) return .record_cat;
        if (std.mem.eql(u8, name, "record.blocks")) return .record_blocks;
        if (std.mem.eql(u8, name, "record.chirp")) return .record_chirp;
        if (std.mem.eql(u8, name, "record.far")) return .record_far;
        if (std.mem.eql(u8, name, "record.mall")) return .record_mall;
        if (std.mem.eql(u8, name, "record.mellohi")) return .record_mellohi;
        if (std.mem.eql(u8, name, "record.stal")) return .record_stal;
        if (std.mem.eql(u8, name, "record.strad")) return .record_strad;
        if (std.mem.eql(u8, name, "record.ward")) return .record_ward;
        if (std.mem.eql(u8, name, "record.11")) return .record_11;
        if (std.mem.eql(u8, name, "record.wait")) return .record_wait;
        if (std.mem.eql(u8, name, "record.null")) return .record_null;
        if (std.mem.eql(u8, name, "flop")) return .flop;
        if (std.mem.eql(u8, name, "elderguardian.curse")) return .elderguardian_curse;
        if (std.mem.eql(u8, name, "mob.warning")) return .mob_warning;
        if (std.mem.eql(u8, name, "mob.warning.baby")) return .mob_warning_baby;
        if (std.mem.eql(u8, name, "teleport")) return .teleport;
        if (std.mem.eql(u8, name, "shulker.open")) return .shulker_open;
        if (std.mem.eql(u8, name, "shulker.close")) return .shulker_close;
        if (std.mem.eql(u8, name, "haggle")) return .haggle;
        if (std.mem.eql(u8, name, "haggle.yes")) return .haggle_yes;
        if (std.mem.eql(u8, name, "haggle.no")) return .haggle_no;
        if (std.mem.eql(u8, name, "haggle.idle")) return .haggle_idle;
        if (std.mem.eql(u8, name, "chorusgrow")) return .chorusgrow;
        if (std.mem.eql(u8, name, "chorusdeath")) return .chorusdeath;
        if (std.mem.eql(u8, name, "glass")) return .glass;
        if (std.mem.eql(u8, name, "potion.brewed")) return .potion_brewed;
        if (std.mem.eql(u8, name, "cast.spell")) return .cast_spell;
        if (std.mem.eql(u8, name, "prepare.attack")) return .prepare_attack;
        if (std.mem.eql(u8, name, "prepare.summon")) return .prepare_summon;
        if (std.mem.eql(u8, name, "prepare.wololo")) return .prepare_wololo;
        if (std.mem.eql(u8, name, "fang")) return .fang;
        if (std.mem.eql(u8, name, "charge")) return .charge;
        if (std.mem.eql(u8, name, "camera.take_picture")) return .camera_take_picture;
        if (std.mem.eql(u8, name, "leashknot.place")) return .leashknot_place;
        if (std.mem.eql(u8, name, "leashknot.break")) return .leashknot_break;
        if (std.mem.eql(u8, name, "growl")) return .growl;
        if (std.mem.eql(u8, name, "whine")) return .whine;
        if (std.mem.eql(u8, name, "pant")) return .pant;
        if (std.mem.eql(u8, name, "purr")) return .purr;
        if (std.mem.eql(u8, name, "purreow")) return .purreow;
        if (std.mem.eql(u8, name, "death.min.volume")) return .death_min_volume;
        if (std.mem.eql(u8, name, "death.mid.volume")) return .death_mid_volume;
        if (std.mem.eql(u8, name, "imitate.blaze")) return .imitate_blaze;
        if (std.mem.eql(u8, name, "imitate.cave_spider")) return .imitate_cave_spider;
        if (std.mem.eql(u8, name, "imitate.creeper")) return .imitate_creeper;
        if (std.mem.eql(u8, name, "imitate.elder_guardian")) return .imitate_elder_guardian;
        if (std.mem.eql(u8, name, "imitate.ender_dragon")) return .imitate_ender_dragon;
        if (std.mem.eql(u8, name, "imitate.enderman")) return .imitate_enderman;
        if (std.mem.eql(u8, name, "imitate.endermite")) return .imitate_endermite;
        if (std.mem.eql(u8, name, "imitate.evocation_illager")) return .imitate_evocation_illager;
        if (std.mem.eql(u8, name, "imitate.ghast")) return .imitate_ghast;
        if (std.mem.eql(u8, name, "imitate.husk")) return .imitate_husk;
        if (std.mem.eql(u8, name, "imitate.magma_cube")) return .imitate_magma_cube;
        if (std.mem.eql(u8, name, "imitate.polar_bear")) return .imitate_polar_bear;
        if (std.mem.eql(u8, name, "imitate.shulker")) return .imitate_shulker;
        if (std.mem.eql(u8, name, "imitate.silverfish")) return .imitate_silverfish;
        if (std.mem.eql(u8, name, "imitate.skeleton")) return .imitate_skeleton;
        if (std.mem.eql(u8, name, "imitate.slime")) return .imitate_slime;
        if (std.mem.eql(u8, name, "imitate.spider")) return .imitate_spider;
        if (std.mem.eql(u8, name, "imitate.stray")) return .imitate_stray;
        if (std.mem.eql(u8, name, "imitate.vex")) return .imitate_vex;
        if (std.mem.eql(u8, name, "imitate.vindication_illager")) return .imitate_vindication_illager;
        if (std.mem.eql(u8, name, "imitate.witch")) return .imitate_witch;
        if (std.mem.eql(u8, name, "imitate.wither")) return .imitate_wither;
        if (std.mem.eql(u8, name, "imitate.wither_skeleton")) return .imitate_wither_skeleton;
        if (std.mem.eql(u8, name, "imitate.wolf")) return .imitate_wolf;
        if (std.mem.eql(u8, name, "imitate.zombie")) return .imitate_zombie;
        if (std.mem.eql(u8, name, "imitate.zombie_pigman")) return .imitate_zombie_pigman;
        if (std.mem.eql(u8, name, "imitate.zombie_villager")) return .imitate_zombie_villager;
        if (std.mem.eql(u8, name, "block.end_portal_frame.fill")) return .block_end_portal_frame_fill;
        if (std.mem.eql(u8, name, "block.end_portal.spawn")) return .block_end_portal_spawn;
        if (std.mem.eql(u8, name, "random.anvil_use")) return .random_anvil_use;
        if (std.mem.eql(u8, name, "bottle.dragonbreath")) return .bottle_dragonbreath;
        if (std.mem.eql(u8, name, "portal.travel")) return .portal_travel;
        if (std.mem.eql(u8, name, "item.trident.hit")) return .item_trident_hit;
        if (std.mem.eql(u8, name, "item.trident.return")) return .item_trident_return;
        if (std.mem.eql(u8, name, "item.trident.riptide_1")) return .item_trident_riptide_1;
        if (std.mem.eql(u8, name, "item.trident.riptide_2")) return .item_trident_riptide_2;
        if (std.mem.eql(u8, name, "item.trident.riptide_3")) return .item_trident_riptide_3;
        if (std.mem.eql(u8, name, "item.trident.throw")) return .item_trident_throw;
        if (std.mem.eql(u8, name, "item.trident.thunder")) return .item_trident_thunder;
        if (std.mem.eql(u8, name, "item.trident.hit_ground")) return .item_trident_hit_ground;
        if (std.mem.eql(u8, name, "default")) return .default;
        if (std.mem.eql(u8, name, "block.fletching_table.use")) return .block_fletching_table_use;
        if (std.mem.eql(u8, name, "elemconstruct.open")) return .elemconstruct_open;
        if (std.mem.eql(u8, name, "icebomb.hit")) return .icebomb_hit;
        if (std.mem.eql(u8, name, "balloonpop")) return .balloonpop;
        if (std.mem.eql(u8, name, "lt.reaction.icebomb")) return .lt_reaction_icebomb;
        if (std.mem.eql(u8, name, "lt.reaction.bleach")) return .lt_reaction_bleach;
        if (std.mem.eql(u8, name, "lt.reaction.epaste")) return .lt_reaction_epaste;
        if (std.mem.eql(u8, name, "lt.reaction.epaste2")) return .lt_reaction_epaste2;
        if (std.mem.eql(u8, name, "lt.reaction.glow_stick")) return .lt_reaction_glow_stick;
        if (std.mem.eql(u8, name, "lt.reaction.glow_stick_2")) return .lt_reaction_glow_stick_2;
        if (std.mem.eql(u8, name, "lt.reaction.luminol")) return .lt_reaction_luminol;
        if (std.mem.eql(u8, name, "lt.reaction.salt")) return .lt_reaction_salt;
        if (std.mem.eql(u8, name, "lt.reaction.fertilizer")) return .lt_reaction_fertilizer;
        if (std.mem.eql(u8, name, "lt.reaction.fireball")) return .lt_reaction_fireball;
        if (std.mem.eql(u8, name, "lt.reaction.mgsalt")) return .lt_reaction_mgsalt;
        if (std.mem.eql(u8, name, "lt.reaction.miscfire")) return .lt_reaction_miscfire;
        if (std.mem.eql(u8, name, "lt.reaction.fire")) return .lt_reaction_fire;
        if (std.mem.eql(u8, name, "lt.reaction.miscexplosion")) return .lt_reaction_miscexplosion;
        if (std.mem.eql(u8, name, "lt.reaction.miscmystical")) return .lt_reaction_miscmystical;
        if (std.mem.eql(u8, name, "lt.reaction.miscmystical2")) return .lt_reaction_miscmystical2;
        if (std.mem.eql(u8, name, "lt.reaction.product")) return .lt_reaction_product;
        if (std.mem.eql(u8, name, "sparkler.use")) return .sparkler_use;
        if (std.mem.eql(u8, name, "glowstick.use")) return .glowstick_use;
        if (std.mem.eql(u8, name, "sparkler.active")) return .sparkler_active;
        if (std.mem.eql(u8, name, "convert_to_drowned")) return .convert_to_drowned;
        if (std.mem.eql(u8, name, "bucket.fill.fish")) return .bucket_fill_fish;
        if (std.mem.eql(u8, name, "bucket.empty.fish")) return .bucket_empty_fish;
        if (std.mem.eql(u8, name, "bubble.up")) return .bubble_up;
        if (std.mem.eql(u8, name, "bubble.down")) return .bubble_down;
        if (std.mem.eql(u8, name, "bubble.pop")) return .bubble_pop;
        if (std.mem.eql(u8, name, "bubble.upinside")) return .bubble_upinside;
        if (std.mem.eql(u8, name, "bubble.downinside")) return .bubble_downinside;
        if (std.mem.eql(u8, name, "hurt.baby")) return .hurt_baby;
        if (std.mem.eql(u8, name, "death.baby")) return .death_baby;
        if (std.mem.eql(u8, name, "step.baby")) return .step_baby;
        if (std.mem.eql(u8, name, "spawn.baby")) return .spawn_baby;
        if (std.mem.eql(u8, name, "born")) return .born;
        if (std.mem.eql(u8, name, "block.turtle_egg.break")) return .block_turtle_egg_break;
        if (std.mem.eql(u8, name, "block.turtle_egg.crack")) return .block_turtle_egg_crack;
        if (std.mem.eql(u8, name, "block.turtle_egg.hatch")) return .block_turtle_egg_hatch;
        if (std.mem.eql(u8, name, "lay_egg")) return .lay_egg;
        if (std.mem.eql(u8, name, "block.turtle_egg.attack")) return .block_turtle_egg_attack;
        if (std.mem.eql(u8, name, "beacon.activate")) return .beacon_activate;
        if (std.mem.eql(u8, name, "beacon.ambient")) return .beacon_ambient;
        if (std.mem.eql(u8, name, "beacon.deactivate")) return .beacon_deactivate;
        if (std.mem.eql(u8, name, "beacon.power")) return .beacon_power;
        if (std.mem.eql(u8, name, "conduit.activate")) return .conduit_activate;
        if (std.mem.eql(u8, name, "conduit.ambient")) return .conduit_ambient;
        if (std.mem.eql(u8, name, "conduit.attack")) return .conduit_attack;
        if (std.mem.eql(u8, name, "conduit.deactivate")) return .conduit_deactivate;
        if (std.mem.eql(u8, name, "conduit.short")) return .conduit_short;
        if (std.mem.eql(u8, name, "swoop")) return .swoop;
        if (std.mem.eql(u8, name, "block.bamboo_sapling.place")) return .block_bamboo_sapling_place;
        if (std.mem.eql(u8, name, "presneeze")) return .presneeze;
        if (std.mem.eql(u8, name, "sneeze")) return .sneeze;
        if (std.mem.eql(u8, name, "ambient.tame")) return .ambient_tame;
        if (std.mem.eql(u8, name, "scared")) return .scared;
        if (std.mem.eql(u8, name, "block.scaffolding.climb")) return .block_scaffolding_climb;
        if (std.mem.eql(u8, name, "crossbow.loading.start")) return .crossbow_loading_start;
        if (std.mem.eql(u8, name, "crossbow.loading.middle")) return .crossbow_loading_middle;
        if (std.mem.eql(u8, name, "crossbow.loading.end")) return .crossbow_loading_end;
        if (std.mem.eql(u8, name, "crossbow.shoot")) return .crossbow_shoot;
        if (std.mem.eql(u8, name, "crossbow.quick_charge.start")) return .crossbow_quick_charge_start;
        if (std.mem.eql(u8, name, "crossbow.quick_charge.middle")) return .crossbow_quick_charge_middle;
        if (std.mem.eql(u8, name, "crossbow.quick_charge.end")) return .crossbow_quick_charge_end;
        if (std.mem.eql(u8, name, "ambient.aggressive")) return .ambient_aggressive;
        if (std.mem.eql(u8, name, "ambient.worried")) return .ambient_worried;
        if (std.mem.eql(u8, name, "cant_breed")) return .cant_breed;
        if (std.mem.eql(u8, name, "item.shield.block")) return .item_shield_block;
        if (std.mem.eql(u8, name, "item.book.put")) return .item_book_put;
        if (std.mem.eql(u8, name, "block.grindstone.use")) return .block_grindstone_use;
        if (std.mem.eql(u8, name, "block.bell.hit")) return .block_bell_hit;
        if (std.mem.eql(u8, name, "block.campfire.crackle")) return .block_campfire_crackle;
        if (std.mem.eql(u8, name, "roar")) return .roar;
        if (std.mem.eql(u8, name, "stun")) return .stun;
        if (std.mem.eql(u8, name, "block.sweet_berry_bush.hurt")) return .block_sweet_berry_bush_hurt;
        if (std.mem.eql(u8, name, "block.sweet_berry_bush.pick")) return .block_sweet_berry_bush_pick;
        if (std.mem.eql(u8, name, "block.cartography_table.use")) return .block_cartography_table_use;
        if (std.mem.eql(u8, name, "block.stonecutter.use")) return .block_stonecutter_use;
        if (std.mem.eql(u8, name, "block.composter.empty")) return .block_composter_empty;
        if (std.mem.eql(u8, name, "block.composter.fill")) return .block_composter_fill;
        if (std.mem.eql(u8, name, "block.composter.fill_success")) return .block_composter_fill_success;
        if (std.mem.eql(u8, name, "block.composter.ready")) return .block_composter_ready;
        if (std.mem.eql(u8, name, "block.barrel.open")) return .block_barrel_open;
        if (std.mem.eql(u8, name, "block.barrel.close")) return .block_barrel_close;
        if (std.mem.eql(u8, name, "raid.horn")) return .raid_horn;
        if (std.mem.eql(u8, name, "block.loom.use")) return .block_loom_use;
        if (std.mem.eql(u8, name, "ambient.in.raid")) return .ambient_in_raid;
        if (std.mem.eql(u8, name, "ui.cartography_table.take_result")) return .ui_cartography_table_take_result;
        if (std.mem.eql(u8, name, "ui.stonecutter.take_result")) return .ui_stonecutter_take_result;
        if (std.mem.eql(u8, name, "ui.loom.take_result")) return .ui_loom_take_result;
        if (std.mem.eql(u8, name, "block.smoker.smoke")) return .block_smoker_smoke;
        if (std.mem.eql(u8, name, "block.blastfurnace.fire_crackle")) return .block_blastfurnace_fire_crackle;
        if (std.mem.eql(u8, name, "block.smithing_table.use")) return .block_smithing_table_use;
        if (std.mem.eql(u8, name, "screech")) return .screech;
        if (std.mem.eql(u8, name, "sleep")) return .sleep;
        if (std.mem.eql(u8, name, "block.furnace.lit")) return .block_furnace_lit;
        if (std.mem.eql(u8, name, "convert_mooshroom")) return .convert_mooshroom;
        if (std.mem.eql(u8, name, "milk_suspiciously")) return .milk_suspiciously;
        if (std.mem.eql(u8, name, "celebrate")) return .celebrate;
        if (std.mem.eql(u8, name, "jump.prevent")) return .jump_prevent;
        if (std.mem.eql(u8, name, "ambient.pollinate")) return .ambient_pollinate;
        if (std.mem.eql(u8, name, "block.beehive.drip")) return .block_beehive_drip;
        if (std.mem.eql(u8, name, "block.beehive.enter")) return .block_beehive_enter;
        if (std.mem.eql(u8, name, "block.beehive.exit")) return .block_beehive_exit;
        if (std.mem.eql(u8, name, "block.beehive.work")) return .block_beehive_work;
        if (std.mem.eql(u8, name, "block.beehive.shear")) return .block_beehive_shear;
        if (std.mem.eql(u8, name, "drink.honey")) return .drink_honey;
        if (std.mem.eql(u8, name, "ambient.cave")) return .ambient_cave;
        if (std.mem.eql(u8, name, "retreat")) return .retreat;
        if (std.mem.eql(u8, name, "converted_to_zombified")) return .converted_to_zombified;
        if (std.mem.eql(u8, name, "admire")) return .admire;
        if (std.mem.eql(u8, name, "step_lava")) return .step_lava;
        if (std.mem.eql(u8, name, "tempt")) return .tempt;
        if (std.mem.eql(u8, name, "panic")) return .panic;
        if (std.mem.eql(u8, name, "angry")) return .angry;
        if (std.mem.eql(u8, name, "ambient.warped_forest.mood")) return .ambient_warped_forest_mood;
        if (std.mem.eql(u8, name, "ambient.soulsand_valley.mood")) return .ambient_soulsand_valley_mood;
        if (std.mem.eql(u8, name, "ambient.nether_wastes.mood")) return .ambient_nether_wastes_mood;
        if (std.mem.eql(u8, name, "ambient.basalt_deltas.mood")) return .ambient_basalt_deltas_mood;
        if (std.mem.eql(u8, name, "ambient.crimson_forest.mood")) return .ambient_crimson_forest_mood;
        if (std.mem.eql(u8, name, "respawn_anchor.charge")) return .respawn_anchor_charge;
        if (std.mem.eql(u8, name, "respawn_anchor.deplete")) return .respawn_anchor_deplete;
        if (std.mem.eql(u8, name, "respawn_anchor.set_spawn")) return .respawn_anchor_set_spawn;
        if (std.mem.eql(u8, name, "respawn_anchor.ambient")) return .respawn_anchor_ambient;
        if (std.mem.eql(u8, name, "particle.soul_escape.quiet")) return .particle_soul_escape_quiet;
        if (std.mem.eql(u8, name, "particle.soul_escape.loud")) return .particle_soul_escape_loud;
        if (std.mem.eql(u8, name, "record.pigstep")) return .record_pigstep;
        if (std.mem.eql(u8, name, "lodestone_compass.link_compass_to_lodestone")) return .lodestone_compass_link_compass_to_lodestone;
        if (std.mem.eql(u8, name, "smithing_table.use")) return .smithing_table_use;
        if (std.mem.eql(u8, name, "armor.equip_netherite")) return .armor_equip_netherite;
        if (std.mem.eql(u8, name, "ambient.warped_forest.loop")) return .ambient_warped_forest_loop;
        if (std.mem.eql(u8, name, "ambient.soulsand_valley.loop")) return .ambient_soulsand_valley_loop;
        if (std.mem.eql(u8, name, "ambient.nether_wastes.loop")) return .ambient_nether_wastes_loop;
        if (std.mem.eql(u8, name, "ambient.basalt_deltas.loop")) return .ambient_basalt_deltas_loop;
        if (std.mem.eql(u8, name, "ambient.crimson_forest.loop")) return .ambient_crimson_forest_loop;
        if (std.mem.eql(u8, name, "ambient.warped_forest.additions")) return .ambient_warped_forest_additions;
        if (std.mem.eql(u8, name, "ambient.soulsand_valley.additions")) return .ambient_soulsand_valley_additions;
        if (std.mem.eql(u8, name, "ambient.nether_wastes.additions")) return .ambient_nether_wastes_additions;
        if (std.mem.eql(u8, name, "ambient.basalt_deltas.additions")) return .ambient_basalt_deltas_additions;
        if (std.mem.eql(u8, name, "ambient.crimson_forest.additions")) return .ambient_crimson_forest_additions;
        if (std.mem.eql(u8, name, "power.on.sculk_sensor")) return .power_on_sculk_sensor;
        if (std.mem.eql(u8, name, "power.off.sculk_sensor")) return .power_off_sculk_sensor;
        if (std.mem.eql(u8, name, "bucket.fill.powder_snow")) return .bucket_fill_powder_snow;
        if (std.mem.eql(u8, name, "bucket.empty.powder_snow")) return .bucket_empty_powder_snow;
        if (std.mem.eql(u8, name, "cauldron_drip.water.pointed_dripstone")) return .cauldron_drip_water_pointed_dripstone;
        if (std.mem.eql(u8, name, "cauldron_drip.lava.pointed_dripstone")) return .cauldron_drip_lava_pointed_dripstone;
        if (std.mem.eql(u8, name, "drip.water.pointed_dripstone")) return .drip_water_pointed_dripstone;
        if (std.mem.eql(u8, name, "drip.lava.pointed_dripstone")) return .drip_lava_pointed_dripstone;
        if (std.mem.eql(u8, name, "pick_berries.cave_vines")) return .pick_berries_cave_vines;
        if (std.mem.eql(u8, name, "tilt_down.big_dripleaf")) return .tilt_down_big_dripleaf;
        if (std.mem.eql(u8, name, "tilt_up.big_dripleaf")) return .tilt_up_big_dripleaf;
        if (std.mem.eql(u8, name, "copper.wax.on")) return .copper_wax_on;
        if (std.mem.eql(u8, name, "copper.wax.off")) return .copper_wax_off;
        if (std.mem.eql(u8, name, "scrape")) return .scrape;
        if (std.mem.eql(u8, name, "mob.player.hurt_drown")) return .mob_player_hurt_drown;
        if (std.mem.eql(u8, name, "mob.player.hurt_on_fire")) return .mob_player_hurt_on_fire;
        if (std.mem.eql(u8, name, "mob.player.hurt_freeze")) return .mob_player_hurt_freeze;
        if (std.mem.eql(u8, name, "item.spyglass.use")) return .item_spyglass_use;
        if (std.mem.eql(u8, name, "item.spyglass.stop_using")) return .item_spyglass_stop_using;
        if (std.mem.eql(u8, name, "chime.amethyst_block")) return .chime_amethyst_block;
        if (std.mem.eql(u8, name, "ambient.screamer")) return .ambient_screamer;
        if (std.mem.eql(u8, name, "hurt.screamer")) return .hurt_screamer;
        if (std.mem.eql(u8, name, "death.screamer")) return .death_screamer;
        if (std.mem.eql(u8, name, "milk.screamer")) return .milk_screamer;
        if (std.mem.eql(u8, name, "jump_to_block")) return .jump_to_block;
        if (std.mem.eql(u8, name, "pre_ram")) return .pre_ram;
        if (std.mem.eql(u8, name, "pre_ram.screamer")) return .pre_ram_screamer;
        if (std.mem.eql(u8, name, "ram_impact")) return .ram_impact;
        if (std.mem.eql(u8, name, "ram_impact.screamer")) return .ram_impact_screamer;
        if (std.mem.eql(u8, name, "squid.ink_squirt")) return .squid_ink_squirt;
        if (std.mem.eql(u8, name, "glow_squid.ink_squirt")) return .glow_squid_ink_squirt;
        if (std.mem.eql(u8, name, "convert_to_stray")) return .convert_to_stray;
        if (std.mem.eql(u8, name, "cake.add_candle")) return .cake_add_candle;
        if (std.mem.eql(u8, name, "extinguish.candle")) return .extinguish_candle;
        if (std.mem.eql(u8, name, "ambient.candle")) return .ambient_candle;
        if (std.mem.eql(u8, name, "block.click")) return .block_click;
        if (std.mem.eql(u8, name, "block.click.fail")) return .block_click_fail;
        if (std.mem.eql(u8, name, "block.sculk_catalyst.bloom")) return .block_sculk_catalyst_bloom;
        if (std.mem.eql(u8, name, "block.sculk_shrieker.shriek")) return .block_sculk_shrieker_shriek;
        if (std.mem.eql(u8, name, "nearby_close")) return .nearby_close;
        if (std.mem.eql(u8, name, "nearby_closer")) return .nearby_closer;
        if (std.mem.eql(u8, name, "nearby_closest")) return .nearby_closest;
        if (std.mem.eql(u8, name, "agitated")) return .agitated;
        if (std.mem.eql(u8, name, "record.otherside")) return .record_otherside;
        if (std.mem.eql(u8, name, "tongue")) return .tongue;
        if (std.mem.eql(u8, name, "irongolem.crack")) return .irongolem_crack;
        if (std.mem.eql(u8, name, "irongolem.repair")) return .irongolem_repair;
        if (std.mem.eql(u8, name, "listening")) return .listening;
        if (std.mem.eql(u8, name, "heartbeat")) return .heartbeat;
        if (std.mem.eql(u8, name, "horn_break")) return .horn_break;
        if (std.mem.eql(u8, name, "block.sculk.spread")) return .block_sculk_spread;
        if (std.mem.eql(u8, name, "charge.sculk")) return .charge_sculk;
        if (std.mem.eql(u8, name, "block.sculk_sensor.place")) return .block_sculk_sensor_place;
        if (std.mem.eql(u8, name, "block.sculk_shrieker.place")) return .block_sculk_shrieker_place;
        if (std.mem.eql(u8, name, "horn_call0")) return .horn_call0;
        if (std.mem.eql(u8, name, "horn_call1")) return .horn_call1;
        if (std.mem.eql(u8, name, "horn_call2")) return .horn_call2;
        if (std.mem.eql(u8, name, "horn_call3")) return .horn_call3;
        if (std.mem.eql(u8, name, "horn_call4")) return .horn_call4;
        if (std.mem.eql(u8, name, "horn_call5")) return .horn_call5;
        if (std.mem.eql(u8, name, "horn_call6")) return .horn_call6;
        if (std.mem.eql(u8, name, "horn_call7")) return .horn_call7;
        if (std.mem.eql(u8, name, "imitate.warden")) return .imitate_warden;
        if (std.mem.eql(u8, name, "listening_angry")) return .listening_angry;
        if (std.mem.eql(u8, name, "item_given")) return .item_given;
        if (std.mem.eql(u8, name, "item_taken")) return .item_taken;
        if (std.mem.eql(u8, name, "disappeared")) return .disappeared;
        if (std.mem.eql(u8, name, "reappeared")) return .reappeared;
        if (std.mem.eql(u8, name, "drink.milk")) return .drink_milk;
        if (std.mem.eql(u8, name, "block.frog_spawn.hatch")) return .block_frog_spawn_hatch;
        if (std.mem.eql(u8, name, "lay_spawn")) return .lay_spawn;
        if (std.mem.eql(u8, name, "block.frog_spawn.break")) return .block_frog_spawn_break;
        if (std.mem.eql(u8, name, "sonic_boom")) return .sonic_boom;
        if (std.mem.eql(u8, name, "sonic_charge")) return .sonic_charge;
        if (std.mem.eql(u8, name, "item_thrown")) return .item_thrown;
        if (std.mem.eql(u8, name, "record.5")) return .record_5;
        if (std.mem.eql(u8, name, "convert_to_frog")) return .convert_to_frog;
        if (std.mem.eql(u8, name, "block.enchanting_table.use")) return .block_enchanting_table_use;
        if (std.mem.eql(u8, name, "step_sand")) return .step_sand;
        if (std.mem.eql(u8, name, "dash_ready")) return .dash_ready;
        if (std.mem.eql(u8, name, "bundle.drop_contents")) return .bundle_drop_contents;
        if (std.mem.eql(u8, name, "bundle.insert")) return .bundle_insert;
        if (std.mem.eql(u8, name, "bundle.remove_one")) return .bundle_remove_one;
        if (std.mem.eql(u8, name, "pressure_plate.click_off")) return .pressure_plate_click_off;
        if (std.mem.eql(u8, name, "pressure_plate.click_on")) return .pressure_plate_click_on;
        if (std.mem.eql(u8, name, "button.click_off")) return .button_click_off;
        if (std.mem.eql(u8, name, "button.click_on")) return .button_click_on;
        if (std.mem.eql(u8, name, "door.open")) return .door_open;
        if (std.mem.eql(u8, name, "door.close")) return .door_close;
        if (std.mem.eql(u8, name, "trapdoor.open")) return .trapdoor_open;
        if (std.mem.eql(u8, name, "trapdoor.close")) return .trapdoor_close;
        if (std.mem.eql(u8, name, "fence_gate.open")) return .fence_gate_open;
        if (std.mem.eql(u8, name, "fence_gate.close")) return .fence_gate_close;
        if (std.mem.eql(u8, name, "insert")) return .insert;
        if (std.mem.eql(u8, name, "pickup")) return .pickup;
        if (std.mem.eql(u8, name, "insert_enchanted")) return .insert_enchanted;
        if (std.mem.eql(u8, name, "pickup_enchanted")) return .pickup_enchanted;
        if (std.mem.eql(u8, name, "brush")) return .brush;
        if (std.mem.eql(u8, name, "brush_completed")) return .brush_completed;
        if (std.mem.eql(u8, name, "shatter_pot")) return .shatter_pot;
        if (std.mem.eql(u8, name, "break_pot")) return .break_pot;
        if (std.mem.eql(u8, name, "block.sniffer_egg.crack")) return .block_sniffer_egg_crack;
        if (std.mem.eql(u8, name, "block.sniffer_egg.hatch")) return .block_sniffer_egg_hatch;
        if (std.mem.eql(u8, name, "block.sign.waxed_interact_fail")) return .block_sign_waxed_interact_fail;
        if (std.mem.eql(u8, name, "record.relic")) return .record_relic;
        if (std.mem.eql(u8, name, "note.bass")) return .note_bass;
        if (std.mem.eql(u8, name, "pumpkin.carve")) return .pumpkin_carve;
        if (std.mem.eql(u8, name, "mob.husk.convert_to_zombie")) return .mob_husk_convert_to_zombie;
        if (std.mem.eql(u8, name, "mob.pig.death")) return .mob_pig_death;
        if (std.mem.eql(u8, name, "mob.hoglin.converted_to_zombified")) return .mob_hoglin_converted_to_zombified;
        if (std.mem.eql(u8, name, "ambient.underwater.enter")) return .ambient_underwater_enter;
        if (std.mem.eql(u8, name, "ambient.underwater.exit")) return .ambient_underwater_exit;
        if (std.mem.eql(u8, name, "bottle.fill")) return .bottle_fill;
        if (std.mem.eql(u8, name, "bottle.empty")) return .bottle_empty;
        if (std.mem.eql(u8, name, "crafter.craft")) return .crafter_craft;
        if (std.mem.eql(u8, name, "crafter.fail")) return .crafter_fail;
        if (std.mem.eql(u8, name, "block.decorated_pot.insert")) return .block_decorated_pot_insert;
        if (std.mem.eql(u8, name, "block.decorated_pot.insert_fail")) return .block_decorated_pot_insert_fail;
        if (std.mem.eql(u8, name, "crafter.disable_slot")) return .crafter_disable_slot;
        if (std.mem.eql(u8, name, "trial_spawner.open_shutter")) return .trial_spawner_open_shutter;
        if (std.mem.eql(u8, name, "trial_spawner.eject_item")) return .trial_spawner_eject_item;
        if (std.mem.eql(u8, name, "trial_spawner.detect_player")) return .trial_spawner_detect_player;
        if (std.mem.eql(u8, name, "trial_spawner.spawn_mob")) return .trial_spawner_spawn_mob;
        if (std.mem.eql(u8, name, "trial_spawner.close_shutter")) return .trial_spawner_close_shutter;
        if (std.mem.eql(u8, name, "trial_spawner.ambient")) return .trial_spawner_ambient;
        if (std.mem.eql(u8, name, "block.copper_bulb.turn_on")) return .block_copper_bulb_turn_on;
        if (std.mem.eql(u8, name, "block.copper_bulb.turn_off")) return .block_copper_bulb_turn_off;
        if (std.mem.eql(u8, name, "ambient.in.air")) return .ambient_in_air;
        if (std.mem.eql(u8, name, "breeze_wind_charge.burst")) return .breeze_wind_charge_burst;
        if (std.mem.eql(u8, name, "imitate.breeze")) return .imitate_breeze;
        if (std.mem.eql(u8, name, "mob.armadillo.brush")) return .mob_armadillo_brush;
        if (std.mem.eql(u8, name, "mob.armadillo.scute_drop")) return .mob_armadillo_scute_drop;
        if (std.mem.eql(u8, name, "armor.equip_wolf")) return .armor_equip_wolf;
        if (std.mem.eql(u8, name, "armor.unequip_wolf")) return .armor_unequip_wolf;
        if (std.mem.eql(u8, name, "reflect")) return .reflect;
        if (std.mem.eql(u8, name, "vault.open_shutter")) return .vault_open_shutter;
        if (std.mem.eql(u8, name, "vault.close_shutter")) return .vault_close_shutter;
        if (std.mem.eql(u8, name, "vault.eject_item")) return .vault_eject_item;
        if (std.mem.eql(u8, name, "vault.insert_item")) return .vault_insert_item;
        if (std.mem.eql(u8, name, "vault.insert_item_fail")) return .vault_insert_item_fail;
        if (std.mem.eql(u8, name, "vault.ambient")) return .vault_ambient;
        if (std.mem.eql(u8, name, "vault.activate")) return .vault_activate;
        if (std.mem.eql(u8, name, "vault.deactivate")) return .vault_deactivate;
        if (std.mem.eql(u8, name, "hurt.reduced")) return .hurt_reduced;
        if (std.mem.eql(u8, name, "wind_charge.burst")) return .wind_charge_burst;
        if (std.mem.eql(u8, name, "imitate.bogged")) return .imitate_bogged;
        if (std.mem.eql(u8, name, "armor.crack_wolf")) return .armor_crack_wolf;
        if (std.mem.eql(u8, name, "armor.break_wolf")) return .armor_break_wolf;
        if (std.mem.eql(u8, name, "armor.repair_wolf")) return .armor_repair_wolf;
        if (std.mem.eql(u8, name, "mace.smash_air")) return .mace_smash_air;
        if (std.mem.eql(u8, name, "mace.smash_ground")) return .mace_smash_ground;
        if (std.mem.eql(u8, name, "trial_spawner.charge_activate")) return .trial_spawner_charge_activate;
        if (std.mem.eql(u8, name, "trial_spawner.ambient_ominous")) return .trial_spawner_ambient_ominous;
        if (std.mem.eql(u8, name, "ominous_item_spawner.spawn_item")) return .ominous_item_spawner_spawn_item;
        if (std.mem.eql(u8, name, "ominous_bottle.end_use")) return .ominous_bottle_end_use;
        if (std.mem.eql(u8, name, "mace.heavy_smash_ground")) return .mace_heavy_smash_ground;
        if (std.mem.eql(u8, name, "ominous_item_spawner.spawn_item_begin")) return .ominous_item_spawner_spawn_item_begin;
        if (std.mem.eql(u8, name, "apply_effect.bad_omen")) return .apply_effect_bad_omen;
        if (std.mem.eql(u8, name, "apply_effect.raid_omen")) return .apply_effect_raid_omen;
        if (std.mem.eql(u8, name, "apply_effect.trial_omen")) return .apply_effect_trial_omen;
        if (std.mem.eql(u8, name, "ominous_item_spawner.about_to_spawn_item")) return .ominous_item_spawner_about_to_spawn_item;
        if (std.mem.eql(u8, name, "record.creator")) return .record_creator;
        if (std.mem.eql(u8, name, "record.creator_music_box")) return .record_creator_music_box;
        if (std.mem.eql(u8, name, "record.precipice")) return .record_precipice;
        if (std.mem.eql(u8, name, "vault.reject_rewarded_player")) return .vault_reject_rewarded_player;
        if (std.mem.eql(u8, name, "imitate.drowned")) return .imitate_drowned;
        if (std.mem.eql(u8, name, "imitate.creaking")) return .imitate_creaking;
        if (std.mem.eql(u8, name, "bundle.insert_fail")) return .bundle_insert_fail;
        if (std.mem.eql(u8, name, "sponge.absorb")) return .sponge_absorb;
        if (std.mem.eql(u8, name, "block.creaking_heart.trail")) return .block_creaking_heart_trail;
        if (std.mem.eql(u8, name, "creaking_heart_spawn")) return .creaking_heart_spawn;
        if (std.mem.eql(u8, name, "activate")) return .activate;
        if (std.mem.eql(u8, name, "deactivate")) return .deactivate;
        if (std.mem.eql(u8, name, "freeze")) return .freeze;
        if (std.mem.eql(u8, name, "unfreeze")) return .unfreeze;
        if (std.mem.eql(u8, name, "open")) return .open;
        if (std.mem.eql(u8, name, "open_long")) return .open_long;
        if (std.mem.eql(u8, name, "close")) return .close;
        if (std.mem.eql(u8, name, "close_long")) return .close_long;
        if (std.mem.eql(u8, name, "imitate.phantom")) return .imitate_phantom;
        if (std.mem.eql(u8, name, "imitate.zoglin")) return .imitate_zoglin;
        if (std.mem.eql(u8, name, "imitate.guardian")) return .imitate_guardian;
        if (std.mem.eql(u8, name, "imitate.ravager")) return .imitate_ravager;
        if (std.mem.eql(u8, name, "imitate.pillager")) return .imitate_pillager;
        if (std.mem.eql(u8, name, "place_in_water")) return .place_in_water;
        if (std.mem.eql(u8, name, "state_change")) return .state_change;
        if (std.mem.eql(u8, name, "imitate.happy_ghast")) return .imitate_happy_ghast;
        if (std.mem.eql(u8, name, "armor.unequip_generic")) return .armor_unequip_generic;
        if (std.mem.eql(u8, name, "record.tears")) return .record_tears;
        if (std.mem.eql(u8, name, "ambient.weather.the_end_light_flash")) return .ambient_weather_the_end_light_flash;
        if (std.mem.eql(u8, name, "lead.leash")) return .lead_leash;
        if (std.mem.eql(u8, name, "lead.unleash")) return .lead_unleash;
        if (std.mem.eql(u8, name, "lead.break")) return .lead_break;
        if (std.mem.eql(u8, name, "unsaddle")) return .unsaddle;
        if (std.mem.eql(u8, name, "armor.equip_copper")) return .armor_equip_copper;
        if (std.mem.eql(u8, name, "record.lava_chicken")) return .record_lava_chicken;
        if (std.mem.eql(u8, name, "place_item")) return .place_item;
        if (std.mem.eql(u8, name, "single_swap")) return .single_swap;
        if (std.mem.eql(u8, name, "multi_swap")) return .multi_swap;
        if (std.mem.eql(u8, name, "item.enchant.lunge1")) return .item_enchant_lunge1;
        if (std.mem.eql(u8, name, "item.enchant.lunge2")) return .item_enchant_lunge2;
        if (std.mem.eql(u8, name, "item.enchant.lunge3")) return .item_enchant_lunge3;
        if (std.mem.eql(u8, name, "attack.critical")) return .attack_critical;
        if (std.mem.eql(u8, name, "item.spear.attack_hit")) return .item_spear_attack_hit;
        if (std.mem.eql(u8, name, "item.spear.attack_miss")) return .item_spear_attack_miss;
        if (std.mem.eql(u8, name, "item.wooden_spear.attack_hit")) return .item_wooden_spear_attack_hit;
        if (std.mem.eql(u8, name, "item.wooden_spear.attack_miss")) return .item_wooden_spear_attack_miss;
        if (std.mem.eql(u8, name, "imitate.parched")) return .imitate_parched;
        if (std.mem.eql(u8, name, "imitate.camel_husk")) return .imitate_camel_husk;
        if (std.mem.eql(u8, name, "item.spear.use")) return .item_spear_use;
        if (std.mem.eql(u8, name, "item.wooden_spear.use")) return .item_wooden_spear_use;
        if (std.mem.eql(u8, name, "saddle_in_water")) return .saddle_in_water;
        if (std.mem.eql(u8, name, "item.stone_spear.attack_hit")) return .item_stone_spear_attack_hit;
        if (std.mem.eql(u8, name, "item.iron_spear.attack_hit")) return .item_iron_spear_attack_hit;
        if (std.mem.eql(u8, name, "item.copper_spear.attack_hit")) return .item_copper_spear_attack_hit;
        if (std.mem.eql(u8, name, "item.golden_spear.attack_hit")) return .item_golden_spear_attack_hit;
        if (std.mem.eql(u8, name, "item.diamond_spear.attack_hit")) return .item_diamond_spear_attack_hit;
        if (std.mem.eql(u8, name, "item.netherite_spear.attack_hit")) return .item_netherite_spear_attack_hit;
        if (std.mem.eql(u8, name, "item.stone_spear.attack_miss")) return .item_stone_spear_attack_miss;
        if (std.mem.eql(u8, name, "item.iron_spear.attack_miss")) return .item_iron_spear_attack_miss;
        if (std.mem.eql(u8, name, "item.copper_spear.attack_miss")) return .item_copper_spear_attack_miss;
        if (std.mem.eql(u8, name, "item.golden_spear.attack_miss")) return .item_golden_spear_attack_miss;
        if (std.mem.eql(u8, name, "item.diamond_spear.attack_miss")) return .item_diamond_spear_attack_miss;
        if (std.mem.eql(u8, name, "item.netherite_spear.attack_miss")) return .item_netherite_spear_attack_miss;
        if (std.mem.eql(u8, name, "item.stone_spear.use")) return .item_stone_spear_use;
        if (std.mem.eql(u8, name, "item.iron_spear.use")) return .item_iron_spear_use;
        if (std.mem.eql(u8, name, "item.copper_spear.use")) return .item_copper_spear_use;
        if (std.mem.eql(u8, name, "item.golden_spear.use")) return .item_golden_spear_use;
        if (std.mem.eql(u8, name, "item.diamond_spear.use")) return .item_diamond_spear_use;
        if (std.mem.eql(u8, name, "item.netherite_spear.use")) return .item_netherite_spear_use;
        if (std.mem.eql(u8, name, "pause_growth")) return .pause_growth;
        if (std.mem.eql(u8, name, "reset_growth")) return .reset_growth;
        if (std.mem.eql(u8, name, "pushed_by_player")) return .pushed_by_player;
        if (std.mem.eql(u8, name, "bounce")) return .bounce;
        if (std.mem.eql(u8, name, "slime_landing")) return .slime_landing;
        if (std.mem.eql(u8, name, "absorb_block")) return .absorb_block;
        if (std.mem.eql(u8, name, "eject_block")) return .eject_block;
        if (std.mem.eql(u8, name, "geyser_eruption_start")) return .geyser_eruption_start;
        if (std.mem.eql(u8, name, "geyser_eruption_active")) return .geyser_eruption_active;
        if (std.mem.eql(u8, name, "record.bounce")) return .record_bounce;
        if (std.mem.eql(u8, name, "bucket.fill.land_animal")) return .bucket_fill_land_animal;
        if (std.mem.eql(u8, name, "bucket.empty.land_animal")) return .bucket_empty_land_animal;
        if (std.mem.eql(u8, name, "geyser_continuous_eruption_start")) return .geyser_continuous_eruption_start;
        if (std.mem.eql(u8, name, "geyser_continuous_eruption_active")) return .geyser_continuous_eruption_active;
        if (std.mem.eql(u8, name, "mount")) return .mount;
        if (std.mem.eql(u8, name, "dismount")) return .dismount;
        if (std.mem.eql(u8, name, "straw_bed.break_leave")) return .straw_bed_break_leave;
        return null;
    }
};

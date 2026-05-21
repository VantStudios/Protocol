const BinaryStream = @import("BinaryStream").BinaryStream;
const Packet = @import("../enums/packet.zig").Packet;
const Vector3f = @import("../types/vector3f.zig").Vector3f;

pub const ActorEventType = enum(u8) {
    Jump = 1,
    HurtAnimation = 2,
    DeathAnimation = 3,
    ArmSwing = 4,
    StopAttack = 5,
    TameFail = 6,
    TameSuccess = 7,
    ShakeWet = 8,
    UseItem = 9,
    EatGrassAnimation = 10,
    FishHookBubble = 11,
    FishHookPosition = 12,
    FishHookHook = 13,
    FishHookTease = 14,
    SquidInkCloud = 15,
    ZombieVillagerCure = 16,
    Respawn = 18,
    IronGolemOfferFlower = 19,
    IronGolemWithdrawFlower = 20,
    LoveParticles = 21,
    VillagerAngry = 22,
    VillagerHappy = 23,
    WitchSpellParticles = 24,
    FireworkParticles = 25,
    InLoveParticles = 26,
    SilverfishSpawnAnimation = 27,
    GuardianAttack = 28,
    WitchDrinkPotion = 29,
    WitchThrowPotion = 30,
    MinecartTntPrimeFuse = 31,
    CreeperPrimeFuse = 32,
    AirSupplyExpired = 33,
    PlayerAddXpLevels = 34,
    ElderGuardianCurse = 35,
    AgentArmSwing = 36,
    EnderDragonDeath = 37,
    DustParticles = 38,
    ArrowShake = 39,
    EatingItem = 57,
    BabyAnimalFeed = 60,
    DeathSmokeCloud = 61,
    CompleteTrade = 62,
    RemoveLeash = 63,
    ConsumeTotem = 65,
    PlayerCheckTreasureHunterAchievement = 66,
    EntitySpawn = 67,
    DragonPuke = 68,
    ItemEntityMerge = 69,
    StartSwim = 70,
    BalloonPop = 71,
    TreasureHunt = 72,
    AgentSummon = 73,
    ChargedItem = 74,
    Fall = 75,
    GrowUp = 76,
    VibrationDetected = 77,
    DrinkMilk = 78,
    ShakeWetnessStop = 79,
    KineticDamageDealt = 80,
    HurtWithoutReceivingDamage = 81,
    _,
};

pub const ActorEventPacket = struct {
    runtimeEntityId: u64,
    event: ActorEventType,
    data: i32 = 0,
    fire_at_position: ?Vector3f = null,

    pub fn serialize(self: *const ActorEventPacket, stream: *BinaryStream) ![]const u8 {
        try stream.writeVarInt(Packet.ActorEvent);
        try stream.writeVarLong(self.runtimeEntityId);
        try stream.writeUint8(@intFromEnum(self.event));
        try stream.writeZigZag(self.data);
        if (self.fire_at_position) |fire_at_position| {
            try stream.writeBool(true);
            try Vector3f.write(stream, fire_at_position);
        } else {
            try stream.writeBool(false);
        }

        return stream.getBuffer();
    }
};

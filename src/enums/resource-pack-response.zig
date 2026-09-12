pub const ResourcePackResponse = enum(u8) {
    None = 0, // v2168-deprecated; never sent on the wire.
    Refused = 1,
    SendPacks = 2,
    HaveAllPacks = 3,
    Completed = 4,
};

/// v2168 wire mapping:
///   wire 0 = REFUSED
///   wire 1 = SEND_PACKS
///   wire 2 = HAVE_ALL_PACKS
///   wire 3 = COMPLETED
/// (None was removed from the wire in v2168; the Java enum keeps it as a
/// deprecated placeholder at ordinal 0, shifted off the wire by -1.)
pub const ResourcePackResponse = enum(u8) {
    None = 0, // v2168-deprecated; never sent on the wire.
    Refused = 1,
    SendPacks = 2,
    HaveAllPacks = 3,
    Completed = 4,
};

pub const ResourcePackResponse = enum(u8) {
    Cancel = 0,
    Downloading = 1,
    DownloadingFinished = 2,
    ResourcePackStackFinished = 3,
};

import Foundation

// MARK: - Disk Info

struct DiskInfo {
    let totalSpace: Int64
    let freeSpace: Int64

    var usedSpace: Int64 { totalSpace - freeSpace }

    var usedFraction: Double {
        guard totalSpace > 0 else { return 0 }
        return Double(usedSpace) / Double(totalSpace)
    }

    var freeFraction: Double {
        guard totalSpace > 0 else { return 0 }
        return Double(freeSpace) / Double(totalSpace)
    }

    /// Load current boot volume disk info
    static func current() -> DiskInfo? {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: "/") else {
            return nil
        }
        let total = (attrs[.systemSize] as? NSNumber)?.int64Value ?? 0
        let free  = (attrs[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
        guard total > 0 else { return nil }
        return DiskInfo(totalSpace: total, freeSpace: free)
    }
}

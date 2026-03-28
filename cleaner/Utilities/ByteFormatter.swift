import Foundation

// MARK: - Byte Formatter

enum ByteFormatter {

    private static let formatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .file
        f.allowsNonnumericFormatting = false
        return f
    }()

    static func string(from bytes: Int64) -> String {
        formatter.string(fromByteCount: bytes)
    }

    /// Returns a short label like "2.3 GB" for display in charts
    static func compact(from bytes: Int64) -> String {
        let gb = Double(bytes) / 1_073_741_824
        if gb >= 1 { return String(format: "%.1f GB", gb) }
        let mb = Double(bytes) / 1_048_576
        if mb >= 1 { return String(format: "%.0f MB", mb) }
        let kb = Double(bytes) / 1_024
        if kb >= 1 { return String(format: "%.0f KB", kb) }
        return "\(bytes) B"
    }
}

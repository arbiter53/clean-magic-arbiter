import Foundation

// MARK: - Safety Constants

enum Safety {
    /// Paths that must NEVER be deleted under any circumstances
    static let protectedPaths: Set<String> = [
        "/System",
        "/usr",
        "/bin",
        "/sbin",
        "/etc",
        "/var",
        "/private",
        "/Library",
        "/Applications",
        "/Network",
        "/Volumes",
        "/cores",
        "/dev",
        "/opt"
    ]

    /// Returns true if the path is safe to delete (inside user home, not protected)
    static func isSafeToDelete(_ path: String) -> Bool {
        let home = FileManager.default.homeDirectoryForCurrentUser.path

        // Must be inside user home directory
        guard path.hasPrefix(home) else { return false }

        // Must not start with any protected path
        for protected in protectedPaths {
            if path.hasPrefix(protected) { return false }
        }

        // Protect critical home subdirectories
        let criticalSubdirs = [
            "\(home)/Desktop",
            "\(home)/Documents",
            "\(home)/Downloads",
            "\(home)/Movies",
            "\(home)/Music",
            "\(home)/Pictures",
            "\(home)/Library/Keychains",
            "\(home)/Library/Preferences",
            "\(home)/Library/Application Support",
            "\(home)/Library/Safari",
            "\(home)/Library/Mail"
        ]

        for critical in criticalSubdirs {
            if path.hasPrefix(critical) { return false }
        }

        return true
    }
}

// MARK: - UI Constants

enum UI {
    static let cornerRadius: Double = 12
    static let cardPadding: Double = 16
    static let animationDuration: Double = 0.3
    static let sidebarWidth: Double = 220
}

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
    static func isSafeToDelete(_ path: String, categoryType: CategoryType? = nil) -> Bool {
        let home = FileManager.default.homeDirectoryForCurrentUser.path

        // Yalnızca /Library/Logs ve ev dizini içindeki yollara izin ver
        if !path.hasPrefix(home) {
            if categoryType == .logs && path.hasPrefix("/Library/Logs") {
                // Özel izin: Sistem Logları
            } else {
                return false
            }
        }

        // Must not start with any protected path
        let protectedPaths: Set<String> = [
            "/System",
            "/usr",
            "/bin",
            "/sbin",
            "/etc",
            "/var",
            "/private",
            "/Applications",
            "/Network",
            "/cores",
            "/dev",
            "/opt"
        ]

        for protected in protectedPaths {
            if path.hasPrefix(protected) { return false }
        }

        // Dosya uzantısı kontrolü (özel koruma)
        if path.hasSuffix(".keychain") || path.hasSuffix(".keychain-db") || path.hasSuffix(".plist") {
            return false
        }

        // `/Library` is partially protected. If category is logs, `/Library/Logs` is allowed.
        if path.hasPrefix("/Library") && !path.hasPrefix("/Library/Logs") {
            return false
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
            "\(home)/Library/Mail"
        ]

        for critical in criticalSubdirs {
            if path.hasPrefix(critical) { return false }
        }

        // Application Support koruması: Chrome cache hariç her şey yasak "Sakın silmeyin"
        if path.hasPrefix("\(home)/Library/Application Support") {
            let chromeCache = "\(home)/Library/Application Support/Google/Chrome/Default/Application Cache"
            if !path.hasPrefix(chromeCache) {
                return false
            }
        }

        // Safari koruması: Sadece Tarayıcı Verileri
        if path == "\(home)/Library/Safari" || path.hasPrefix("\(home)/Library/Safari/") {
            if categoryType != .browserData {
                return false
            }
        }
        
        // CocoaPods ve npm gibi gizli klasörleri engellememek için
        // Geliştirici verilerine izin veriyoruz.
        if path.hasPrefix("\(home)/.npm") || path.hasPrefix("\(home)/.android") {
            if categoryType != .derivedData {
                return false
            }
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

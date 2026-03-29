import Foundation

// MARK: - App State

enum AppState: Equatable {
    case idle
    case scanning
    case ready
    case cleaning
    case completed
    case error(String)
}

// MARK: - Category Type

enum CategoryType: String, CaseIterable, Identifiable {
    case caches        = "User Caches"
    case logs          = "System Logs"
    case browserData   = "Browser Data"
    case mailDownloads = "Mail Downloads"
    case largeFiles    = "Large Files"
    case oldDownloads  = "Old Downloads"
    case languageFiles = "Language Packages"
    case trash         = "Trash"
    case derivedData   = "Xcode Derived Data"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .caches:        return "Kullanıcı Önbelleği"
        case .logs:          return "Sistem Günlükleri"
        case .browserData:   return "Gizlilik Temizliği"
        case .mailDownloads: return "Mail İndirmeleri"
        case .largeFiles:    return "Büyük Dosyalar"
        case .oldDownloads:  return "Eski İndirmeler"
        case .languageFiles: return "Dil Paketleri"
        case .trash:         return "Çöp Kutusu"
        case .derivedData:   return "Geliştirici Verileri"
        }
    }

    var description: String {
        switch self {
        case .caches:        return "Temporary cache files from apps"
        case .logs:          return "Application and system log files"
        case .browserData:   return "Browsing history, cookies, and website data"
        case .mailDownloads: return "Downloaded Mail attachments"
        case .largeFiles:    return "Files larger than 500 MB"
        case .oldDownloads:  return "Downloads older than 3 months"
        case .languageFiles: return "Unused localization files in applications"
        case .trash:         return "Files waiting to be permanently deleted"
        case .derivedData:   return "Developer build artifacts, caches and emulators"
        }
    }

    var localizedDescription: String {
        switch self {
        case .caches:        return "Uygulamalardan geçici önbellek dosyaları"
        case .logs:          return "Uygulama ve sistem günlük dosyaları"
        case .browserData:   return "Safari ve Chrome geçmiş, çerez ve önbellek verileri"
        case .mailDownloads: return "Apple Mail ekleri ve indirmeleri"
        case .largeFiles:    return "500 MB üzerindeki büyük dosyalar"
        case .oldDownloads:  return "3 aydan eski indirilmiş dosyalar"
        case .languageFiles: return "Uygulamalardaki gereksiz dil paketleri (.lproj)"
        case .trash:         return "Kalıcı olarak silinmeyi bekleyen dosyalar"
        case .derivedData:   return "Xcode, npm, Android Studio önbellek ve artifaktları"
        }
    }

    var icon: String {
        switch self {
        case .caches:        return "archivebox.fill"
        case .logs:          return "doc.text.fill"
        case .browserData:   return "safari.fill"
        case .mailDownloads: return "envelope.fill"
        case .largeFiles:    return "externaldrive.fill"
        case .oldDownloads:  return "arrow.down.circle.fill"
        case .languageFiles: return "globe"
        case .trash:         return "trash.fill"
        case .derivedData:   return "hammer.fill"
        }
    }

    var iconColor: String {
        switch self {
        case .caches:        return "blue"
        case .logs:          return "orange"
        case .browserData:   return "cyan"
        case .mailDownloads: return "teal"
        case .largeFiles:    return "pink"
        case .oldDownloads:  return "indigo"
        case .languageFiles: return "mint"
        case .trash:         return "red"
        case .derivedData:   return "purple"
        }
    }

    /// Paths to scan for this category (relative to home or absolute)
    var scanPaths: [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        switch self {
        case .caches:
            return ["\(home)/Library/Caches"]
        case .logs:
            return ["\(home)/Library/Logs", "/Library/Logs"]
        case .browserData:
            return [
                "\(home)/Library/Safari",
                "\(home)/Library/Containers/com.apple.Safari/Data/Library/Caches",
                "\(home)/Library/Application Support/Google/Chrome/Default/Application Cache",
                "\(home)/Library/Containers/com.apple.iChat/Data/Library/Caches", // iMessage
                "\(home)/Library/Application Support/Telegram Desktop/tdata/user_data/cache", // Telegram
                "\(home)/Library/Containers/com.tinyspeck.slackmacgap/Data/Library/Caches" // Slack
            ]
        case .mailDownloads:
            return ["\(home)/Library/Containers/com.apple.mail/Data/Library/Mail Downloads"]
        case .largeFiles:
            return [home] // We will search from home
        case .oldDownloads:
            return ["\(home)/Downloads"]
        case .languageFiles:
            return ["/Applications", "\(home)/Applications"] // Look inside apps
        case .trash:
            return ["\(home)/.Trash"]
        case .derivedData:
            return [
                "\(home)/Library/Developer/Xcode/DerivedData",
                "\(home)/Library/Developer/Xcode/Archives",
                "\(home)/.npm/_cacache",
                "\(home)/Library/Caches/CocoaPods",
                "\(home)/.android/avd"
            ]
        }
    }
}

// MARK: - Clean Category Model

struct CleanCategory: Identifiable {
    let id: UUID
    let type: CategoryType
    var isSelected: Bool
    var scannedSize: Int64
    var isScanning: Bool
    var scanError: String?
    var items: [ScanItem]

    init(type: CategoryType) {
        self.id = UUID()
        self.type = type
        self.isSelected = true
        self.scannedSize = 0
        self.isScanning = false
        self.items = []
    }

    var name: String { type.rawValue }
    var localizedName: String { type.localizedName }
    var description: String { type.description }
    var localizedDescription: String { type.localizedDescription }
    var icon: String { type.icon }
    var paths: [String] { type.scanPaths }
    var hasContent: Bool { scannedSize > 0 }
}

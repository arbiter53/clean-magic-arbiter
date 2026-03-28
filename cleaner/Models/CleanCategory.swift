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
    case caches       = "User Caches"
    case logs         = "System Logs"
    case trash        = "Trash"
    case derivedData  = "Xcode Derived Data"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .caches:      return "Kullanıcı Önbelleği"
        case .logs:        return "Sistem Günlükleri"
        case .trash:       return "Çöp Kutusu"
        case .derivedData: return "Xcode Türetilmiş Veri"
        }
    }

    var description: String {
        switch self {
        case .caches:      return "Temporary cache files from apps"
        case .logs:        return "Application and system log files"
        case .trash:       return "Files waiting to be permanently deleted"
        case .derivedData: return "Xcode build artifacts and indexes"
        }
    }

    var localizedDescription: String {
        switch self {
        case .caches:      return "Uygulamalardan geçici önbellek dosyaları"
        case .logs:        return "Uygulama ve sistem günlük dosyaları"
        case .trash:       return "Kalıcı olarak silinmeyi bekleyen dosyalar"
        case .derivedData: return "Xcode derleme artifaktları ve dizinleri"
        }
    }

    var icon: String {
        switch self {
        case .caches:      return "archivebox.fill"
        case .logs:        return "doc.text.fill"
        case .trash:       return "trash.fill"
        case .derivedData: return "hammer.fill"
        }
    }

    var iconColor: String {
        switch self {
        case .caches:      return "blue"
        case .logs:        return "orange"
        case .trash:       return "red"
        case .derivedData: return "purple"
        }
    }

    /// Paths to scan for this category (relative to home or absolute)
    var scanPaths: [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        switch self {
        case .caches:
            return ["\(home)/Library/Caches"]
        case .logs:
            return ["\(home)/Library/Logs"]
        case .trash:
            return ["\(home)/.Trash"]
        case .derivedData:
            return ["\(home)/Library/Developer/Xcode/DerivedData"]
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

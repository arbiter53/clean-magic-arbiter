import Foundation

// MARK: - Cleanup Result

struct CleanupResult {
    let deletedCount: Int
    let freedBytes: Int64
    let errors: [CleanupError]
}

struct CleanupError: Identifiable {
    let id = UUID()
    let path: String
    let reason: String
}

// MARK: - Cleanup Progress

struct CleanupProgress {
    let current: Int
    let total: Int
    let currentPath: String
    let bytesFreed: Int64

    var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }
}

// MARK: - Cleanup Service

/// Safely deletes files selected by the user.
/// Respects the safety whitelist in Constants.swift.
actor CleanupService {

    // MARK: - Public API

    /// Delete all items from selected categories, streaming progress updates.
    func clean(
        categories: [CleanCategory],
        progressHandler: @Sendable @escaping (CleanupProgress) -> Void
    ) async -> CleanupResult {

        let selectedItems = categories
            .filter(\.isSelected)
            .flatMap(\.items)

        guard !selectedItems.isEmpty else {
            return CleanupResult(deletedCount: 0, freedBytes: 0, errors: [])
        }

        var deletedCount = 0
        var freedBytes: Int64 = 0
        var errors: [CleanupError] = []
        var requiresRootPaths: [ScanItem] = []
        let total = selectedItems.count

        for (index, item) in selectedItems.enumerated() {
            guard !Task.isCancelled else { break }

            progressHandler(CleanupProgress(
                current: index,
                total: total,
                currentPath: item.name,
                bytesFreed: freedBytes
            ))

            guard Safety.isSafeToDelete(item.path, categoryType: item.categoryType) else {
                errors.append(CleanupError(
                    path: item.path,
                    reason: "Safety Layer tarafından korumalı bölge olarak işaretlendi."
                ))
                continue
            }

            do {
                try FileManager.default.removeItem(atPath: item.path)
                deletedCount += 1
                freedBytes += item.size
            } catch {
                let nsError = error as NSError
                // 513: NSFileWriteNoPermissionError
                if nsError.domain == NSCocoaErrorDomain && nsError.code == 513 {
                    requiresRootPaths.append(item)
                } else {
                    errors.append(CleanupError(path: item.path, reason: error.localizedDescription))
                }
            }
        }

        // Kök yetkisi (Root) gerektirenleri topluca AppleScript ile sil (Tek Sefer Şifre İsteyerek)
        if !requiresRootPaths.isEmpty && !Task.isCancelled {
            // Güvenli bash escaping (ör: 'dosya adı' -> '\'' ile korunur)
            let safePaths = requiresRootPaths.map { "'" + $0.path.replacingOccurrences(of: "'", with: "'\\''") + "'" }.joined(separator: " ")
            let appleScriptSource = "do shell script \"rm -rf \(safePaths)\" with administrator privileges"
            
            var errorDict: NSDictionary?
            if let scriptObject = NSAppleScript(source: appleScriptSource) {
                scriptObject.executeAndReturnError(&errorDict)
                
                if let _ = errorDict {
                    // Kullanıcı şifre girmeyi reddetti veya işlem yine başarısız oldu
                    for item in requiresRootPaths {
                        errors.append(CleanupError(path: item.path, reason: "Yönetici yetkisi ile silme isteği reddedildi veya başarısız oldu."))
                    }
                } else {
                    // Başarılı!
                    deletedCount += requiresRootPaths.count
                    freedBytes += requiresRootPaths.reduce(0) { $0 + $1.size }
                }
            } else {
                 for item in requiresRootPaths {
                     errors.append(CleanupError(path: item.path, reason: "Yetki istemcisi (AppleScript) başlatılamadı."))
                 }
            }
        }

        // Final progress update
        progressHandler(CleanupProgress(
            current: total,
            total: total,
            currentPath: "",
            bytesFreed: freedBytes
        ))

        return CleanupResult(deletedCount: deletedCount, freedBytes: freedBytes, errors: errors)
    }

    /// Delete a single item (used for individual item removal)
    func deleteItem(_ item: ScanItem) async throws {
        guard Safety.isSafeToDelete(item.path, categoryType: item.categoryType) else {
            throw CleanerError.protectedPath(item.path)
        }
        try FileManager.default.removeItem(atPath: item.path)
    }
}

// MARK: - Custom Errors

enum CleanerError: LocalizedError {
    case protectedPath(String)
    case permissionDenied(String)
    case notFound(String)

    var errorDescription: String? {
        switch self {
        case .protectedPath(let path):
            return "'\(path)' is a protected path and cannot be deleted."
        case .permissionDenied(let path):
            return "Permission denied when accessing '\(path)'."
        case .notFound(let path):
            return "'\(path)' no longer exists."
        }
    }
}

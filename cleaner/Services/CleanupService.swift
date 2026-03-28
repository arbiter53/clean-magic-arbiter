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
        let total = selectedItems.count

        for (index, item) in selectedItems.enumerated() {
            // Check cancellation at each step
            guard !Task.isCancelled else { break }

            // Report progress before attempting deletion
            progressHandler(CleanupProgress(
                current: index,
                total: total,
                currentPath: item.name,
                bytesFreed: freedBytes
            ))

            // Safety check
            guard Safety.isSafeToDelete(item.path) else {
                errors.append(CleanupError(
                    path: item.path,
                    reason: "Protected path – deletion blocked by safety layer"
                ))
                continue
            }

            // Attempt deletion
            do {
                try FileManager.default.removeItem(atPath: item.path)
                deletedCount += 1
                freedBytes += item.size
            } catch {
                errors.append(CleanupError(path: item.path, reason: error.localizedDescription))
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
        guard Safety.isSafeToDelete(item.path) else {
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

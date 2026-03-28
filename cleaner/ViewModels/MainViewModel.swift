import Foundation
import SwiftUI

// MARK: - Main View Model

@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - Published State

    @Published var appState: AppState = .idle
    @Published var categories: [CleanCategory] = CategoryType.allCases.map { CleanCategory(type: $0) }
    @Published var diskInfo: DiskInfo?
    @Published var cleanupProgress: CleanupProgress?
    @Published var cleanupResult: CleanupResult?
    @Published var errorMessage: String?
    @Published var showConfirmationDialog = false

    // MARK: - Computed Properties

    var totalReclaimable: Int64 {
        categories.filter(\.isSelected).reduce(0) { $0 + $1.scannedSize }
    }

    var totalScanned: Int64 {
        categories.reduce(0) { $0 + $1.scannedSize }
    }

    var hasScannedContent: Bool {
        categories.contains(where: { $0.scannedSize > 0 })
    }

    var selectedCategories: [CleanCategory] {
        categories.filter(\.isSelected)
    }

    var isScanning: Bool { appState == .scanning }
    var isCleaning: Bool { appState == .cleaning }

    // MARK: - Services

    private let scanner = ScannerService()
    private let cleanup = CleanupService()
    private var scanTask: Task<Void, Never>?

    // MARK: - Initializer

    init() {
        diskInfo = DiskInfo.current()
        PermissionService.shared.checkFullDiskAccess()
    }

    // MARK: - Actions

    /// Start scanning all categories concurrently
    func startScan() {
        guard appState == .idle || appState == .ready || appState == .completed else { return }

        appState = .scanning
        errorMessage = nil
        cleanupResult = nil

        // Reset sizes
        for index in categories.indices {
            categories[index].scannedSize = 0
            categories[index].items = []
            categories[index].scanError = nil
        }

        scanTask = Task {
            await withTaskGroup(of: (Int, CleanCategory).self) { group in
                for (index, category) in categories.enumerated() {
                    group.addTask {
                        do {
                            let updated = try await self.scanner.scan(category: category)
                            return (index, updated)
                        } catch CleanerError.permissionDenied {
                            var failed = category
                            failed.scanError = "Erişim reddedildi — Tam Disk Erişimi verin"
                            failed.isScanning = false
                            return (index, failed)
                        } catch {
                            var failed = category
                            failed.scanError = error.localizedDescription
                            failed.isScanning = false
                            return (index, failed)
                        }
                    }
                }

                for await (index, updated) in group {
                    guard !Task.isCancelled else { break }
                    categories[index] = updated
                }
            }

            // Refresh disk info after scan
            diskInfo = DiskInfo.current()

            if !Task.isCancelled {
                appState = .ready
            }
        }
    }

    func cancelScan() {
        scanTask?.cancel()
        appState = .idle
        for index in categories.indices {
            categories[index].isScanning = false
        }
    }

    /// Present confirmation dialog before cleaning
    func requestClean() {
        guard appState == .ready, totalReclaimable > 0 else { return }
        showConfirmationDialog = true
    }

    /// Execute cleanup after user confirmation
    func confirmClean() {
        showConfirmationDialog = false
        guard appState == .ready else { return }
        appState = .cleaning
        cleanupProgress = nil

        Task {
            let result = await cleanup.clean(categories: categories) { [weak self] progress in
                Task { @MainActor [weak self] in
                    self?.cleanupProgress = progress
                }
            }

            cleanupResult = result
            diskInfo = DiskInfo.current()

            // Clear cleaned items from categories
            for index in categories.indices {
                categories[index].items = []
                categories[index].scannedSize = 0
            }

            appState = .completed
        }
    }

    /// Toggle selection of a category
    func toggleCategory(_ category: CleanCategory) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[index].isSelected.toggle()
    }

    /// Reset to idle state for a new scan
    func reset() {
        appState = .idle
        cleanupResult = nil
        cleanupProgress = nil
        for index in categories.indices {
            categories[index].scannedSize = 0
            categories[index].items = []
            categories[index].isSelected = true
        }
        diskInfo = DiskInfo.current()
    }
}

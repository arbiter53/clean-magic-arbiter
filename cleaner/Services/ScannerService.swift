import Foundation

// MARK: - Scanner Service

actor ScannerService {

    // MARK: - Public API

    func scan(category: CleanCategory) async throws -> CleanCategory {
        var updated = category
        updated.isScanning = true
        updated.items = []
        updated.scannedSize = 0

        var totalSize: Int64 = 0
        var items: [ScanItem] = []
        var firstError: Error?

        for rootPath in category.paths {
            // Dizin yoksa atla (örn: DerivedData hiç kullanılmamış Mac)
            guard FileManager.default.fileExists(atPath: rootPath) else { continue }

            do {
                let (size, scanItems) = try await scanDirectory(at: rootPath, categoryType: category.type)
                totalSize += size
                items.append(contentsOf: scanItems)
            } catch {
                firstError = error
            }
        }

        // Hiç öğe bulunamadı VE hata varsa fırlat
        if items.isEmpty, let err = firstError {
            throw err
        }

        updated.scannedSize = totalSize
        updated.items = items.sorted { $0.size > $1.size }
        updated.isScanning = false
        return updated
    }

    // MARK: - Private

    private func scanDirectory(at path: String, categoryType: CategoryType) async throws -> (Int64, [ScanItem]) {
        try Task.checkCancellation()

        let fm = FileManager.default
        var totalSize: Int64 = 0
        var items: [ScanItem] = []

        // Erişim yoksa anlamlı hata fırlat
        let children: [String]
        do {
            children = try fm.contentsOfDirectory(atPath: path)
        } catch {
            let nsErr = error as NSError
            if nsErr.code == NSFileReadNoPermissionError || nsErr.code == 1 {
                throw CleanerError.permissionDenied(path)
            }
            throw error
        }

        for child in children {
            try Task.checkCancellation()
            // Gizli dosyaları atla (.DS_Store vb.) — Çöp Kutusu hariç
            guard !child.hasPrefix(".") || categoryType == .trash else { continue }

            let childPath = (path as NSString).appendingPathComponent(child)
            let size = directorySize(at: childPath)
            guard size > 0 else { continue }

            let attrs = try? fm.attributesOfItem(atPath: childPath)
            let modDate = attrs?[.modificationDate] as? Date
            let isDir = (attrs?[.type] as? FileAttributeType) == .typeDirectory

            items.append(ScanItem(
                path: childPath,
                size: size,
                isDirectory: isDir,
                modifiedDate: modDate,
                categoryType: categoryType
            ))
            totalSize += size
        }

        return (totalSize, items)
    }

    private func directorySize(at path: String) -> Int64 {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: path, isDirectory: &isDir) else { return 0 }

        guard isDir.boolValue else {
            return (try? fm.attributesOfItem(atPath: path)[.size] as? Int64) ?? 0
        }

        guard let enumerator = fm.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]   // skipsPackageDescendants kaldırıldı — paket içlerini de say
        ) else { return 0 }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
                  values.isRegularFile == true,
                  let size = values.fileSize else { continue }
            total += Int64(size)
        }
        return total
    }
}

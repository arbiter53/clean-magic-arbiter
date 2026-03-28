import Foundation

// MARK: - Scan Item

/// Represents a single file or directory found during scanning
struct ScanItem: Identifiable, Hashable {
    let id: UUID
    let path: String
    let name: String
    let size: Int64
    let isDirectory: Bool
    let modifiedDate: Date?
    let categoryType: CategoryType

    init(path: String, size: Int64, isDirectory: Bool, modifiedDate: Date?, categoryType: CategoryType) {
        self.id = UUID()
        self.path = path
        self.name = URL(fileURLWithPath: path).lastPathComponent
        self.size = size
        self.isDirectory = isDirectory
        self.modifiedDate = modifiedDate
        self.categoryType = categoryType
    }
}

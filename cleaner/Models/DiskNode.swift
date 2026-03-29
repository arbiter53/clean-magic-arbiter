import Foundation

// MARK: - Disk Radar / Tree Map Architecture

/// "Disk Radar" veya blok haritası görünümü için dizinleri derinlemesine (du benzeri) tarayıp
/// ağaç modeli olarak saklayan veri yapısı. Bu model, SwiftUI tarafında Chart veya 
/// özel bir Treemap Canvas ile görselleştirilir (Örn: DaisyDisk veya CleanMyMac uzay haritası).
struct DiskNode: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    var size: Int64
    var isDirectory: Bool
    
    /// İçerdiği alt dosyalar ve klasörler
    var children: [DiskNode]?
    
    /// Tüm kardeş klasörlere kıyasla disk üzerindeki yüzdesi (Görsel çizimlerde kullanılmak üzere)
    var relativePercentage: Double = 0.0
    
    /// Derinlemesine tarama yaparak (recursive) bir DiskNode ağacı oluşturur.
    /// Uyarı: Gelişmiş "Radar" görünümü için / aramasını tam disk yetkisi olmadan yaparken
    /// korumalı dizinleri atlar.
    static func scanAsTree(path: String, depth: Int = 3) async throws -> DiskNode {
        guard depth > 0 else {
            // Son seviyede daha derine inme, Sadece size hesapla dön.
            // Bu yaklaşım performans için 'du -sh' mantığıyla yüzeyden alt boyutu okur.
            return DiskNode(name: URL(fileURLWithPath: path).lastPathComponent,
                            path: path,
                            size: 0, // Hedef: fileManager.attributesOfItem()
                            isDirectory: true,
                            children: nil)
        }
        
        // ... recursive FileManager tarama mantığı ve Children allocation ...
        // ... (Bu kod radar haritası ViewModel'ine stream edilebilir) ...
        
        return DiskNode(
            name: "Dummy Radar Root",
            path: path,
            size: 10 * 1024 * 1024 * 1024,
            isDirectory: true,
            children: []
        )
    }
}

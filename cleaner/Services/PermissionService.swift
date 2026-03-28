import Foundation
import AppKit

// MARK: - Permission Status

enum PermissionStatus {
    case granted
    case denied
    case unknown
}

// MARK: - Permission Service

final class PermissionService: ObservableObject {
    @Published private(set) var fullDiskAccess: PermissionStatus = .unknown
    /// FDA verildi ama uygulama yeniden başlatılmayı bekliyor
    @Published private(set) var needsRestart = false

    static let shared = PermissionService()

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Kontrol

    func checkFullDiskAccess() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let granted = Self.probeFullDiskAccess()
            DispatchQueue.main.async {
                let previous = self?.fullDiskAccess
                self?.fullDiskAccess = granted ? .granted : .denied
                // Önceki durum "denied" iken "denied" kalmaya devam ediyorsa
                // ve kullanıcı Settings'den geliyorsa restart gerekebilir —
                // bu durumu needsRestart ile işaretle
                if previous == .denied && !granted {
                    self?.needsRestart = true
                } else {
                    self?.needsRestart = false
                }
            }
        }
    }

    /// Uygulamayı yeniden başlatır (FDA sandbox için gerekli olabilir)
    func relaunch() {
        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL,
                                           configuration: config)
        NSApp.terminate(nil)
    }

    var hasFullDiskAccess: Bool { fullDiskAccess == .granted }

    func openFullDiskAccessSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Private

    /// Birden fazla korumalı yolu dener — ilki başarılı olursa FDA verilmiş demektir.
    /// TCC.db: her Mac'te bulunur, yalnızca FDA ile okunabilir.
    /// ~/Library/Safari: Safari kullanmayan cihazlarda mevcut olmayabilir.
    private static func probeFullDiskAccess() -> Bool {
        let fm = FileManager.default

        // Probe 1 — sistem TCC veritabanı (en güvenilir)
        let tcc = "/Library/Application Support/com.apple.TCC/TCC.db"
        if fm.isReadableFile(atPath: tcc) { return true }

        // Probe 2 — kullanıcı TCC kopyası
        let userTCC = fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/com.apple.TCC/TCC.db")
        if fm.isReadableFile(atPath: userTCC.path) { return true }

        // Probe 3 — Safari geçmişi (Safari yüklüyse)
        let safariHistory = fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Safari/History.db")
        if fm.isReadableFile(atPath: safariHistory.path) { return true }

        // Probe 4 — Mail veritabanı
        let mail = fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Mail")
        if let _ = try? fm.contentsOfDirectory(atPath: mail.path) { return true }

        return false
    }

    @objc private func appDidBecomeActive() {
        checkFullDiskAccess()
    }
}

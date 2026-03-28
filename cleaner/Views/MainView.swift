import SwiftUI

// MARK: - Main View

struct MainView: View {
    @StateObject private var vm = MainViewModel()
    @ObservedObject private var permissions = PermissionService.shared
    /// İlk açılışta FDA onboarding göster (yalnızca bir kez)
    @AppStorage("fdaOnboardingShown") private var fdaOnboardingShown = false
    @State private var showFDAOnboarding = false

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                AppToolbar(vm: vm)
                Divider()
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                BrandFooter()
            }
        }
        .frame(minWidth: 700, minHeight: 520)
        .sheet(isPresented: $showFDAOnboarding) {
            FDAOnboardingView()
        }
        .onAppear {
            permissions.checkFullDiskAccess()
            // FDA verilmemişse ve onboarding daha gösterilmemişse göster
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if !fdaOnboardingShown && permissions.fullDiskAccess != .granted {
                    fdaOnboardingShown = true
                    showFDAOnboarding = true
                }
            }
        }
        .onChange(of: permissions.fullDiskAccess) { status in
            // FDA verilince onboarding sheet varsa kapat
            if status == .granted {
                showFDAOnboarding = false
            }
        }
        .confirmationDialog(
            "\(ByteFormatter.compact(from: vm.totalReclaimable)) temizlensin mi?",
            isPresented: $vm.showConfirmationDialog,
            titleVisibility: .visible
        ) {
            Button("Şimdi Temizle", role: .destructive) {
                withAnimation { vm.confirmClean() }
            }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("Seçilen dosyalar kalıcı olarak silinecek. Bu işlem geri alınamaz.")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.appState {
        case .idle:
            ScanView(vm: vm)
        case .scanning:
            ScanningView(vm: vm)
        case .ready:
            ResultsView(vm: vm)
        case .cleaning:
            CleaningView(vm: vm)
        case .completed:
            CompletedView(vm: vm)
        case .error(let msg):
            ErrorView(message: msg) { vm.reset() }
        }
    }
}

// MARK: - App Toolbar

private struct AppToolbar: View {
    @ObservedObject var vm: MainViewModel
    @ObservedObject private var permissions = PermissionService.shared
    @State private var showFDASheet = false

    var body: some View {
        HStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, .purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("Clean Magic - Arbiter")
                    .font(.system(size: 15, weight: .bold))
            }

            Spacer()

            // FDA durum göstergesi
            FDAStatusPill(status: permissions.fullDiskAccess) {
                showFDASheet = true
            }

            StateBadge(state: vm.appState)

            Menu {
                Button("Tekrar Tara") { vm.startScan() }
                    .disabled(vm.isCleaning || vm.isScanning)
                Divider()
                Button("Tam Disk Erişimi Ayarları…") { showFDASheet = true }
                Divider()
                Button("Sıfırla") { vm.reset() }
                    .disabled(vm.appState == .idle)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 16))
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .padding(.horizontal, 20)
        .frame(height: 52)
        .sheet(isPresented: $showFDASheet) {
            FDAOnboardingView()
        }
    }
}

// MARK: - FDA Durum Hapı

private struct FDAStatusPill: View {
    let status: PermissionStatus
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(color)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .strokeBorder(color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .help(helpText)
    }

    private var icon: String {
        switch status {
        case .granted:  return "lock.open.fill"
        case .denied:   return "lock.fill"
        case .unknown:  return "lock.fill"
        }
    }

    private var label: String {
        switch status {
        case .granted:  return "Tam Erişim"
        case .denied:   return "Kısıtlı Erişim"
        case .unknown:  return "Kontrol Ediliyor"
        }
    }

    private var color: Color {
        switch status {
        case .granted:  return .green
        case .denied:   return .orange
        case .unknown:  return .secondary
        }
    }

    private var helpText: String {
        switch status {
        case .granted:  return "Tam Disk Erişimi verildi"
        case .denied:   return "Tam Disk Erişimi verilmedi — tıklayın"
        case .unknown:  return "İzin durumu kontrol ediliyor"
        }
    }
}

// MARK: - State Badge

private struct StateBadge: View {
    let state: AppState

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(badgeColor)
                .frame(width: 7, height: 7)
            Text(badgeLabel)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(badgeColor.opacity(0.1))
        )
    }

    private var badgeLabel: String {
        switch state {
        case .idle:      return "Hazır"
        case .scanning:  return "Taranıyor"
        case .ready:     return "Tarama Tamamlandı"
        case .cleaning:  return "Temizleniyor"
        case .completed: return "Tamamlandı"
        case .error:     return "Hata"
        }
    }

    private var badgeColor: Color {
        switch state {
        case .idle:      return .gray
        case .scanning:  return .accentColor
        case .ready:     return .green
        case .cleaning:  return .orange
        case .completed: return .green
        case .error:     return .red
        }
    }
}

// MARK: - Error View

private struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            Text("Bir şeyler yanlış gitti")
                .font(.system(size: 20, weight: .bold))
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            Button("Tekrar Dene", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Marka Footer

private struct BrandFooter: View {
    var body: some View {
        HStack(spacing: 4) {
            Spacer()
            Text("Bir")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.6))
            Button {
                if let url = URL(string: "https://topcuyazilim.com") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Text("topcuyazilim.com")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.7))
                    .underline()
            }
            .buttonStyle(.plain)
            .help("topcuyazilim.com — web sitemizi ziyaret edin")
            Text("ürünüdür")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

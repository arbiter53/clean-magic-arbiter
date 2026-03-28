import SwiftUI

// MARK: - Scan View (Boşta)

struct ScanView: View {
    @ObservedObject var vm: MainViewModel
    @ObservedObject private var permissions = PermissionService.shared

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.0)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)

                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 8) {
                Text("Temizlemeye Hazır")
                    .font(.system(size: 26, weight: .bold))
                Text("Gereksiz dosyaları bulmak ve disk alanını güvenli şekilde boşaltmak için Mac'inizi tarayın.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 340)
            }

            if let disk = vm.diskInfo {
                DiskSummaryPill(diskInfo: disk)
            }

            // FDA yoksa kısıtlı tarama uyarısı
            if permissions.fullDiskAccess == .denied {
                FDAWarningNote()
            }

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    vm.startScan()
                }
            } label: {
                Label("Taramayı Başlat", systemImage: "sparkles")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 190, height: 42)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.return, modifiers: [])

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Taranıyor Ekranı

struct ScanningView: View {
    @ObservedObject var vm: MainViewModel

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.08))
                    .frame(width: 110, height: 110)

                ProgressView()
                    .scaleEffect(1.8)
                    .progressViewStyle(.circular)
            }

            VStack(spacing: 6) {
                Text("Taranıyor…")
                    .font(.system(size: 22, weight: .bold))
                Text("Sisteminizdeki gereksiz dosyalar için analiz ediliyor")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(vm.categories) { category in
                    ScanProgressRow(category: category)
                }
            }
            .padding(.horizontal, 32)

            Button("İptal") {
                vm.cancelScan()
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Tarama İlerleme Satırı

private struct ScanProgressRow: View {
    let category: CleanCategory

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: category.isScanning ? "circle.dotted" : (category.scannedSize > 0 ? "checkmark.circle.fill" : "circle"))
                .font(.system(size: 13))
                .foregroundColor(category.isScanning ? .accentColor : (category.scannedSize > 0 ? .green : .secondary))
                .animation(.easeInOut, value: category.isScanning)

            Text(category.localizedName)
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Spacer()

            if category.isScanning {
                ProgressView()
                    .scaleEffect(0.6)
                    .frame(width: 16, height: 16)
            } else if category.scannedSize > 0 {
                Text(ByteFormatter.compact(from: category.scannedSize))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - FDA Uyarı Notu

private struct FDAWarningNote: View {
    @State private var showSheet = false

    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 12))
                Text("Tam Disk Erişimi olmadan tarama kısıtlı olacak")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.orange.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSheet) {
            FDAOnboardingView()
        }
    }
}

// MARK: - Disk Özet Hapsu

struct DiskSummaryPill: View {
    let diskInfo: DiskInfo

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "internaldrive")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Text("\(ByteFormatter.compact(from: diskInfo.freeSpace)) boş / toplam \(ByteFormatter.compact(from: diskInfo.totalSpace))")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
        )
    }
}

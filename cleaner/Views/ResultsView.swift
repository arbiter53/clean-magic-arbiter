import SwiftUI

// MARK: - Sonuçlar Ekranı

struct ResultsView: View {
    @ObservedObject var vm: MainViewModel
    @State private var showPermissionsGuide = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                PermissionsBanner()

                if let disk = vm.diskInfo {
                    StorageSection(diskInfo: disk, reclaimable: vm.totalReclaimable)
                }

                StatsRow(vm: vm)

                CategoriesSection(vm: vm)

                Spacer(minLength: 16)
            }
            .padding(20)
        }
        .safeAreaInset(edge: .bottom) {
            CleanBottomBar(vm: vm)
        }
        .sheet(isPresented: $showPermissionsGuide) {
            PermissionsGuideView()
        }
    }
}

// MARK: - Depolama Bölümü

private struct StorageSection: View {
    let diskInfo: DiskInfo
    let reclaimable: Int64

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Sistem Depolaması", systemImage: "internaldrive.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            StorageBar(diskInfo: diskInfo, reclaimable: reclaimable)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - İstatistik Satırı

private struct StatsRow: View {
    @ObservedObject var vm: MainViewModel

    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Geri Kazanılabilir",
                value: ByteFormatter.compact(from: vm.totalReclaimable),
                subtitle: "\(vm.selectedCategories.count) kategori hazır",
                icon: "arrow.down.to.line.circle.fill",
                color: .green
            )

            StatCard(
                title: "Taranan Hacim",
                value: ByteFormatter.compact(from: vm.totalScanned),
                subtitle: "\(vm.categories.count) modül tarandı",
                icon: "magnifyingglass.circle.fill",
                color: .accentColor
            )

            if let disk = vm.diskInfo {
                StatCard(
                    title: "Kullanılabilir Alan",
                    value: ByteFormatter.compact(from: disk.freeSpace),
                    subtitle: "%\(Int(disk.freeFraction * 100)) kapasite boş",
                    icon: "checkmark.seal.fill",
                    color: disk.freeFraction > 0.2 ? .teal : .orange
                )
            }
        }
    }
}

// MARK: - Kategoriler Bölümü

private struct CategoriesSection: View {
    @ObservedObject var vm: MainViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Modüller & Dosyalar", systemImage: "square.grid.2x2.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.leading, 4)

            VStack(spacing: 12) {
                ForEach(vm.categories) { category in
                    CategoryRow(category: category) {
                        vm.toggleCategory(category)
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Alt Temizleme Çubuğu

private struct CleanBottomBar: View {
    @ObservedObject var vm: MainViewModel

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                Text(ByteFormatter.compact(from: vm.totalReclaimable))
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(vm.totalReclaimable > 0 ? .primary : .secondary)
                    .tracking(-0.5)
                
                Text(vm.totalReclaimable > 0 ? "Temizlenmek üzere seçildi" : "Seçili dosya yok")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.8))
            }

            Spacer()

            Button("Yenile") {
                vm.startScan()
            }
            .buttonStyle(.plain)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)

            Button {
                vm.requestClean()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Sistemi Temizle")
                        .font(.system(size: 14, weight: .bold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    vm.totalReclaimable > 0
                    ? LinearGradient(colors: [.accentColor, .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [.secondary.opacity(0.2), .secondary.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .foregroundColor(vm.totalReclaimable > 0 ? .white : .secondary)
                .cornerRadius(10)
                .shadow(color: vm.totalReclaimable > 0 ? .accentColor.opacity(0.3) : .clear, radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .disabled(vm.totalReclaimable == 0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.secondary.opacity(0.15)),
            alignment: .top
        )
    }
}

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
        VStack(alignment: .leading, spacing: 12) {
            Label("Depolama", systemImage: "internaldrive.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            StorageBar(diskInfo: diskInfo, reclaimable: reclaimable)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - İstatistik Satırı

private struct StatsRow: View {
    @ObservedObject var vm: MainViewModel

    var body: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Geri Kazanılabilir",
                value: ByteFormatter.compact(from: vm.totalReclaimable),
                subtitle: "\(vm.selectedCategories.count) kategori seçildi",
                icon: "arrow.down.circle.fill",
                color: .green
            )

            StatCard(
                title: "Toplam Taranan",
                value: ByteFormatter.compact(from: vm.totalScanned),
                subtitle: "\(vm.categories.count) kategori tarandı",
                icon: "magnifyingglass",
                color: .accentColor
            )

            if let disk = vm.diskInfo {
                StatCard(
                    title: "Boş Alan",
                    value: ByteFormatter.compact(from: disk.freeSpace),
                    subtitle: "%\(Int(disk.freeFraction * 100)) kullanılabilir",
                    icon: "checkmark.circle.fill",
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
        VStack(alignment: .leading, spacing: 10) {
            Label("Kategoriler", systemImage: "folder.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                ForEach(vm.categories) { category in
                    CategoryRow(category: category) {
                        vm.toggleCategory(category)
                    }
                }
            }
        }
    }
}

// MARK: - Alt Temizleme Çubuğu

private struct CleanBottomBar: View {
    @ObservedObject var vm: MainViewModel

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 1) {
                Text(ByteFormatter.compact(from: vm.totalReclaimable))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(vm.totalReclaimable > 0 ? .primary : .secondary)
                Text("temizlenecek seçildi")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Tekrar Tara") {
                vm.startScan()
            }
            .buttonStyle(.bordered)

            Button {
                vm.requestClean()
            } label: {
                Label("Şimdi Temizle", systemImage: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.totalReclaimable == 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Rectangle()
                .fill(.regularMaterial)
                .ignoresSafeArea()
        )
    }
}

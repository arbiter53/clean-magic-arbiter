import SwiftUI

// MARK: - Temizleme Ekranı

struct CleaningView: View {
    @ObservedObject var vm: MainViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                CircularProgress(
                    progress: vm.cleanupProgress?.fraction ?? 0,
                    lineWidth: 10,
                    color: .accentColor,
                    size: 120
                )

                VStack(spacing: 2) {
                    Text("\(Int((vm.cleanupProgress?.fraction ?? 0) * 100))%")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text("temizlendi")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            VStack(spacing: 6) {
                Text("Temizleniyor…")
                    .font(.system(size: 22, weight: .bold))
                if let progress = vm.cleanupProgress, !progress.currentPath.isEmpty {
                    Text(progress.currentPath)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 300)
                }
            }

            if let progress = vm.cleanupProgress {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.green)
                    Text("\(ByteFormatter.compact(from: progress.bytesFreed)) boşaltıldı")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.1))
                )
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Tamamlandı Ekranı

struct CompletedView: View {
    @ObservedObject var vm: MainViewModel

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.green.opacity(0.2), Color.green.opacity(0.0)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            if let result = vm.cleanupResult {
                VStack(spacing: 8) {
                    Text(ByteFormatter.compact(from: result.freedBytes))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    Text("\(result.deletedCount) öğe temizlendi")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }

                if !result.errors.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 13))
                        Text("\(result.errors.count) öğe silinemedi")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }

            if let disk = vm.diskInfo {
                DiskSummaryPill(diskInfo: disk)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    vm.reset()
                }
            } label: {
                Label("Tekrar Tara", systemImage: "arrow.clockwise")
                    .frame(width: 160, height: 38)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

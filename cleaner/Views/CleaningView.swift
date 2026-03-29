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
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundColor(.green)
                        .tracking(-0.5)
                        
                    Text("\(result.deletedCount) modül kancası ve dosya kalıntısı temizlendi")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .padding(.vertical, 10)

                if !result.errors.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                                
                            Text("\(result.errors.count) öğe güvenlik veya yetki sebebiyle silinemedi")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(result.errors.prefix(50)) { errorItem in
                                    HStack(alignment: .top, spacing: 10) {
                                        Rectangle()
                                            .fill(Color.orange.opacity(0.4))
                                            .frame(width: 2, height: 16)
                                            .cornerRadius(1)
                                            
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(errorItem.path.replacingOccurrences(of: FileManager.default.homeDirectoryForCurrentUser.path, with: "~"))
                                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                                .foregroundColor(.primary.opacity(0.8))
                                                .lineLimit(1)
                                                .truncationMode(.head)
                                                
                                            Text(errorItem.reason)
                                                .font(.system(size: 10))
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                                
                                if result.errors.count > 50 {
                                    Text("+ \(result.errors.count - 50) benzer hata daha alındı...")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.orange)
                                        .padding(.top, 4)
                                        .padding(.leading, 12)
                                }
                            }
                        }
                        .frame(maxHeight: 140)
                        .padding(12)
                        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                }
            }

            if let disk = vm.diskInfo {
                DiskSummaryPill(diskInfo: disk)
                    .padding(.top, 8)
            }

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    vm.reset()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 15, weight: .bold))
                    Text("Yeni Bir Tarama Başlat")
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [.accentColor.opacity(0.9), .purple.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: .accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.top, 16)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

import SwiftUI

// MARK: - Depolama Çubuğu

struct StorageBar: View {
    let diskInfo: DiskInfo
    let reclaimable: Int64

    private var cleanFraction: Double {
        guard diskInfo.totalSpace > 0 else { return 0 }
        return min(Double(reclaimable) / Double(diskInfo.totalSpace), 1.0)
    }

    private var usedWithoutClean: Double {
        max(diskInfo.usedFraction - cleanFraction, 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Kullanılan", systemImage: "internaldrive.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(ByteFormatter.compact(from: diskInfo.usedSpace))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    + Text(" / ")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    + Text(ByteFormatter.compact(from: diskInfo.totalSpace))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(nsColor: .separatorColor).opacity(0.3))
                        .frame(height: 14)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor)
                        .frame(width: max(geo.size.width * usedWithoutClean, 0), height: 14)

                    if reclaimable > 0 {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.green.opacity(0.8), .teal.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: max(geo.size.width * cleanFraction, 0),
                                height: 14
                            )
                            .offset(x: geo.size.width * usedWithoutClean)
                    }
                }
            }
            .frame(height: 14)

            HStack(spacing: 16) {
                LegendDot(color: .accentColor, label: "Sistem ve Uygulamalar")
                if reclaimable > 0 {
                    LegendDot(color: .green, label: "Geri Kazanılabilir: \(ByteFormatter.compact(from: reclaimable))")
                }
                LegendDot(color: Color(nsColor: .separatorColor).opacity(0.5), label: "Boş")
            }
        }
    }
}

// MARK: - Açıklama Noktası

private struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

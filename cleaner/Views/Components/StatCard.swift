import SwiftUI

// MARK: - İstatistik Kartı

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color

    init(title: String, value: String, subtitle: String? = nil, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.8), color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)
                        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
                        
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                    .tracking(-0.5)
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.2)
                
                if let subtitle {
                    Text(verbatim: subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.7))
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Dairesel İlerleme Halkası

struct CircularProgress: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color
    let size: CGFloat

    init(progress: Double, lineWidth: CGFloat = 6, color: Color = .accentColor, size: CGFloat = 60) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.color = color
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
        }
        .frame(width: size, height: size)
    }
}

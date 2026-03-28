import SwiftUI

// MARK: - Kategori Satırı

struct CategoryRow: View {
    let category: CleanCategory
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category.localizedName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                Text(category.localizedDescription)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Group {
                if category.isScanning {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 60)
                } else if category.scannedSize > 0 {
                    Text(ByteFormatter.compact(from: category.scannedSize))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(category.isSelected ? iconColor : .secondary)
                        .frame(width: 60, alignment: .trailing)
                } else if let err = category.scanError {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .help(err)
                        .frame(width: 60, alignment: .trailing)
                } else {
                    Text("–")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(width: 60, alignment: .trailing)
                }
            }

            Toggle("", isOn: Binding(
                get: { category.isSelected },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.switch)
            .controlSize(.small)
            .disabled(!category.hasContent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    category.isSelected && category.hasContent
                        ? iconColor.opacity(0.3)
                        : Color.clear,
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: category.isSelected)
    }

    private var iconColor: Color {
        switch category.type {
        case .caches:      return .blue
        case .logs:        return .orange
        case .trash:       return .red
        case .derivedData: return .purple
        }
    }
}

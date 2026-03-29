import SwiftUI

// MARK: - Kategori Satırı

struct CategoryRow: View {
    let category: CleanCategory
    let onToggle: () -> Void

    @State private var isExpanded = false
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Premium İkon (Kademeli Renk Gecisli ve Gölgeli)
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [iconColor.opacity(0.8), iconColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
                        .shadow(color: iconColor.opacity(0.25), radius: 5, x: 0, y: 3)
                        
                    Image(systemName: category.icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(category.localizedName)
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                        .tracking(0.3)
                    
                    Text(category.localizedDescription)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.8))
                        .lineLimit(1)
                }

                Spacer(minLength: 16)

                // Genişletme İkonu (Mikro Etkileşimli)
                if !category.items.isEmpty {
                    ZStack {
                        Circle()
                            .fill(isHovered ? Color.secondary.opacity(0.08) : Color.clear)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .foregroundColor(isExpanded ? iconColor : .secondary.opacity(0.6))
                            .font(.system(size: 12, weight: .bold))
                    }
                    .contentShape(Circle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            isExpanded.toggle()
                        }
                    }
                    .help("Konum detaylarını ve klasör ağacını göster")
                }

                Group {
                    if category.isScanning {
                        ProgressView()
                            .scaleEffect(0.6)
                            .frame(width: 65, alignment: .trailing)
                    } else if category.scannedSize > 0 {
                        Text(ByteFormatter.compact(from: category.scannedSize))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(category.isSelected ? iconColor : .secondary)
                            .frame(width: 65, alignment: .trailing)
                    } else if let err = category.scanError {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .help(err)
                            .frame(width: 65, alignment: .trailing)
                    } else {
                        Text("–")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.5))
                            .frame(width: 65, alignment: .trailing)
                    }
                }

                Toggle("", isOn: Binding(
                    get: { category.isSelected },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)
                .tint(iconColor)
                .disabled(!category.hasContent)
                .padding(.leading, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isHovered ? Color.secondary.opacity(0.03) : Color.clear)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }

            // Ayrıntılar (Ağaç Yapısı Esintili UI)
            if isExpanded {
                Divider()
                    .overlay(iconColor.opacity(0.2))
                    .padding(.horizontal, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(category.items.prefix(150)) { item in
                            HStack(spacing: 10) {
                                // Ağaç dalı efekti
                                Rectangle()
                                    .fill(iconColor.opacity(0.3))
                                    .frame(width: 2, height: 16)
                                    .cornerRadius(1)
                                
                                Image(systemName: item.isDirectory ? "folder.fill" : "doc.text.fill")
                                    .foregroundColor(item.isDirectory ? iconColor.opacity(0.8) : .secondary.opacity(0.5))
                                    .font(.system(size: 11))
                                    .frame(width: 16)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.primary.opacity(0.85))
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    
                                    Text(item.path.replacingOccurrences(of: FileManager.default.homeDirectoryForCurrentUser.path, with: "~"))
                                        .font(.system(size: 10, design: .default))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.head)
                                }
                                
                                Spacer()
                                
                                Text(ByteFormatter.compact(from: item.size))
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundColor(.secondary.opacity(0.8))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.08))
                                    .cornerRadius(6)
                            }
                            .padding(.vertical, 3)
                        }
                        
                        if category.items.count > 150 {
                            HStack {
                                Spacer()
                                Text("+ \(category.items.count - 150) ek dosya tespit edildi...")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(iconColor)
                                    .padding(.vertical, 8)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }
                .frame(maxHeight: 250)
                .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
                .scrollIndicators(.hidden)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    category.isSelected && category.hasContent
                        ? iconColor.opacity(0.4)
                        : Color.secondary.opacity(0.15),
                    lineWidth: category.isSelected && category.hasContent ? 1.5 : 0.5
                )
        )
        .shadow(color: Color.black.opacity(isHovered ? 0.08 : 0.03), radius: isHovered ? 8 : 4, x: 0, y: isHovered ? 4 : 2)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: category.isSelected)
        .onChange(of: category.items.isEmpty) { isEmpty in
            if isEmpty {
                isExpanded = false
            }
        }
    }

    private var iconColor: Color {
        switch category.type {
        case .caches:        return .blue
        case .logs:          return .orange
        case .browserData:   return .cyan
        case .mailDownloads: return .teal
        case .largeFiles:    return .pink
        case .oldDownloads:  return .indigo
        case .languageFiles: return .mint
        case .trash:         return .red
        case .derivedData:   return .purple
        }
    }
}

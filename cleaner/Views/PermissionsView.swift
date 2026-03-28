import SwiftUI

// MARK: - İzin Bandı

struct PermissionsBanner: View {
    @ObservedObject var permissionService = PermissionService.shared
    @State private var showSheet = false

    var body: some View {
        if permissionService.fullDiskAccess == .denied {
            HStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .red.opacity(0.8)],
                                       startPoint: .top, endPoint: .bottom)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text("Tam Disk Erişimi Önerilir")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Daha kapsamlı temizlik için izin verin.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button("Nasıl Veririm?") { showSheet = true }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                Button("Erişim Ver") {
                    permissionService.openFullDiskAccessSettings()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.orange)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.orange.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.orange.opacity(0.22), lineWidth: 1)
                    )
            )
            .sheet(isPresented: $showSheet) {
                FDAOnboardingView()
            }
        }
    }
}

// MARK: - FDA Onboarding Ana Ekran

struct FDAOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var permissions = PermissionService.shared
    @State private var isOpened = false
    @State private var pulseIcon = false
    @State private var stepAppeared = false

    private let steps: [(icon: String, color: Color, title: String, detail: String)] = [
        ("apple.logo",           .primary,  "Sistem Ayarları",        "Sol üst menüden  → Sistem Ayarları'nı aç"),
        ("hand.raised.fill",     .blue,     "Gizlilik ve Güvenlik",   "Sol kenar çubuğunda 'Gizlilik ve Güvenlik'e tıkla"),
        ("internaldrive.fill",   .purple,   "Tam Disk Erişimi",       "Listenin altına kaydırıp 'Tam Disk Erişimi'ni seç"),
        ("sparkles",             .orange,   "Clean Magic - Arbiter",        "Listede Clean Magic - Arbiter'ı bulup geçişi Açık'a al"),
        ("arrow.clockwise",      .green,    "Geri Dön",               "Uygulamaya geri dön — izin otomatik algılanır"),
    ]

    var body: some View {
        VStack(spacing: 0) {

            // ── Hero ──────────────────────────────────────────────────────
            heroSection

            // ── Adımlar ───────────────────────────────────────────────────
            stepsSection

            // ── Alt Bar ───────────────────────────────────────────────────
            bottomBar
        }
        .frame(width: 460)
        .fixedSize(horizontal: true, vertical: true)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseIcon = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.15)) {
                stepAppeared = true
            }
        }
        .onChange(of: permissions.fullDiskAccess) { status in
            if status == .granted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
            }
        }
    }

    // MARK: Hero

    private var heroSection: some View {
        ZStack {
            // Arka plan degrade
            LinearGradient(
                stops: [
                    .init(color: .orange.opacity(0.18), location: 0),
                    .init(color: Color.accentColor.opacity(0.10), location: 0.6),
                    .init(color: .clear, location: 1),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Dekoratif daireler
            Circle()
                .fill(.orange.opacity(0.06))
                .frame(width: 220)
                .offset(x: -80, y: -30)
            Circle()
                .fill(Color.accentColor.opacity(0.06))
                .frame(width: 160)
                .offset(x: 120, y: 40)

            VStack(spacing: 18) {
                // İkon grubu
                ZStack {
                    // Nabız halkası
                    Circle()
                        .stroke(.orange.opacity(pulseIcon ? 0.0 : 0.3), lineWidth: 2)
                        .frame(width: pulseIcon ? 110 : 80)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                   value: pulseIcon)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.orange.opacity(0.25), .clear],
                                center: .center, startRadius: 10, endRadius: 56
                            )
                        )
                        .frame(width: 90)

                    // FDA verilince ikon değişir
                    ZStack {
                        if permissions.fullDiskAccess == .granted {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 42, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(colors: [.green, .teal],
                                                   startPoint: .top, endPoint: .bottom)
                                )
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 42, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(colors: [.orange, .red.opacity(0.75)],
                                                   startPoint: .top, endPoint: .bottom)
                                )
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.6),
                               value: permissions.fullDiskAccess)
                }

                VStack(spacing: 6) {
                    if permissions.fullDiskAccess == .granted {
                        Text("Erişim Verildi!")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(colors: [.green, .teal],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                        Text("Clean Magic - Arbiter artık tüm dosyalara erişebilir.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } else {
                        Text("Tam Disk Erişimi")
                            .font(.system(size: 22, weight: .bold))
                        Text("Önbellekleri, günlükleri ve Xcode verilerini\ntamamen temizleyebilmek için bu izne ihtiyaç var.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: permissions.fullDiskAccess)
            }
            .padding(.top, 36)
            .padding(.bottom, 28)
        }
    }

    // MARK: Adımlar

    private var stepsSection: some View {
        VStack(spacing: 0) {
            Divider()

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    StepCard(
                        number: index + 1,
                        icon: step.icon,
                        color: step.color,
                        title: step.title,
                        detail: step.detail,
                        isLast: index == steps.count - 1
                    )
                    .opacity(stepAppeared ? 1 : 0)
                    .offset(x: stepAppeared ? 0 : -12)
                    .animation(
                        .easeOut(duration: 0.4).delay(Double(index) * 0.07),
                        value: stepAppeared
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }

    // MARK: Alt Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()

            // Sandbox nedeniyle yeniden başlatma gerekebilir — kullanıcıyı bilgilendir
            if isOpened && permissions.fullDiskAccess == .denied {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 13))
                    Text("İzin verdikten sonra uygulama algılamıyorsa yeniden başlatın.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Yeniden Başlat") {
                        permissions.relaunch()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 4)
            }

            HStack(spacing: 10) {
                Button("Şimdilik Geç") { dismiss() }
                    .buttonStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)

                Spacer()

                if permissions.fullDiskAccess == .granted {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Tamam, Harika!")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .frame(height: 32)
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(GreenGradientButtonStyle())
                } else {
                    Button {
                        isOpened = true
                        permissions.openFullDiskAccessSettings()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.right.square.fill")
                            Text(isOpened ? "Ayarları Tekrar Aç" : "Sistem Ayarlarını Aç")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .frame(height: 32)
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(OrangeGradientButtonStyle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Adım Kartı

private struct StepCard: View {
    let number: Int
    let icon: String
    let color: Color
    let title: String
    let detail: String
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            // Numara + bağlantı çizgisi
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color == .primary ? Color(nsColor: .labelColor) : color)
                }

                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.2), color.opacity(0.04)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 4)
                }
            }
            .frame(width: 34)

            // Metin
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("\(number)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(color == .primary ? Color(nsColor: .labelColor) : color)
                        .frame(width: 16, height: 16)
                        .background(
                            Circle().fill(color.opacity(color == .primary ? 0.1 : 0.1))
                        )
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineSpacing(1.5)
                    .padding(.leading, 22)
            }
            .padding(.top, 7)
            .padding(.bottom, isLast ? 0 : 14)

            Spacer()
        }
    }
}

// MARK: - Özel Buton Stilleri

private struct OrangeGradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: configuration.isPressed
                                ? [.orange.opacity(0.8), .red.opacity(0.6)]
                                : [.orange, .red.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct GreenGradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: configuration.isPressed
                                ? [.green.opacity(0.8), .teal.opacity(0.8)]
                                : [.green, .teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - İzin Kılavuzu Alias

struct PermissionsGuideView: View {
    var body: some View { FDAOnboardingView() }
}

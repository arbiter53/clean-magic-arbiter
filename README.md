<div align="center">

<img src="cleaner/Assets.xcassets/AppIcon.appiconset/128.png" width="100" alt="Clean Magic - Arbiter"/>

# Clean Magic - Arbiter

**macOS için hızlı, güvenli ve şık sistem temizleme uygulaması**

![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![Platform](https://img.shields.io/badge/Platform-macOS%2013%2B-blue?logo=apple)
![UI](https://img.shields.io/badge/UI-SwiftUI-purple)
![License](https://img.shields.io/badge/License-MIT-green)
![Made by](https://img.shields.io/badge/Made%20by-topcuyazilim.com-black)

</div>

---

## Ekran Görüntüleri

| Ana Ekran | Tarama Sonuçları | Temizleme | Tam Disk Erişimi |
|:---------:|:----------------:|:---------:|:----------------:|
| Basit başlangıç ekranı | Kategori bazlı boyutlar | Gerçek zamanlı ilerleme | Adım adım kılavuz |

---

## Özellikler

- 🔍 **Akıllı Tarama** — Kullanıcı önbelleği, sistem günlükleri, çöp kutusu ve Xcode türetilmiş verilerini tarar
- 🧹 **Güvenli Temizleme** — Kritik sistem dosyaları asla silinmez; beyaz liste koruması
- 📊 **Depolama Görselleştirme** — Disk kullanımı ve geri kazanılabilir alan için renkli grafikler
- 🔐 **Tam Disk Erişimi Kılavuzu** — Adım adım izin rehberi, otomatik algılama
- 🌙 **Dark Mode** — Tam karanlık mod desteği
- 🇹🇷 **Türkçe Arayüz** — Tamamen Türkçe kullanıcı deneyimi

---

## Temizlenen Kategoriler

| Kategori | Konum | Açıklama |
|---|---|---|
| 🔵 Kullanıcı Önbelleği | `~/Library/Caches` | Uygulamaların geçici önbellek dosyaları |
| 🟠 Sistem Günlükleri | `~/Library/Logs` | Uygulama ve sistem log dosyaları |
| 🔴 Çöp Kutusu | `~/.Trash` | Kalıcı silinmeyi bekleyen dosyalar |
| 🟣 Xcode Türetilmiş Veri | `~/Library/Developer/Xcode/DerivedData` | Xcode derleme artifaktları |

---

## Teknoloji

- **Dil:** Swift 5.9
- **UI:** SwiftUI (macOS native)
- **Mimari:** MVVM
- **Eşzamanlılık:** Swift Concurrency (async/await, Actor)
- **Minimum Sürüm:** macOS 13.0 Ventura

---

## Kurulum

### Geliştirici olarak çalıştırma

```bash
git clone https://github.com/arbiter53/clean-magic-arbiter.git
cd clean-magic-arbiter
open cleaner.xcodeproj
```

Xcode'da `⌘R` ile çalıştırın.

### Gereksinimler

- Xcode 15+
- macOS 13.0+
- Apple Developer hesabı (imzalama için)

---

## Güvenlik

Uygulama aşağıdaki koruma katmanlarına sahiptir:

- `/System`, `/usr`, `/bin` gibi sistem yolları **hiçbir zaman** silinmez
- Yalnızca kullanıcı ev dizini (`~/`) içinde çalışır
- Masaüstü, Belgeler, İndirilenler gibi kritik klasörler korunur
- Silme işlemi öncesi **onay diyaloğu** gösterilir

---

## Proje Yapısı

```
cleaner/
├── App/
│   └── cleanerApp.swift          # Uygulama giriş noktası
├── Models/
│   ├── CleanCategory.swift       # Kategori modeli ve uygulama durumu
│   ├── ScanItem.swift            # Taranan dosya modeli
│   └── DiskInfo.swift            # Disk bilgisi modeli
├── Services/
│   ├── ScannerService.swift      # Dosya tarama servisi (Actor)
│   ├── CleanupService.swift      # Güvenli silme servisi (Actor)
│   └── PermissionService.swift   # Tam Disk Erişimi yönetimi
├── ViewModels/
│   └── MainViewModel.swift       # Ana ViewModel (@MainActor)
├── Views/
│   ├── MainView.swift            # Kök view, durum yönetimi
│   ├── ScanView.swift            # Tarama ekranı
│   ├── ResultsView.swift         # Sonuçlar ekranı
│   ├── CleaningView.swift        # Temizleme & tamamlanma ekranı
│   ├── PermissionsView.swift     # FDA onboarding
│   └── Components/
│       ├── CategoryRow.swift     # Kategori satır bileşeni
│       ├── StorageBar.swift      # Depolama çubuğu
│       └── StatCard.swift        # İstatistik kartı
└── Utilities/
    ├── ByteFormatter.swift       # Byte formatlama
    └── Constants.swift           # Güvenlik sabitleri
```

---

## Katkıda Bulunma

1. Fork'layın
2. Feature branch oluşturun (`git checkout -b feature/yeni-ozellik`)
3. Değişikliklerinizi commit'leyin (`git commit -m 'Yeni özellik eklendi'`)
4. Branch'i push'layın (`git push origin feature/yeni-ozellik`)
5. Pull Request açın

---

## Lisans

MIT License — Detaylar için `LICENSE` dosyasına bakın.

---

<div align="center">

[topcuyazilim.com](https://topcuyazilim.com) tarafından geliştirilmiştir

</div>

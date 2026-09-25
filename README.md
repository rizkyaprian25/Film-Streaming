# CineFlow - Mobile Film & Series Streaming App

<p align="center">
  <strong>Aplikasi Mobile Streaming Film & Serial Sinematik Bergaya LokLok (Tanpa Login / Zero Friction)</strong>
</p>

---

## 🌟 Fitur Unggulan

* **Tanpa Login (*Zero Login Friction*):** Pengguna dapat langsung membuka aplikasi dan menikmati seluruh katalog tontonan tanpa registrasi atau hambatan otentikasi.
* **Beranda Sinematik (*LokLok Style Feed*):**
  * *Hero Banner Carousel* dengan poster berkualitas tinggi dan tombol tonton instan.
  * *Pills Filter Cepat:* Semua, Film, Serial TV, Anime.
  * Barisan konten horisontal (*Trending*, *Popular Movies*, *TV Series*, *Top Anime*).
* **Lanjutkan Menonton (*Continue Watching - LokLok Signature*):**
  * Otomatis menyimpan progres tontonan (menit & detik terakhir) ke penyimpanan lokal aman.
  * Kartu tontonan menampilkan bilah persentase durasi tontonan dan tombol *resume* 1-ketukan.
* **Pemutar Video Kustom (*Custom In-App Player*):**
  * Kontrol transparan *Apple HIG Liquid Glass* dengan auto-hide cerdas.
  * Tombol lewati cepat ($\pm 10$ detik), slider timeline presisi.
  * **Pemilih Episode Langsung di Dalam Player:** Ganti episode serial tanpa perlu keluar dari layar pemutar.
  * **Pemilih Resolusi:** Pilihan kualitas video (Auto, 1080p FHD, 720p HD, 480p).
  * **Dukungan Subtitle:** Pilihan trek subtitle multibahasa (Bahasa Indonesia, English, dll.).
* **Eksplorasi & Filter Cerdas (*Discover*):**
  * Filter genre (Aksi, Sci-Fi, Fantasi, Thriller, Drama, Anime, Misteri, Petualangan).
  * Filter jenis media (Film / Serial TV / Anime).
  * Tata letak grid poster responsif dengan badge rating dan resolusi HD.
* **Pencarian Cepat (*Instant Search with Debouncing*):**
  * Input pencarian dengan proteksi debounce 300ms untuk performa efisien.
  * Tag rekomendasi pencarian populer.
* **Koleksi Saya (*Local-First Library*):**
  * Tab *Riwayat Tontonan* dengan fitur hapus geser (*swipe to dismiss*).
  * Tab *Watchlist Saya* untuk menyimpan judul-judul favorit.
* **Resiliensi & Keandalan (*Enterprise Grade*):**
  * *Global Error Boundary* pelindung crash fatal (mencegah *White Screen of Death*).
  * *Self-Healing Data:* Pemulihan otomatis jika cache lokal tidak tersedia.

---

## 🏗️ Arsitektur Proyek (Feature-First)

Mengacu pada standar **Clean Architecture & Ponytail Protocol**:

```text
lib/
├── core/
│   ├── theme/             # Token warna HIG, skala tipografi, & tema gelap
│   ├── storage/           # Local storage SSOT (Riwayat & Watchlist)
│   ├── error/             # Global Error Boundary & Fallback UI
│   └── widgets/           # Komponen UI bersama (MediaCard, SectionHeader)
├── contracts/
│   ├── models.dart        # SSOT Data Model (MediaItem, MediaDetail, Episode, StreamSource)
│   ├── api_contracts.dart # Interface StreamProvider & ApiResponse
│   ├── mock_data.dart     # Dataset kaya dengan video stream HLS/MP4 teruji
│   └── mock_provider.dart # Implementasi provider mandiri untuk pengujian
├── features/
│   ├── shell/             # App Shell & Bilah Navigasi Bawah Transparan
│   ├── home/              # Katalog Beranda & Hero Carousel
│   ├── discover/          # Filter Kategori & Grid Konten
│   ├── search/            # Pencarian instan debounced
│   ├── detail/            # Layar detail, sinopsis, & pemilih episode
│   ├── player/            # Pemutar video kustom dengan in-player sheet
│   └── library/           # Riwayat tontonan & Watchlist tersimpan
└── main.dart              # Entrypoint, DI AppScope, & System UI
```

---

## 🚀 Panduan Memulai (*Quick Start*)

### Prasyarat
* Flutter SDK $\ge 3.44.0$
* Dart SDK $\ge 3.12.0$
* Android SDK 34+ / Xcode untuk iOS

### Langkah Instalasi & Menjalankan

1. **Clone repositori dan pasang dependensi:**
   ```bash
   flutter pub get
   ```

2. **Jalankan static analyzer & uji kualitas:**
   ```bash
   flutter analyze
   flutter test
   ```

3. **Jalankan aplikasi di perangkat emulator/fisik:**
   ```bash
   flutter run
   ```

---

## 🔒 Kebijakan Keamanan & Privasi
* Tidak ada data identitas pribadi atau login yang dikirim ke server.
* Seluruh riwayat tontonan dan daftar bookmark tersimpan secara lokal di perangkat Anda.

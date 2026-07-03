# Prompt Refactor UI/UX — Café Finder (Flutter)

> Salin seluruh isi di bawah ini ke Claude untuk fine-tuning desain. Prompt sudah berisi konteks teknis, kondisi UI saat ini, target hasil, dan spesifikasi skeleton loading untuk semua screen.

---

## PROMPT

Kamu adalah senior product designer + Flutter UI engineer. Aku punya app Flutter bernama **Café Finder** (cari & review kafe). Aku mau refactor UI/UX biar jauh lebih bagus, modern, konsisten, dan punya skeleton loading di semua screen. Pertahankan arsitektur & logika yang ada — **ubah hanya layer presentation (UI)**, jangan ganti bloc/event/state/repository.

### Stack & Constraint
- Flutter, Material 3 (`useMaterial3: true`), `google_fonts` (Poppins), `flutter_bloc`, `go_router`, `cached_network_image`, `shimmer: ^3.0.0`, `flutter_map`.
- Arsitektur clean: `features/<x>/presentation/{pages,widgets,bloc}`. Core di `lib/core/`.
- State management BLoC/Cubit sudah ada. **Jangan ubah** nama event/state. Cuma konsumsi state untuk render UI baru.
- Komponen reusable yang sudah ada: `GlobalShimmer`, `ShimmerAvatar`, `ShimmerCard`, `ShimmerList` (`lib/core/components/global_shimmer.dart`), `GlobalEmptyState`, `GlobalErrorState`, `InteractiveButton`, `GlassPanel`, `SmartListView`.

### Design System yang diinginkan
Tema saat ini (`lib/core/config/app_theme.dart`) — palet coffee, perlu di-upgrade jadi design system penuh:
```
primary       #6F4E37 (coffee brown)
primaryLight  #A67B5B
secondary     #D4A574 (caramel)
background     #FAF7F2 (cream)
surface        #FFFFFF
error          #B00020
textPrimary   #1A1A1A
textSecondary #757575
```
Yang aku mau kamu kerjakan untuk design system:
1. **Color scheme lengkap** Material 3 (light + dark mode) — turunkan tonal palette dari primary coffee. Tambah `surfaceContainer`, `outline`, semantic colors (success/warning).
2. **Typography scale** konsisten pakai Poppins: displayLarge → labelSmall, dengan weight & letter-spacing yang rapi.
3. **Spacing & radius token** terpusat (mis. `AppSpacing`, `AppRadius`) — stop hardcode angka `16`, `12`, `8` di tiap widget.
4. **Elevation/shadow** lembut & konsisten (cards, sheets, FAB).
5. **Component theme**: ElevatedButton, FilledButton, OutlinedButton, Chip, ChoiceChip, TextField/InputDecoration, Card, AppBar, BottomNavigationBar, SnackBar — semua diberi style default di theme biar widget bersih.
6. Dukung **dark mode** penuh.

### Prinsip UX
- Hierarki visual jelas, whitespace cukup, tap target ≥ 48px.
- Micro-interaction: ripple, hero transition gambar kafe (list → detail), animasi favorite (scale/bounce), smooth page transition.
- Loading **selalu** pakai skeleton/shimmer (bukan `CircularProgressIndicator` di tengah). Empty state & error state pakai ilustrasi + CTA.
- Aksesibilitas: kontras AA, semantic label, text scaling aman.

### Screen yang harus diperbaiki (kondisi sekarang → target)

1. **Splash** (`features/splash/.../splash_page.dart`)
   Sekarang: icon cafe + text + spinner di background coffee.
   Target: branding lebih hidup — logo animasi (fade/scale), gradient halus, tagline. Tetap simpel.

2. **Login & Register** (`features/auth/.../login_page.dart`, `register_page.dart`)
   Sekarang: form polos, TextFormField default, AppBar "Login".
   Target: layout welcoming — header/ilustrasi, input modern (filled, icon, show/hide password), tombol full-width, link "Register/Login" rapi, error inline, loading state di tombol (bukan spinner gantiin tombol).

3. **Places List / Home tab** (`features/places/.../places_list_tab.dart` + `place_card.dart`)
   Sekarang: AppBar dengan search + ChoiceChip kategori; ListView `PlaceCard` (gambar 150px, nama, rating, kategori, alamat). FAB add location.
   Target: 
   - Search bar lebih modern (rounded, shadow lembut, mungkin di body bukan AppBar bottom).
   - Category chips dengan style selected/unselected jelas, smooth.
   - `PlaceCard` redesign: gambar dengan gradient overlay, badge rating floating, badge kategori, ikon favorite di card, jarak/distance kalau ada, typography rapi.
   - Pull-to-refresh & infinite scroll dipertahankan.
   - FAB lebih estetik.

4. **Place Detail** (`features/places/.../place_detail_screen.dart`)
   Sekarang: SliverAppBar 250px (PageView foto), nama+rating, chip kategori, alamat, deskripsi, ActionChip (Maps/IG/Web), tags/fasilitas, list ulasan (Card+ListTile), dialog tambah ulasan (Slider rating).
   Target:
   - Hero image carousel dengan indikator halaman, gradient, tombol back/favorite floating bergaya.
   - Section rapi berkartu: info utama, action buttons jadi tombol bergaya (bukan ActionChip kecil), fasilitas sebagai pill, rating summary (bar distribusi kalau memungkinkan).
   - Review card lebih bagus (avatar, nama, bintang, tanggal, isi).
   - Dialog/Bottom sheet tulis ulasan: star rating interaktif (tap bintang), textfield bagus, tombol submit dengan loading.

5. **Map tab** (`features/map/.../map_tab.dart`)
   Sekarang: FlutterMap OSM, marker merah, FAB my-location, PlaceCard floating saat marker dipilih.
   Target: custom marker bergaya (pin kafe), kartu floating bottom yang lebih bagus (mini, swipeable), tombol my-location & kontrol zoom rapi, loading state map.

6. **Favorites tab** (`features/favorites/.../favorites_tab.dart`)
   Sekarang: ListView Card horizontal (foto 100px + info).
   Target: kartu favorite konsisten dengan list utama, swipe-to-remove atau tombol hapus, animasi saat dihapus, empty state bagus.

7. **Profile tab** (`features/profile/.../profile_tab.dart`)
   Sekarang: avatar, nama, email, role badge, menu ListTile (Pengaturan, Bantuan), tombol Logout merah, dialog konfirmasi.
   Target: header profil bergaya (mungkin gradient/cover), stats (jumlah favorit/ulasan kalau ada), menu items dengan ikon dalam container, logout rapi, dark mode toggle kalau bisa.

8. **Bottom Navigation** (`features/places/.../home_page.dart`)
   Sekarang: `BottomNavigationBar` fixed 4 tab (Daftar/Peta/Favorit/Profil).
   Target: nav bar modern (Material 3 `NavigationBar` atau custom), indikator selected halus, ikon filled/outlined sesuai state.

### Skeleton Loading — WAJIB untuk SEMUA screen
Bikin skeleton/shimmer yang **meniru layout asli** tiap screen (bukan spinner generik). Buat file widget terpisah per screen di folder masing-masing (mis. `widgets/places_list_skeleton.dart`). Pakai `GlobalShimmer` yang sudah ada atau perbaiki. Spesifik:

- **Places List**: 5–6 skeleton card meniru `PlaceCard` (block gambar + garis judul + garis rating + garis alamat) + skeleton row chip kategori.
- **Place Detail**: skeleton hero image besar, block judul, chip, baris deskripsi, baris action button, beberapa skeleton review card.
- **Favorites**: 5–6 skeleton kartu horizontal (foto kotak + 2 garis teks).
- **Map**: skeleton/placeholder area peta + skeleton kartu bottom.
- **Profile**: skeleton avatar lingkaran + garis nama/email + skeleton menu items.
- **Reviews list / detail review**: skeleton avatar + garis.
- **Login/Register**: opsional, skeleton tombol saat submit.

Trigger skeleton dari status loading bloc yang sudah ada (mis. `PlacesListStatus.loading`, `PlaceDetailLoading`, `FavoritesLoading`, `MapStatus.loading`). Ganti semua `Center(child: CircularProgressIndicator())` dengan skeleton yang sesuai.

### Deliverable yang aku minta
1. File `app_theme.dart` baru (light + dark) + file token (`app_spacing.dart`, `app_radius.dart`, `app_typography.dart` kalau perlu).
2. Kode Flutter lengkap & siap pakai untuk tiap screen yang di-redesign (full file, bukan potongan).
3. Widget skeleton per screen (full file).
4. Komponen reusable baru kalau perlu (mis. `AppButton`, `RatingStars`, `SectionHeader`, `CafeImage` dengan hero).
5. Catatan singkat tiap perubahan + cara pasang (import, ganti widget mana).

### Aturan
- Output berupa kode Dart yang langsung kompilasi (Flutter stable, Material 3, null-safety).
- Jangan ubah signature bloc/event/state. Kalau butuh data tambahan yang belum ada di state, tandai dengan `// TODO: butuh field X` jangan diasumsikan.
- Konsisten pakai design token, jangan hardcode warna/spacing.
- Sertakan dark mode.
- Bahasa UI tetap Indonesia (label "Cari kafe", "Favorit Saya", dll).

Mulai dengan: (1) design system + theme, (2) komponen reusable + skeleton, (3) screen satu per satu. Tanya kalau ada yang ambigu sebelum generate banyak kode.

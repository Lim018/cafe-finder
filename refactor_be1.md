# Refactor Backend — Perubahan untuk UI Baru (refactor1)

Integrasi UI baru **tidak mengubah** layer datasource/endpoint. Semua screen jalan dengan response API yang ada sekarang (UI degrade dengan baik kalau data tidak tersedia). Tapi ada **2 fitur UI baru** yang sekarang pakai data perkiraan/placeholder. Untuk akurat, backend perlu tambahan berikut.

Status: **semua OPSIONAL**. Tanpa ini app tetap kompilasi & jalan.

---

## 1. Rating Distribution (bar 5★→1★) — Place Detail

**Lokasi UI:** `place_detail_screen.dart` → widget `_RatingDistribution`.

**Kondisi sekarang:** bar distribusi dihitung dari `place.recentReviews` (list parsial review terbaru saja), **bukan** semua ulasan. UI memberi disclaimer label `"dari N ulasan*"` (tanda `*` = perkiraan).

**Yang dibutuhkan:** field distribusi akurat di response `GET /places/{id}`.

### Perubahan endpoint
`GET /places/{id}` — tambah objek `ratingDistribution` + `reviewCount`:

```json
{
  "id": 12,
  "name": "Kopi Tetangga",
  "avgRating": 4.3,
  "recommendationCount": 87,
  "reviewCount": 87,
  "ratingDistribution": {
    "5": 45,
    "4": 25,
    "3": 10,
    "2": 5,
    "1": 2
  },
  "reviews": [ ... ],
  "...": "field lain tetap"
}
```

Catatan: `ratingDistribution` = jumlah review per nilai bintang dari **seluruh** ulasan (bukan recent). `reviewCount` = total semua ulasan (kalau `recommendationCount` sudah berarti total review, boleh pakai itu, tidak perlu field baru).

### Dampak ke Flutter (kalau backend tambah field)
- `PlaceDetail` entity (`domain/entities/place_detail.dart`): tambah `final Map<int,int>? ratingDistribution;`
- `PlaceDetailModel.fromJson`: parse `json['ratingDistribution']`.
- `_RatingDistribution` widget: pakai field ini bila ada, fallback ke `recentReviews` bila null; hapus tanda `*`.

---

## 2. Statistik Profil (Ulasan / Dikunjungi)

**Lokasi UI:** `profile_tab.dart` → row `_StatCard` (Favorit / Ulasan / Dikunjungi).

**Kondisi sekarang:**
- **Favorit** → sudah jalan (dihitung dari `FavoritesBloc`).
- **Ulasan** → tampil `–` (placeholder, data belum ada).
- **Dikunjungi** → tampil `–` (placeholder, data belum ada).

**Yang dibutuhkan:** field statistik user di response auth (`GET /auth/me` / login / register — endpoint yang mengembalikan objek `user`).

### Perubahan endpoint
Tambah field di objek `user`:

```json
{
  "user": {
    "id": 3,
    "name": "Ali",
    "email": "ali@mail.com",
    "role": "user",
    "avatarUrl": null,
    "reviewsCount": 12,
    "visitedCount": 8
  }
}
```

- `reviewsCount` = total ulasan yang dibuat user.
- `visitedCount` = total tempat yang dikunjungi (kalau ada konsep visit/check-in; kalau tidak ada fitur ini, **drop saja** kartu "Dikunjungi" dari UI).

### Dampak ke Flutter (kalau backend tambah field)
- `User` entity (`domain/entities/user.dart`): tambah `final int reviewsCount;` `final int visitedCount;` (default 0).
- `UserModel.fromJson`: parse field baru.
- `profile_tab.dart`: ganti `'–'` jadi `'${user.reviewsCount}'` & `'${user.visitedCount}'`, hapus TODO.

---

## TIDAK perlu perubahan backend

- **Jarak (distance) di list/card** — dihitung client-side dari `latitude`/`longitude` + lokasi device (`MapBloc.currentLocation`). Tidak butuh field `distance` dari API.
- **Dark mode** — murni client (`ThemeCubit`).
- **Skeleton loading** — murni client, pakai status loading bloc yang ada.
- **Search, kategori, favorites, map, reviews submit** — semua pakai endpoint existing tanpa perubahan.

---

## Ringkasan

| # | Endpoint | Field baru | Prioritas | Tanpa ini |
|---|----------|-----------|-----------|-----------|
| 1 | `GET /places/{id}` | `ratingDistribution`, (`reviewCount`) | sedang | bar rating = perkiraan dari recent reviews |
| 2 | auth `user` object | `reviewsCount`, `visitedCount` | rendah | kartu Ulasan & Dikunjungi tampil `–` |

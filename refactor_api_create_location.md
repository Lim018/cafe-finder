# Refactor API — Create Location (Tambah Lokasi)

Catatan integrasi mobile ↔ backend untuk fitur **Tambah Lokasi**. Mobile dev
only — **jangan ubah backend dari sini**. Dokumen ini menjelaskan cara kerja
backend saat ini + usulan opsional yang perlu dikerjakan tim backend jika
disetujui.

Sumber backend: `BackendAppsFindCafe/`.

---

## 1. Flow backend saat ini (yang dipakai mobile)

### Buat lokasi
`POST /api/v1/places` — butuh auth (Bearer token).

- Route: `src/routes/place.routes.ts:13`
  `router.post('/', auth, validate(createPlace), placeController.createPlace)`
- Controller: `src/controllers/place.controller.ts:23` → `createPlace(req.body, req.user.id)`
- Service: `src/services/place.service.ts:166`

Logika penting service:
- Baca `AppSettings.placeApprovalMode` (default `manual`).
- `manual` → `status = 'pending'`, `approvedVia = null`.
- `auto` → `status = 'approved'`, `approvedVia = 'auto'`.
- `slug` dibuat otomatis unik dari `name` (`generateUniqueSlug`).
- `submittedBy` = user id dari token.
- Response `201` shape standar `{ success, message, data }`; `data` = objek
  place hasil `prisma.place.create` (id `BigInt` → dikirim sebagai **string**
  karena patch `bigIntToJson`).

### Field (Joi `createPlace`, `src/validations/place.validation.ts:3`)

| Field | Wajib | Aturan |
|-------|-------|--------|
| `name` | ✅ | string, max 150 |
| `address` | ✅ | string |
| `latitude` | ✅ | number, -90..90 |
| `longitude` | ✅ | number, -180..180 |
| `categoryId` | ✅ | number **atau** string |
| `description` | — | string / '' / null |
| `district` | — | string / '' / null |
| `priceMin` | — | number ≥ 0 / null |
| `priceMax` | — | number ≥ 0 / null |
| `phone` | — | string / '' / null |
| `websiteUrl` | — | uri / '' / null |
| `instagramUrl` | — | uri / '' / null |
| `googleMapsUrl` | — | uri / '' / null |

Error validasi → `400` dengan `{ errors: { field: [pesan] } }`
(`src/middleware/validate.ts`). Mobile ambil pesan pertama untuk ditampilkan.

### Kategori (untuk dropdown)
`GET /api/v1/categories` — sudah dipakai app (`CategoriesCubit`). Dipakai untuk
mengisi `categoryId`.

### Foto (opsional, endpoint terpisah)
`POST /api/v1/places/:id/photos` — auth + **multipart** field `photo`
(`upload.single('photo')`, `src/routes/place.routes.ts:14`).
- Service: `src/services/place.service.ts:198` — upload ke Cloudinary, buat
  `PlacePhoto` (status pending/approved sesuai `photoApprovalMode`).
- Butuh Cloudinary env aktif di backend.

---

## 2. Yang sudah diimplementasi di mobile

- Halaman `AddPlacePage` (`lib/features/add_place/...`): form + map picker
  (flutter_map, tap/geser + tombol "Lokasi saya" via geolocator) + dropdown
  kategori.
- `POST /places` via `AddPlaceRemoteDataSource.createPlace`.
- FAB "Tambah Lokasi" di tab Daftar → route `/add-place` (hanya saat login).
- Setelah sukses: snackbar "menunggu persetujuan admin" + pop.

**Belum** upload foto dari mobile (butuh dependency `image_picker` + call
multipart kedua). Lihat usulan di bawah.

---

## 3. Usulan perubahan backend (OPSIONAL — untuk tim backend)

Semua di bawah **tidak wajib**; API sekarang sudah cukup untuk membuat lokasi.
Prioritas dari sudut pandang mobile:

### P1 — Foto dalam satu langkah (nice to have)
Sekarang buat-place dan upload-foto = 2 request, dan mobile harus tahu `id`
dari response create dulu. Usulan: terima foto opsional saat create (multipart)
**atau** endpoint yang menerima array `photoUrl`. Mengurangi round-trip &
state parsial (place dibuat tapi foto gagal).

### P2 — Konsistensi tipe `id` di response create
`data.id` dikirim sebagai string (efek `bigIntToJson`). Mobile sudah handle
(`int.tryParse`), tapi akan lebih aman jika didokumentasikan di Swagger bahwa
semua id adalah string numerik.

### P3 — Endpoint "lokasi yang saya ajukan"
Tidak ada cara bagi user melihat status submission-nya (pending/approved/
rejected). Usulan: `GET /api/v1/places/mine` (auth) → list place milik user
lintas status. Berguna untuk feedback setelah submit.

### P4 — Validasi duplikat / dekat
Backend belum cek apakah lokasi dengan koordinat/nama sangat mirip sudah ada.
Usulan opsional: warning "kemungkinan duplikat" saat create (non-blocking),
supaya tidak banyak entri kembar menunggu moderasi.

### P5 — Parse `googleMapsUrl` → lat/lng (opsional)
Jika user tempel link Google Maps, backend bisa auto-extract koordinat sebagai
fallback. Saat ini mobile mengandalkan map picker, jadi ini rendah prioritas.

---

## 4. Kontrak singkat (referensi cepat mobile)

```
POST /api/v1/places
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Kopi Senja",
  "address": "Jl. Mawar No. 12",
  "latitude": -7.2575,
  "longitude": 112.7521,
  "categoryId": 3,
  "district": "Wonokromo",        // opsional
  "description": "...",           // opsional
  "priceMin": 15000,              // opsional
  "priceMax": 40000,              // opsional
  "phone": "08xxxx",             // opsional
  "websiteUrl": "https://...",   // opsional
  "instagramUrl": "https://...", // opsional
  "googleMapsUrl": "https://..." // opsional
}

→ 201 { success, message, data: { id, slug, status: "pending", ... } }
→ 400 { success:false, errors: { field: ["pesan"] } }
→ 401 kalau token invalid/absen
```

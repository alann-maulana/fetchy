# Product Requirements Document (PRD)

## Aplikasi Mobile Manajemen REST API
Aplikasi mobile untuk mengelola dan menguji REST API dengan kemudahan penggunaan, dukungan import/export kompatibel Postman Collection v2.1, dan tampilan responsif untuk Android/iOS.

## Tujuan
- Menyediakan pengalaman mobile yang sederhana dan fungsional untuk membuat, menguji, dan menyimpan request API.
- Mendukung manajemen proyek/collection, environment, dan variabel.
- Menampilkan response dengan mode teks, JSON viewer, dan HTML viewer.
- Menggunakan Flutter, Material 3, dan Dio.

## Audiens Target
- Developer mobile dan web yang perlu menguji REST API secara on-the-go.
- Tim QA yang membutuhkan alat API ringan di perangkat mobile.
- Pengguna yang ingin menyimpan konfigurasi request API dalam collection dan environment.

## Fitur Utama

### 1. Manajemen API Client
- Request builder
  - Pilihan HTTP methods: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
  - Input URL endpoint
  - Query parameters dengan penambahan, pengeditan, dan penghapusan
  - Header request custom
  - Body request: raw, JSON, form-data, x-www-form-urlencoded
  - Authentication: Basic Auth, Bearer Token, API Key
- Response viewer
  - Status code dan status message
  - Response headers
  - Response body
- Content type handling
  - Default: plain text
  - JSON: tampilkan dengan JSON viewer terstruktur
  - HTML: tampilkan dengan HTML viewer bawaan

### 2. Manajemen Proyek
- Collection
  - Buat, edit, hapus collection
  - Simpan request ke collection
  - Organisasi request dalam folder collection
- Import/Export
  - Import collection kompatibel Postman Collection v2.1
  - Export collection ke Postman Collection v2.1
- Environment dan variabel
  - Buat environment dengan daftar variabel
  - Pilih environment saat menjalankan request
  - Variabel global dan environment
  - Resolusi variabel dalam URL, header, dan body

### 3. UI/UX dan Pengalaman Pengguna
- Mobile responsive dengan layout yang adaptif
- Tampilan clean dan ringkas
- Dark mode dan dukungan tema Material 3
- Navigasi intuitif antara request, collection, dan environment

## Teknologi
- Flutter
- Android dan iOS
- Dio sebagai HTTP client
- Material 3 untuk desain UI

## Fase Implementasi

### Fase 1: Skeleton Project Folder + Files Utama
- Struktur folder proyek Flutter
- Utama: `lib/main.dart`, `lib/screens`, `lib/models`, `lib/services`, `lib/widgets`
- Setup Material 3 dan theming
- Integrasi dasar Dio
- Routing dan navigasi sederhana

Deliverable:
- Template aplikasi Flutter dengan scaffold halaman utama
- Tema light/dark
- Struktur file dasar untuk request, collection, environment

### Fase 2: Manajemen API Client
- Implementasi request builder lengkap
- Implementasi response viewer dengan support status, headers, body
- Integrasi content type handling
- Authentication support

Deliverable:
- Halaman request API yang bisa melakukan HTTP calls
- Response viewer dengan plain text, JSON viewer, HTML viewer

### Fase 3: Manajemen Proyek
- Implementasi collection CRUD
- Import/export Postman Collection v2.1
- Environment dan variabel CRUD
- Penyimpanan lokal (misalnya SQLite, Hive, atau shared preferences)

Deliverable:
- Fitur collection dan environment penuh
- Data tersimpan dan bisa diimpor/ekspor kompatibel Postman

## Non-functional Requirements
- Performa responsif di perangkat mobile
- Pengalaman pengguna sederhana dan mudah dibaca
- Dukungan offline untuk koleksi dan environment yang disimpan
- Keamanan dasar untuk penyimpanan data lokal

## Prioritas
1. Skeleton project dan UI dasar
2. Request builder + response viewer
3. Collection management + import/export
4. Environment dan variabel
5. Dark mode dan tema Material 3 yang konsisten

## Catatan Tambahan
- Pastikan penggunaan plugin Flutter yang stabil untuk JSON viewer dan HTML viewer.
- Evaluasi package import/export Postman Collection yang tersedia.
- Pertimbangkan sinkronisasi data di masa depan, tetapi fokus pada fungsi offline awal.

# Simple E-Learning Platform (Flutter, Student App)

Aplikasi Flutter untuk Student: melihat daftar course, membuka detail course, memilih lesson, dan menonton video lesson.
Dibuat sebagai Technical Assessment Flutter Developer (Track B).

## Fitur

- **Course list**: judul, instruktur, ringkasan, level, jumlah lesson, total durasi.
- **Course detail**: deskripsi course dan daftar lesson berurutan.
- **Lesson selection**: tap lesson untuk membuka player.
- **Video player**: play, pause, seek (slider), indikator buffering, replay saat selesai.
- **Navigasi**: kembali ke daftar course, atau pindah lesson langsung dari halaman player.
- **Penanganan kondisi**: loading, empty, error, dan koneksi gagal (dengan tombol "Coba lagi").
- **Pengelolaan player**: controller di-dispose saat halaman ditutup atau lesson diganti, dan video di-pause saat aplikasi masuk background.

## Requirement

- Flutter SDK 3.38.x (channel stable) dan Dart yang menyertainya
- Android Studio atau VS Code dengan plugin Flutter dan Dart
- Koneksi internet (data dan video diambil dari jaringan)
- Untuk Android: Android SDK. Untuk web: Google Chrome

## Instalasi dan Menjalankan

```bash
git clone https://github.com/zaidanrazzak190804-blip/elearning-app.git
cd elearning-app
flutter pub get
flutter run -d chrome        # atau pilih emulator/perangkat Android
```

Build APK Android:

```bash
flutter build apk
# hasil: build/app/outputs/flutter-apk/app-release.apk
```

Izin `INTERNET` sudah ditambahkan di `android/app/src/main/AndroidManifest.xml` agar APK rilis dapat mengakses jaringan.

Menjalankan tes dan analisis kode:

```bash
flutter analyze
flutter test
```

Tidak ada akun demo karena aplikasi tidak memiliki login.

## Konfigurasi

Satu-satunya konfigurasi adalah base URL API di `lib/core/network/dio_client.dart`:

```dart
const String kBaseUrl =
    'https://zaidanrazzak190804-blip.github.io/elearning-mock-api';
```

## Mock API

Data dilayani sebagai file JSON statis lewat GitHub Pages dari repo terpisah:
[elearning-mock-api](https://github.com/zaidanrazzak190804-blip/elearning-mock-api).

| Endpoint | Isi |
|---|---|
| `GET /courses.json` | Daftar course ringkas |
| `GET /courses/{id}.json` | Detail course beserta daftar lesson |

Bentuk respons lengkap ada di [docs/design.md](docs/design.md).

### Mengganti mock dengan API sebenarnya

1. Ubah `kBaseUrl` ke alamat backend asli.
2. Jika path berbeda (misalnya `/courses` tanpa `.json`), sesuaikan dua path di `lib/features/courses/data/course_repository.dart`.
3. Selama respons tetap berbentuk `{ "data": ... }` dengan field yang sama, tidak ada kode lain yang perlu diubah. Jika bentuknya berbeda, cukup ubah `fromJson` di `course_models.dart`.

UI dan state tidak mengetahui Dio atau URL sama sekali, karena semuanya lewat `CourseRepository`.

## Arsitektur

Feature-based sederhana dengan tiga lapisan di tiap fitur:

```
lib/
├── core/
│   ├── network/     dio_client.dart, api_error.dart
│   ├── router/      app_router.dart
│   └── theme/       app_theme.dart
├── features/
│   ├── courses/
│   │   ├── data/            model dan repository
│   │   ├── providers/       provider Riverpod
│   │   └── presentation/    halaman list, detail, widget state
│   └── player/
│       └── presentation/    halaman player dan widget video
└── main.dart
```

- **data**: mengambil dan memetakan data. Hanya lapisan ini yang tahu soal HTTP.
- **providers**: state async (loading, error, data) dengan Riverpod.
- **presentation**: hanya menampilkan UI dari state.

Diagram dan alur lengkap ada di [docs/design.md](docs/design.md).

## Pilihan Package dan Alasannya

| Package | Alasan |
|---|---|
| `flutter_riverpod` | Diutamakan oleh brief. `FutureProvider` dan `AsyncValue.when` memaksa loading, error, dan data selalu ditangani. Mudah dites dan tanpa `BuildContext` untuk akses state. |
| `go_router` | Package routing resmi dari tim Flutter. Mendukung path parameter (`/course/:courseId/lesson/:lessonId`) dan deep link. |
| `dio` | Timeout, jenis error (`DioException`) yang jelas, dan mudah dikembangkan dengan interceptor. Lebih lengkap dari `http` untuk kebutuhan penanganan koneksi gagal. |
| `video_player` | Package resmi Flutter, stabil, mendukung Android, iOS, dan web. Antarmuka kontrol dibuat sendiri agar konsisten dengan tema aplikasi dan dapat dijelaskan baris per baris. |

## Keputusan Teknis Penting

- **Lifecycle player**: `VideoPlayerController` dibuat di `initState` dan di-dispose di `dispose`. Widget player diberi `ValueKey(lesson.id)`, sehingga saat lesson diganti, controller lama dibuang dan yang baru dibuat. Pengecekan `mounted` dilakukan setelah setiap `await`.
- **Seek**: `seekTo` dipanggil di `onChangeEnd` slider, bukan di setiap geseran, agar player tidak terbebani.
- **Pause di background**: lewat `WidgetsBindingObserver`.
- **`retry` dimatikan** pada provider: Riverpod 3 mengulang provider yang gagal secara otomatis, sehingga state error baru muncul setelah beberapa percobaan. Dimatikan agar error tampil langsung dan pengguna mengulang lewat tombol "Coba lagi".
- **Pesan error ramah** lewat `friendlyError`, memisahkan pesan untuk pengguna dari detail teknis.

## Asumsi

- Video bersifat **placeholder**: URL `.mp4` publik yang aman, isinya tidak sesuai judul lesson, dan sebagian dipakai ulang antar lesson. Pada sistem nyata setiap lesson memiliki `videoUrl` sendiri (CDN atau layanan streaming). Aplikasi hanya bergantung pada URL, bukan isi video.
- Teks dummy (judul course, deskripsi, instruktur) dibuat bermakna dan realistis.
- Gambar thumbnail memakai layanan placeholder publik (picsum.photos).
- Video diputar secara streaming dari URL (`VideoPlayerController.networkUrl`), bukan alur download lalu putar.

## Keterbatasan

- Tidak ada login, akun, maupun progres belajar.
- Tidak ada cache atau mode offline: tanpa internet, data dan video tidak tersedia.
- Tidak ada mode layar penuh dan pengaturan kecepatan putar.
- Data berasal dari JSON statis, sehingga tidak ada pencarian, filter, maupun paginasi.
- Pengujian utama dilakukan di Chrome (web). **[ISI: status pengujian Android, misalnya "APK telah dibuild dan dicoba di perangkat Android" atau "belum diuji di perangkat Android"]**. Perilaku video di web dan mobile dapat berbeda.
- Tes otomatis baru berupa tes dasar (aplikasi dapat dibangun dan judul halaman tampil).

## Pengembangan Lanjutan

Backend asli dengan database, autentikasi, penyimpanan progres per lesson, cache offline, dan kontrol player yang lebih lengkap (layar penuh, kecepatan putar, resume posisi terakhir).

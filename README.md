# Math Worm - Game Cacing Edukasi Matematika 🐛➕➖✖️➗

[![Language](https://img.shields.io/badge/Language-Free%20Pascal-blue.svg)](https://www.freepascal.org/)
[![Library](https://img.shields.io/badge/Library-SDL2-orange.svg)](https://www.libsdl.org/)
[![Architecture](https://img.shields.io/badge/Architecture-Modular%20MVC-success.svg)](#-2-struktur-proyek--arsitektur-modular)
[![Platform](https://img.shields.io/badge/Platform-Windows%20(32--bit%20%2F%2064--bit)-lightgrey.svg)](#-5-cara-kompilasi-dan-menjalankan)

> **Tugas Akhir Mata Kuliah Pemrograman Dasar**  
> Repositori GitHub: [https://github.com/Justdhif/math_worm](https://github.com/Justdhif/math_worm)

---

## 📌 1. Deskripsi Permainan

**Math Worm** adalah adaptasi game cacing klasik (*snake game*) yang dikombinasikan dengan sarana edukasi matematika interaktif. Di dalam permainan ini, cacing tidak hanya memakan objek sembarangan, melainkan harus memakan angka yang merupakan **jawaban tepat** dari soal matematika yang ditampilkan di layar bagian atas.

### 🎯 Aturan Permainan:
* **Soal Matematika**: Ditampilkan di header atas dengan 4 macam operasi aritmatika (Penjumlahan `+`, Pengurangan `-`, Perkalian `X`, Pembagian `:`).
* **Makanan Berserakan**: Terdapat **3 hingga 4 pilihan jawaban** makanan berbentuk kotak angka di dalam arena. Salah satunya adalah **jawaban benar**, sedangkan sisanya adalah **jawaban pengecoh unik** yang mendekati nilai asli.
* **Memakan Jawaban BENAR**:
  * Skor bertambah **+10**.
  * Badan cacing bertambah panjang **+1 ruas**.
  * Muncul notifikasi hijau `BENAR! +10 SKOR` dan soal baru akan langsung diacak kembali.
* **Memakan Jawaban SALAH**:
  * Nyawa cacing berkurang **1** (dari modal awal 3 nyawa).
  * Muncul peringatan merah `SALAH! -1 NYAWA` dan soal diacak ulang.
* **Layar Menu Utama (Start Menu)**:
  * Menampilkan judul game retro, penjelasan cara bermain, panduan kontrol tombol, dan tombol mulai.
* **Sistem Pause (Jeda Permainan)**:
  * Tekan tombol **P** atau **ESC** saat bermain untuk menjeda waktu dan pergerakan ular.
  * Tampil kartu pop-up jeda dengan opsi melanjutkan atau kembali ke menu utama.
* **Kondisi Kalah (Game Over)**:
  1. **Nyawa Habis (0)**: Pemain salah menjawab soal sebanyak 3 kali.
  2. **Menabrak Badan Sendiri (*Self-Collision*)**: Kepala cacing berbelok dan menabrak salah satu bagian ruas badannya sendiri.
* **Layar Game Over**:
  * Muncul pop-up dialog yang menampilkan alasan kalah secara dinamis, skor akhir, dan panjang cacing yang diraih, serta tombol interaksi untuk mengulang permainan atau kembali ke menu utama.

---

## 📂 2. Struktur Proyek & Arsitektur Modular

Kode program dibangun menggunakan pola perancangan **Modular MVC (Model-View-Controller)** agar rapi, terstruktur, dan tidak menumpuk dalam satu file panjang:

```text
math_worm/
├── MathWorm.pas          # Controller  : Program utama, SDL2 loop, event input
├── UTypes.pas            # Data/Struct : Tipe data record (TWorm, TGame, TPoint) & konstanta
├── UMathEngine.pas       # Model (Math): Generator 4 operasi hitung & pilihan angka unik
├── UGameLogic.pas        # Model (Game): Logika ular, wrap-around dinding, tabrakan, skor/nyawa
├── UGameRenderer.pas     # View (Render): Penggambaran header, arena, grid, ular, & Game Over
├── UFont.pas             # View (Font)  : Font piksel 3x5 mandiri & ikon hati nyawa
│
├── .gitignore            # Konfigurasi file yang diabaikan oleh Git (*.exe, *.o, *.ppu)
├── SDL2.dll              # Dynamic Link Library SDL2 untuk Windows
├── lib/                  # Binding Unit SDL2 untuk Free Pascal (SDL2-for-Pascal)
│   └── SDL2-for-Pascal-master/
└── README.md             # Dokumentasi Lengkap Proyek
```

### Rincian Modul Program:

| Nama File | Peran | Baris Kode | Deskripsi Singkat |
| :--- | :---: | :---: | :--- |
| **`MathWorm.pas`** | **Controller** | ~100 | Mengatur siklus hidup game: inisialisasi SDL2, jendela (*window*), *renderer*, *event loop* pembaca input keyboard, serta koordinasi *update* dan *render*. |
| **`UTypes.pas`** | **Data / Types** | ~55 | Menyimpan konstanta permainan (`CELL_SIZE`, `MAX_LIVES`, dsb.), struktur record (`TPoint`, `TWorm`, `TFoodState`, `TFeedback`), dan fungsi utilitas `NumberToString`. |
| **`UMathEngine.pas`** | **Model (Math)** | ~95 | Menghasilkan soal matematika secara acak untuk 4 operasi aritmatika dengan hasil bilangan bulat positif $\le 99$, serta menyusun pilihan angka jawaban yang unik. |
| **`UGameLogic.pas`** | **Model (Logic)** | ~240 | Mengelola dunia game: penempatan koordinat makanan acak, validasi arah gerakan cacing, mekanisme tembus dinding (*wrap-around*), deteksi tabrak badan sendiri, dan pembaruan skor/nyawa. |
| **`UGameRenderer.pas`** | **View** | ~310 | Menggambar semua elemen visual: latar belakang, garis grid arena, kotak makanan berwarna emas, ruas badan cacing, animasi arah mata cacing, hingga pop-up Game Over. |
| **`UFont.pas`** | **View (Font)** | ~160 | Menggambar huruf (A–Z), angka (0–9), simbol, dan ikon hati nyawa menggunakan matriks piksel retro 3x5 mandiri tanpa ketergantungan library font eksternal. |

---

## 🎮 3. Kontrol Permainan

Permainan mendukung tombol panah maupun tombol standar gamer (WASD):

| Tombol Keyboard | Aksi |
| :--- | :--- |
| **W** atau **Panah Atas ($\uparrow$)** | Belok ke Atas |
| **S** atau **Panah Bawah ($\downarrow$)** | Belok ke Bawah |
| **A** atau **Panah Kiri ($\leftarrow$)** | Belok ke Kiri |
| **D** atau **Panah Kanan ($\rightarrow$)** | Belok ke Kanan |
| **P** | Jeda / Lanjutkan Permainan (*Pause / Resume*) |
| **SPASI** atau **ENTER** | Mulai Main dari Menu / Mulai Ulang saat Game Over / Lanjut dari Pause |
| **M** | Kembali ke Menu Utama (dari layar Pause atau Game Over) |
| **ESC** | Jeda Permainan / Kembali ke Menu / Keluar dari Game |

---

## 🛠️ 4. Tutorial Implementasi SDL2 pada Pascal

**SDL2 (Simple DirectMedia Layer 2)** adalah pustaka C tingkat rendah yang menyediakan akses langsung ke perangkat keras grafis 2D (*GPU*), audio, serta input keyboard/mouse. 

Proyek ini memanfaatkan binding resmi **SDL2-for-Pascal** (`lib/SDL2-for-Pascal-master/units`) dan library biner **`SDL2.dll`**.

Berikut adalah tahapan inti arsitektur implementasi SDL2 pada game ini:

### A. Memuat Unit SDL2
Cukup sertakan unit `SDL2` pada klausa `uses`:
```pascal
program MathWorm;
uses
  SDL2, ...;
```
Compiler Free Pascal (`fpc`) diarahkan untuk membaca folder unit SDL2 melalui opsi `-Fu"lib/SDL2-for-Pascal-master/units"`.

---

### B. Inisialisasi Subsistem Video
Sebelum fungsi grafis digunakan, SDL2 harus diinisialisasi terlebih dahulu:
```pascal
if SDL_Init(SDL_INIT_VIDEO) < 0 then
begin
  WriteLn('Error: Gagal menginisialisasi subsistem video SDL2.');
  Halt(1);
end;
```
* `SDL_INIT_VIDEO` menginisialisasi driver grafis, window manager, dan event loop.

---

### C. Membuat Jendela Aplikasi (*Window*)
Jendela permainan dibuat menggunakan fungsi `SDL_CreateWindow`:
```pascal
window := SDL_CreateWindow(
  'Math Worm - Game Cacing Edukasi Matematika',
  SDL_WINDOWPOS_CENTERED,  { Posisi horizontal di tengah layar monitor }
  SDL_WINDOWPOS_CENTERED,  { Posisi vertikal di tengah layar monitor }
  800,                     { Lebar jendela: 800 piksel }
  600,                     { Tinggi jendela: 600 piksel }
  SDL_WINDOW_SHOWN         { Jendela langsung ditampilkan }
);
```

---

### D. Membuat Mesin Gambar (*Renderer Hardware-Accelerated*)
Renderer bertugas mengeksekusi perintah menggambar ke jendela menggunakan akselerasi GPU:
```pascal
renderer := SDL_CreateRenderer(
  window,
  -1,                       { Memilih driver grafis pertama yang cocok }
  SDL_RENDERER_ACCELERATED  { Menggunakan akselerasi GPU agar animasi mulus }
);
```

---

### E. Pola Siklus Game (*Game Loop*)
Game loop adalah perulangan yang berjalan terus-menerus selama variabel `running = True`:
```pascal
while running do
begin
  { 1. Tangani Event Input Keyboard & Jendela }
  while SDL_PollEvent(@event) = 1 do
  begin
    if event.type_ = Cardinal(SDL_QUITEV) then
      running := False;

    if event.type_ = SDL_KEYDOWN then
    begin
      case event.key.keysym.sym of
        SDLK_ESCAPE: running := False;
        SDLK_UP, SDLK_w: ChangeDirection(game, 0, -CELL_SIZE);
        { ... tombol lainnya ... }
      end;
    end;
  end;

  { 2. Update Logika Permainan berbasis Waktu Riil (Tick Rate: 150 ms) }
  currentTime := SDL_GetTicks;
  if (game.state = STATE_PLAYING) and (currentTime - lastMove >= 150) then
  begin
    lastMove := currentTime;
    UpdateGameStep(game); { Jalankan pergerakan ular dan deteksi tabrakan }
  end;

  { 3. Render Grafis ke Layar }
  RenderGame(renderer, game);

  { Jeda 1 milidetik agar CPU tidak bekerja 100% saat idle }
  SDL_Delay(1);
end;
```

---

### F. Teknik Menggambar Primitif (*Double Buffering*)
Setiap frame digambar melalui tahapan buffer belakang (*backbuffer*):
1. **Bersihkan Layar**:
   ```pascal
   SDL_SetRenderDrawColor(renderer, 15, 20, 30, 255); { Background RGBA }
   SDL_RenderClear(renderer);
   ```
2. **Gambar Objek (Segi Empat / Rect)**:
   ```pascal
   rect.x := 100; rect.y := 100; rect.w := 24; rect.h := 24;
   SDL_SetRenderDrawColor(renderer, 46, 204, 113, 255); { Warna hijau }
   SDL_RenderFillRect(renderer, @rect); { Kotak terisi warna padat }
   ```
3. **Tampilkan ke Monitor**:
   ```pascal
   SDL_RenderPresent(renderer); { Menukar backbuffer ke layar monitor }
   ```

---

### G. Pembersihan Memori (*Clean Up*)
Ketika game ditutup, seluruh alokasi memori grafis dibebaskan kembali ke sistem operasi:
```pascal
SDL_DestroyRenderer(renderer);
SDL_DestroyWindow(window);
SDL_Quit;
```

---

## ⚙️ 5. Cara Kompilasi dan Menjalankan

### Persyaratan Sistem:
* **Sistem Operasi**: Windows 7 / 8 / 10 / 11
* **Compiler**: Free Pascal Compiler (`fpc`) versi 3.0+
* **File Pendukung**: `SDL2.dll` (sudah disediakan di repositori)

### Langkah Kloning & Kompilasi:

```powershell
# 1. Clone repositori dari GitHub
git clone https://github.com/Justdhif/math_worm.git
cd math_worm

# 2. Kompilasi program menggunakan Free Pascal
fpc -Fu"lib/SDL2-for-Pascal-master/units" MathWorm.pas

# 3. Jalankan game
.\MathWorm.exe
```

> **Catatan**: Parameter `-Fu"lib/SDL2-for-Pascal-master/units"` berfungsi agar compiler `fpc` dapat menemukan seluruh unit pustaka SDL2 yang disimpan di dalam folder `lib/`.

---

## 👨‍💻 Pengembang
* **Proyek**: Tugas Akhir Pemrograman Dasar
* **Topik**: Game Edukasi Interaktif Berbasis Algoritma & Grafis 2D SDL2
* **Tahun**: 2026

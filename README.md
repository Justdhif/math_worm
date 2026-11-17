# Math Worm - Game Cacing Edukasi Matematika 🐛➕➖✖️➗

[![Language](https://img.shields.io/badge/Language-Free%20Pascal-blue.svg)](https://www.freepascal.org/)
[![Library](https://img.shields.io/badge/Library-SDL3-red.svg)](https://www.libsdl.org/)
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
├── MathWorm.pas          # Controller  : Program utama, SDL3 loop, event input, window setup
├── UTypes.pas            # Data/Struct : Tipe data record (TWorm, TGame, TPoint) & konstanta
├── UAudio.pas            # Audio/Sound : Generator musik latar (BGM chiptune) & efek suara (SFX)
├── UMathEngine.pas       # Model (Math): Generator 4 operasi hitung & pilihan angka unik
├── UGameLogic.pas        # Model (Game): Logika ular, wrap-around dinding, tabrakan, skor/nyawa
├── UGameRenderer.pas     # View (Render): Penggambaran header, arena, grid, ular, & Game Over
├── UFont.pas             # View (Font)  : Font piksel 3x5 mandiri & ikon hati nyawa
│
├── .gitignore            # Konfigurasi file yang diabaikan oleh Git (*.exe, *.o, *.ppu)
├── SDL3.dll              # Dynamic Link Library SDL3 untuk Windows
├── lib/                  # Binding Unit SDL3 untuk Free Pascal (SDL3-for-Pascal)
│   └── SDL3-for-Pascal/
└── README.md             # Dokumentasi Lengkap Proyek
```

### Rincian Modul Program:

| Nama File | Peran | Baris Kode | Deskripsi Singkat |
| :--- | :---: | :---: | :--- |
| **`MathWorm.pas`** | **Controller** | ~160 | Mengatur siklus hidup game: inisialisasi SDL3, jendela aplikasi (*window* resizable 1024x768), presentasi resolusi logika, *event loop*, serta pemanggilan audio dan render. |
| **`UTypes.pas`** | **Data / Types** | ~70 | Menyimpan konstanta permainan (`LOGICAL_WIDTH/HEIGHT`, `WINDOW_WIDTH/HEIGHT`, `CELL_SIZE`, dsb.), struktur record (`TPoint`, `TWorm`, `TFoodState`, `TFeedback`), dan fungsi `NumberToString`. |
| **`UAudio.pas`** | **Audio / Synth** | ~360 | Mensintesis suara retro chiptune 8-bit secara mandiri: melodi musik latar (BGM 2 channel lead+bass) dan efek suara SFX (makan benar, salah, pause, game over, start) menggunakan `SDL_AudioStream`. |
| **`UMathEngine.pas`** | **Model (Math)** | ~95 | Menghasilkan soal matematika secara acak untuk 4 operasi aritmatika dengan hasil bilangan bulat positif $\le 99$, serta menyusun pilihan angka jawaban yang unik. |
| **`UGameLogic.pas`** | **Model (Logic)** | ~280 | Mengelola dunia game: penempatan koordinat makanan acak, validasi arah gerakan cacing, mekanisme tembus dinding (*wrap-around*), deteksi tabrak badan sendiri, dan pembaruan skor/nyawa serta pemicu SFX. |
| **`UGameRenderer.pas`** | **View** | ~490 | Menggambar semua elemen visual: layar menu utama, header, garis grid arena, kotak makanan berwarna emas, ruas badan cacing, animasi arah mata cacing, dialog Pause, hingga pop-up Game Over. |
| **`UFont.pas`** | **View (Font)** | ~180 | Menggambar huruf (A–Z), angka (0–9), simbol, dan ikon hati nyawa menggunakan matriks piksel retro 3x5 mandiri tanpa ketergantungan library font eksternal. |

---

## 🎮 3. Kontrol Permainan

Permainan mendukung tombol panah maupun tombol standar gamer (WASD):

| Tombol Keyboard | Aksi |
| :--- | :--- |
| **W** atau **Panah Atas ($\uparrow$)** | Belok ke Atas |
| **S** atau **Panah Bawah ($\downarrow$)** | Belok ke Bawah |
| **A** atau **Panah Kiri ($\leftarrow$)** | Belok ke Kiri |
| **D** atau **Panah Kanan ($\rightarrow$)** | Belok ke Kanan |
| **B** | Menyalakan / Mematikan Musik Latar (*BGM On/Off*) |
| **P** | Jeda / Lanjutkan Permainan (*Pause / Resume*) |
| **ENTER** | Mulai Main dari Menu / Mulai Ulang saat Game Over / Lanjut dari Pause |
| **M** | Kembali ke Menu Utama (dari layar Pause atau Game Over) |
| **ESC** | Jeda Permainan / Kembali ke Menu / Keluar dari Game |

---

## 🛠️ 4. Tutorial Implementasi SDL3 pada Pascal

**SDL3 (Simple DirectMedia Layer 3)** adalah versi generasi terbaru dari pustaka SDL yang dirancang lebih modern, efisien, dengan dukungan floating-point rendering (`TSDL_FRect`), API yang disederhanakan, dan performa tinggi.

Proyek ini memanfaatkan binding resmi **SDL3-for-Pascal** (`lib/SDL3-for-Pascal/units`) dan library biner **`SDL3.dll`**.

Berikut adalah tahapan inti arsitektur implementasi SDL3 pada game ini:

### A. Memuat Unit SDL3
Cukup sertakan unit `SDL3` pada klausa `uses`:
```pascal
program MathWorm;
uses
  SDL3, ...;
```
Compiler Free Pascal (`fpc`) diarahkan untuk membaca folder unit SDL3 melalui opsi `-Fu"lib/SDL3-for-Pascal/units"`.

---

### B. Inisialisasi Subsistem Video & Audio
Pada SDL3, `SDL_Init` mengembalikan nilai bertipe `Boolean` (`True` jika berhasil). Kita dapat menginisialisasi subsistem video dan audio sekaligus:
```pascal
if not SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO) then
begin
  WriteLn('Error: Gagal menginisialisasi subsistem video/audio SDL3.');
  Halt(1);
end;
```

---

### C. Membuat Jendela Aplikasi (*Window Resizable*) & Presentasi Logika
Pada SDL3, `SDL_CreateWindow` disederhanakan menjadi 4 parameter. Jendela dibuat dengan ukuran lebih lega (**1024x768**) dan flag `SDL_WINDOW_RESIZABLE` agar pemain dapat mengubah ukuran jendela maupun memaksimalkan layar (*maximize*).

Agar seluruh koordinat gambar permainan (800x600) tetap konsisten dan tidak terdistorsi di berbagai resolusi layar, digunakan fitur bawaan SDL3 `SDL_SetRenderLogicalPresentation`:
```pascal
// 1. Buat jendela 1024x768 yang dapat di-resize
window := SDL_CreateWindow(
  'Math Worm - Game Cacing Edukasi Matematika',
  1024,
  768,
  SDL_WINDOW_RESIZABLE
);

// 2. Tempatkan jendela di tengah layar
SDL_SetWindowPosition(window, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);

// 3. Buat renderer hardware-accelerated
renderer := SDL_CreateRenderer(window, nil);

// 4. Kunci rasio resolusi logika ke 800x600 dengan letterboxing otomatis yang tajam
SDL_SetRenderLogicalPresentation(renderer, 800, 600, SDL_LOGICAL_PRESENTATION_LETTERBOX);
```

---

### D. Sistem Audio & Sintesis Suara Mandiri (*SDL_AudioStream*)
SDL3 menghadirkan arsitektur audio modern berbasis `SDL_AudioStream`. Game ini mensintesis gelombang suara chiptune 8-bit secara matematis (*algorithmic sound synthesis*) tanpa file WAV/MP3 eksternal:
```pascal
var
  spec: TSDL_AudioSpec;
  stream: PSDL_AudioStream;
begin
  spec.format := SDL_AUDIO_S16LE;
  spec.channels := 1;
  spec.freq := 44100;

  // Buka stream audio ke perangkat pemutar standar
  stream := SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, @spec, nil, nil);
  SDL_ResumeAudioStreamDevice(stream);

  // Alirkan buffer suara yang disintesis
  SDL_PutAudioStreamData(stream, @buffer[0], bufferSize);
end;
```

---

### E. Pola Siklus Game (*Game Loop*)
Game loop memproses event, update pergerakan berbasis waktu (`SDL_GetTicks` 64-bit), dan render:
```pascal
while running do
begin
  { 1. Tangani Event Input (SDL_PollEvent mengembalikan Boolean pada SDL3) }
  while SDL_PollEvent(@event) do
  begin
    if event.type_ = SDL_EVENT_QUIT then
      running := False;

    if event.type_ = SDL_EVENT_KEY_DOWN then
    begin
      case event.key.key of
        SDLK_ESCAPE: TogglePause(game);
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
    UpdateGameStep(game);
  end;

  { 3. Render Grafis ke Layar }
  RenderGame(renderer, game);

  SDL_Delay(1);
end;
```

---

### F. Teknik Menggambar Primitif (*Subpixel Float Precision*)
SDL3 menggunakan struktur koordinat floating point `TSDL_FRect` untuk rendering yang presisi:
1. **Bersihkan Layar**:
   ```pascal
   SDL_SetRenderDrawColor(renderer, 15, 20, 30, 255);
   SDL_RenderClear(renderer);
   ```
2. **Gambar Objek (Segi Empat / FRect)**:
   ```pascal
   rect.x := 100; rect.y := 100; rect.w := 24; rect.h := 24;
   SDL_SetRenderDrawColor(renderer, 46, 204, 113, 255);
   SDL_RenderFillRect(renderer, @rect); { Kotak padat }
   SDL_RenderRect(renderer, @rect);     { Garis tepi kotak }
   ```
3. **Tampilkan ke Monitor**:
   ```pascal
   SDL_RenderPresent(renderer);
   ```

---

### G. Pembersihan Memori (*Clean Up*)
Ketika game ditutup, seluruh alokasi memori dilepaskan kembali ke sistem operasi:
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
* **File Pendukung**: `SDL3.dll` (sudah disediakan di repositori)

### Langkah Kloning & Kompilasi:

```powershell
# 1. Clone repositori dari GitHub
git clone https://github.com/Justdhif/math_worm.git
cd math_worm

# 2. Kompilasi program menggunakan Free Pascal & unit SDL3
fpc -Fu"lib/SDL3-for-Pascal/units" MathWorm.pas

# 3. Jalankan game
.\MathWorm.exe
```

---

## 👨‍💻 Pengembang
* **Proyek**: Tugas Akhir Pemrograman Dasar
* **Topik**: Game Edukasi Interaktif Berbasis Algoritma & Grafis 2D SDL3
* **Tahun**: 2026

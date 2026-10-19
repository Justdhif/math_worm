# Math Worm - Game Cacing Edukasi Matematika 🐛➕➖✖️➗

> **Tugas Akhir Mata Kuliah Pemrograman Dasar**  
> Bahasa Pemrograman: **Free Pascal**  
> Pustaka Grafis & Input: **SDL2 (Simple DirectMedia Layer 2)**  
> Pola Perancangan: **Modular Architecture (MVC - Model, View, Controller)**

---

## 📌 1. Deskripsi Permainan

**Math Worm** adalah adaptasi edukatif dari game klasik cacing (*snake game*). Di dalam permainan ini, cacing tidak hanya mencari makanan sembarangan, melainkan harus menyelesaikan soal matematika yang ditampilkan di layar bagian atas (*Header*).

* Di dalam arena, terdapat **3 hingga 4 makanan** berbentuk kotak angka yang berserakan.
* Salah satu makanan bernilai **jawaban yang benar**, sedangkan sisanya merupakan **jawaban pengecoh (distractor)** yang dibuat secara acak namun mendekati jawaban asli.
* **Jika memakan jawaban BENAR**:
  * Skor bertambah **+10**.
  * Badan cacing bertambah panjang **+1 ruas**.
  * Muncul notifikasi hijau `BENAR! +10 SKOR` dan soal baru akan diacak kembali.
* **Jika memakan jawaban SALAH**:
  * Nyawa cacing berkurang **1** (dari total 3 nyawa).
  * Muncul peringatan merah `SALAH! -1 NYAWA` dan soal diacak ulang.
* **Kondisi Kalah (Game Over)**:
  1. **Nyawa Habis (0)**: Pemain salah menjawab soal 3 kali berturut-turut.
  2. **Menabrak Badan Sendiri (Self-Collision)**: Kepala cacing berbelok dan menabrak salah satu ruas badannya sendiri.
* **Layar Game Over**:
  * Tampil kartu pop-up modal interaktif yang menampilkan alasan kalah, skor akhir, dan panjang cacing yang berhasil dicapai, serta instruksi untuk mengulang permainan (*Press Space to Restart*).

---

## 📂 2. Struktur Proyek & Penjelasan File

Kode program dipecah secara modular menjadi beberapa unit mandiri agar tidak menumpuk dalam satu file panjang:

```text
math-worm/
├── MathWorm.pas          # Program Utama (Controller / Entry Point)
├── UTypes.pas            # Modul Konstanta & Struktur Data (Record)
├── UMathEngine.pas       # Modul Logika Generator Soal & Jawaban
├── UGameLogic.pas        # Modul Mekanika & Aturan Permainan (Model)
├── UGameRenderer.pas     # Modul Penggambaran Grafis & UI (View)
├── UFont.pas             # Modul Sistem Font Piksel & Ikon Retro
│
├── SDL2.dll              # Dynamic Link Library SDL2 untuk Windows
├── lib/                  # Binding Unit SDL2 untuk Free Pascal
│   └── SDL2-for-Pascal-master/
├── MathWorm.exe          # File Executable Hasil Kompilasi
└── README.md             # Dokumentasi Lengkap Proyek
```

### Rincian Modul `.pas`:

| Nama File | Peran | Deskripsi Singkat |
| :--- | :---: | :--- |
| **`MathWorm.pas`** | **Controller** | Mengatur siklus hidup game: inisialisasi SDL2, jendela (*window*), *renderer*, *event loop* pembaca tombol keyboard, serta koordinasi *update* dan *render*. |
| **`UTypes.pas`** | **Data / Types** | Menyimpan konstanta permainan (`CELL_SIZE`, `MAX_LIVES`, dsb.), struktur record (`TPoint`, `TWorm`, `TFoodState`, `TFeedback`), dan fungsi konversi `NumberToString`. |
| **`UMathEngine.pas`** | **Model (Math)** | Menghasilkan soal matematika secara acak untuk 4 operasi hitung (`+`, `-`, `X`, `:`) dengan hasil bilangan bulat positif $\le 99$, serta menyusun pilihan angka jawaban yang unik. |
| **`UGameLogic.pas`** | **Model (Logic)** | Mengelola dunia game: penempatan koordinat makanan acak, validasi arah gerakan cacing, mekanisme tembus dinding (*wrap-around*), deteksi tabrak badan sendiri, dan pembaruan skor/nyawa. |
| **`UGameRenderer.pas`** | **View** | Menggambar semua elemen grafis: latar belakang, garis grid arena, kotak makanan berwarna emas, ruas badan cacing, animasi arah mata cacing, hingga pop-up Game Over. |
| **`UFont.pas`** | **View (Font)** | Menggambar huruf (A–Z), angka (0–9), simbol, dan ikon hati nyawa menggunakan matriks piksel retro 3x5 mandiri tanpa ketergantungan library font eksternal. |

---

## 🎮 3. Kontrol Permainan

| Tombol Keyboard | Aksi |
| :--- | :--- |
| **W** atau **Panah Atas ($\uparrow$)** | Belok ke Atas |
| **S** atau **Panah Bawah ($\downarrow$)** | Belok ke Bawah |
| **A** atau **Panah Kiri ($\leftarrow$)** | Belok ke Kiri |
| **D** atau **Panah Kanan ($\rightarrow$)** | Belok ke Kanan |
| **SPASI** atau **ENTER** | Mulai Ulang Permainan (*Restart*) saat Game Over |
| **ESC** | Keluar dari Game kapan saja |

---

## 🛠️ 4. Tutorial Implementasi SDL2 pada Pascal

**SDL2 (Simple DirectMedia Layer 2)** adalah pustaka bahasa C tingkat rendah yang menyediakan akses langsung ke grafis 2D, akselerasi perangkat keras (*GPU*), audio, serta input keyboard/mouse.

Proyek ini memanfaatkan binding **SDL2-for-Pascal** (`lib/SDL2-for-Pascal-master/units`) dan dynamic library **`SDL2.dll`**.

Berikut adalah tahapan inti implementasi SDL2 pada game ini:

### A. Memuat Library SDL2 di Pascal
Di bagian klausa `uses`, cukup sertakan unit `SDL2`:
```pascal
program MathWorm;
uses
  SDL2, ...;
```
Saat kompilasi, compiler Free Pascal (`fpc`) diarahkan untuk membaca folder unit SDL2 menggunakan parameter `-Fu`. Saat dijalankan, program akan memanggil fungsi-fungsi grafis dari `SDL2.dll`.

---

### B. Inisialisasi Subsistem SDL2
Sebelum fungsi grafis digunakan, SDL2 harus diinisialisasi terlebih dahulu:
```pascal
if SDL_Init(SDL_INIT_VIDEO) < 0 then
begin
  WriteLn('Gagal menginisialisasi subsistem video SDL2.');
  Halt(1);
end;
```
* `SDL_INIT_VIDEO` menginisialisasi subsistem grafis dan jendela.

---

### C. Membuat Jendela Aplikasi (*Window*)
Jendela permainan dibuat menggunakan fungsi `SDL_CreateWindow`:
```pascal
window := SDL_CreateWindow(
  'Math Worm - Game Cacing Edukasi Matematika',
  SDL_WINDOWPOS_CENTERED,  { Posisi horizontal di tengah monitor }
  SDL_WINDOWPOS_CENTERED,  { Posisi vertikal di tengah monitor }
  800,                     { Lebar jendela (px) }
  600,                     { Tinggi jendela (px) }
  SDL_WINDOW_SHOWN         { Status jendela langsung tampil }
);
```

---

### D. Membuat Mesin Gambar (*Renderer*)
Renderer adalah objek yang mengeksekusi perintah gambar ke jendela menggunakan kartu grafis (GPU):
```pascal
renderer := SDL_CreateRenderer(
  window,
  -1,                       { Memilih driver display default }
  SDL_RENDERER_ACCELERATED  { Memanfaatkan akselerasi GPU agar lancar }
);
```

---

### E. Pola Siklus Game (*Game Loop*)
Game loop adalah perulangan tak hingga yang terus berjalan untuk memproses 3 hal utama:
1. **Input Handling**: Membaca tombol keyboard atau penutupan jendela.
2. **Game Update**: Menggerakkan cacing, memeriksa tabrakan, dan memperbarui skor.
3. **Render**: Menggambar ulang seluruh elemen ke layar.

```pascal
while running do
begin
  { 1. Tangani Event Input }
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

  { 2. Update Logika Permainan berdasarkan waktu (setiap 150 ms) }
  currentTime := SDL_GetTicks;
  if (game.state = STATE_PLAYING) and (currentTime - lastMove >= 150) then
  begin
    lastMove := currentTime;
    UpdateGameStep(game);
  end;

  { 3. Gambar Tampilan }
  RenderGame(renderer, game);

  { Jeda kecil agar tidak membebani penggunaan CPU }
  SDL_Delay(1);
end;
```

---

### F. Teknik Menggambar Primitif (*Double Buffering*)
Setiap frame digambar melalui tahapan:
1. **Bersihkan Layar**:
   ```pascal
   SDL_SetRenderDrawColor(renderer, 15, 20, 30, 255); { Warna background RGBA }
   SDL_RenderClear(renderer);
   ```
2. **Gambar Objek (Kotak / Segi Empat)**:
   ```pascal
   rect.x := 100; rect.y := 100; rect.w := 24; rect.h := 24;
   SDL_SetRenderDrawColor(renderer, 46, 204, 113, 255); { Warna hijau cacing }
   SDL_RenderFillRect(renderer, @rect); { Kotak padat }
   ```
3. **Tampilkan ke Layar**:
   ```pascal
   SDL_RenderPresent(renderer); { Menukar buffer belakang ke monitor }
   ```

---

### G. Pembersihan Memori (*Clean Up*)
Saat permainan selesai, semua alokasi memori grafis harus dilepaskan:
```pascal
SDL_DestroyRenderer(renderer);
SDL_DestroyWindow(window);
SDL_Quit;
```

---

## ⚙️ 5. Cara Kompilasi dan Menjalankan

### Kebutuhan Sistem:
* **Sistem Operasi**: Windows 7 / 8 / 10 / 11
* **Compiler**: Free Pascal Compiler (`fpc`) versi 3.0+
* **File Library**: `SDL2.dll` (sudah tersedia di folder proyek)

### Langkah Kompilasi:
Buka PowerShell atau Command Prompt di folder proyek ini (`d:\kullyeah\pemrograman_dasar\project_akhir\math-worm`), lalu jalankan perintah:

```powershell
fpc -Fu"lib/SDL2-for-Pascal-master/units" MathWorm.pas
```

Parameter `-Fu` memberitahukan kepada compiler lokasi unit binding SDL2 Pascal yang diperlukan.

### Langkah Menjalankan:
Setelah kompilasi sukses, jalankan file executable yang terbentuk:

```powershell
.\MathWorm.exe
```
Atau cukup **klik dua kali** pada file `MathWorm.exe` di Windows Explorer.

---

## 👨‍💻 Pengembang
* **Proyek**: Tugas Akhir Pemrograman Dasar
* **Topik**: Game Edukasi Interaktif Berbasis Algoritma & Grafis 2D SDL2

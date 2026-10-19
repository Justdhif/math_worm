{ ============================================================================
  Unit        : UTypes
  Deskripsi   : Modul penyimpan konstanta global, struktur data (record), 
                dan fungsi utilitas dasar untuk game Math Worm.
  Tugas Akhir : Pemrograman Dasar
  ============================================================================ }
unit UTypes;

interface

uses
  SDL2;

{ ----------------------------------------------------------------------------
  1. KONSTANTA GLOBAL GAME
  ---------------------------------------------------------------------------- }
const
  { Dimensi Jendela Permainan (dalam piksel) }
  WINDOW_WIDTH    = 800;
  WINDOW_HEIGHT   = 600;

  { Ukuran tiap petak/grid di arena (24x24 piksel) }
  CELL_SIZE       = 24;

  { Aturan Cacing / Ular }
  MAX_WORM_LENGTH = 500; { Batas maksimum panjang segmen badan cacing }
  START_LENGTH    = 3;   { Panjang awal cacing saat permainan dimulai }

  { Aturan Gameplay }
  MAX_FOODS       = 4;   { Batas maksimum pilihan jawaban makanan di arena }
  MAX_LIVES       = 3;   { Jumlah nyawa awal pemain }

  { Status Permainan (State Machine) }
  STATE_PLAYING   = 0;   { Sedang bermain }
  STATE_GAMEOVER  = 1;   { Kalah / Game Over }

{ ----------------------------------------------------------------------------
  2. STRUKTUR DATA (RECORD)
  ---------------------------------------------------------------------------- }
type
  { Representasi koordinat 2D (X, Y) pada grid }
  TPoint = record
    x, y: Integer;
  end;

  { Struktur data lengkap untuk Cacing / Ular }
  TWorm = record
    segments: array[0..MAX_WORM_LENGTH - 1] of TPoint; { Array posisi segmen badan (index 0 = kepala) }
    length: Integer;                                    { Panjang badan saat ini }
    dx, dy: Integer;                                    { Arah pergerakan horizontal & vertikal aktif }
    nextDX, nextDY: Integer;                            { Buffer arah berikutnya dari input pemain }
  end;

  { Struktur data kumpulan makanan / pilihan jawaban di arena }
  TFoodState = record
    pos: array[0..MAX_FOODS - 1] of TPoint;       { Koordinat masing-masing makanan }
    active: array[0..MAX_FOODS - 1] of Boolean;   { Status apakah makanan masih aktif / belum dimakan }
  end;

  { Struktur data notifikasi pesan teks (misal: "BENAR! +10 SKOR") }
  TFeedback = record
    text: String;     { Teks pesan yang ditampilkan }
    timer: Integer;   { Durasi berapa frame/tick pesan akan terlihat }
    r, g, b: Byte;    { Warna teks (RGB) }
  end;

{ ----------------------------------------------------------------------------
  3. FUNGSI UTILITAS UMUM
  ---------------------------------------------------------------------------- }
{ Mengubah integer menjadi string (karena Free Pascal dasar menggunakan Str) }
function NumberToString(n: Integer): String;

implementation

{ Implementasi fungsi konversi integer ke string }
function NumberToString(n: Integer): String;
var
  s: String;
begin
  Str(n, s);
  NumberToString := s;
end;

end.

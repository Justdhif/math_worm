unit UTypes;

interface

uses
  SDL2;

const
  // Ukuran jendela
  WINDOW_WIDTH    = 800;
  WINDOW_HEIGHT   = 600;

  // Ukuran per petak grid (24x24 piksel)
  CELL_SIZE       = 24;

  // Aturan cacing
  MAX_WORM_LENGTH = 500;
  START_LENGTH    = 3;

  // Gameplay
  MAX_FOODS       = 4;
  MAX_LIVES       = 3;

  // State permainan
  STATE_MENU      = 0;
  STATE_PLAYING   = 1;
  STATE_PAUSED    = 2;
  STATE_GAMEOVER  = 3;

type
  // Koordinat 2D pada grid
  TPoint = record
    x, y: Integer;
  end;

  // Data cacing (posisi ruas, panjang, dan arah)
  TWorm = record
    segments: array[0..MAX_WORM_LENGTH - 1] of TPoint;
    length: Integer;
    dx, dy: Integer;
    nextDX, nextDY: Integer;
  end;

  // Data posisi dan status makanan di arena
  TFoodState = record
    pos: array[0..MAX_FOODS - 1] of TPoint;
    active: array[0..MAX_FOODS - 1] of Boolean;
  end;

  // Teks umpan balik sementara (Benar/Salah)
  TFeedback = record
    text: String;
    timer: Integer;
    r, g, b: Byte;
  end;

function NumberToString(n: Integer): String;

implementation

function NumberToString(n: Integer): String;
var
  s: String;
begin
  Str(n, s);
  NumberToString := s;
end;

end.

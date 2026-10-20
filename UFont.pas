unit UFont;

interface

uses
  SDL2;

// Menggambar satu karakter font 3x5
procedure DrawChar(renderer: PSDL_Renderer; ch: Char; posX, posY, pixelSize: Integer);

// Menghitung lebar string dalam piksel
function GetTextWidth(const txt: String; pixelSize: Integer): Integer;

// Menggambar teks dari posisi kiri
procedure DrawText(renderer: PSDL_Renderer; const txt: String; posX, posY, pixelSize: Integer);

// Menggambar teks rata tengah horizontal
procedure DrawTextCentered(renderer: PSDL_Renderer; const txt: String; centerX, posY, pixelSize: Integer);

// Menggambar ikon hati nyawa
procedure DrawHeart(renderer: PSDL_Renderer; posX, posY, pixelSize: Integer; filled: Boolean);

implementation

procedure DrawChar(renderer: PSDL_Renderer; ch: Char; posX, posY, pixelSize: Integer);
var
  r, c: Integer;
  pixelRect: TSDL_Rect;
  rowVal: Byte;
  rows: array[0..4] of Byte;
begin
  ch := UpCase(ch);

  // Bitmap font matriks 3x5 per baris bit (bit 2..0)
  case ch of
    '0': begin rows[0]:=7; rows[1]:=5; rows[2]:=5; rows[3]:=5; rows[4]:=7; end;
    '1': begin rows[0]:=2; rows[1]:=6; rows[2]:=2; rows[3]:=2; rows[4]:=7; end;
    '2': begin rows[0]:=7; rows[1]:=1; rows[2]:=7; rows[3]:=4; rows[4]:=7; end;
    '3': begin rows[0]:=7; rows[1]:=1; rows[2]:=7; rows[3]:=1; rows[4]:=7; end;
    '4': begin rows[0]:=5; rows[1]:=5; rows[2]:=7; rows[3]:=1; rows[4]:=1; end;
    '5': begin rows[0]:=7; rows[1]:=4; rows[2]:=7; rows[3]:=1; rows[4]:=7; end;
    '6': begin rows[0]:=7; rows[1]:=4; rows[2]:=7; rows[3]:=5; rows[4]:=7; end;
    '7': begin rows[0]:=7; rows[1]:=1; rows[2]:=1; rows[3]:=1; rows[4]:=1; end;
    '8': begin rows[0]:=7; rows[1]:=5; rows[2]:=7; rows[3]:=5; rows[4]:=7; end;
    '9': begin rows[0]:=7; rows[1]:=5; rows[2]:=7; rows[3]:=1; rows[4]:=7; end;

    '+': begin rows[0]:=0; rows[1]:=2; rows[2]:=7; rows[3]:=2; rows[4]:=0; end;
    '-': begin rows[0]:=0; rows[1]:=0; rows[2]:=7; rows[3]:=0; rows[4]:=0; end;
    '*', 'X': begin rows[0]:=5; rows[1]:=5; rows[2]:=2; rows[3]:=5; rows[4]:=5; end;
    '/', ':': begin rows[0]:=0; rows[1]:=2; rows[2]:=0; rows[3]:=2; rows[4]:=0; end;
    '=': begin rows[0]:=0; rows[1]:=7; rows[2]:=0; rows[3]:=7; rows[4]:=0; end;
    '?': begin rows[0]:=7; rows[1]:=1; rows[2]:=3; rows[3]:=0; rows[4]:=2; end;
    '!': begin rows[0]:=2; rows[1]:=2; rows[2]:=2; rows[3]:=0; rows[4]:=2; end;
    '.': begin rows[0]:=0; rows[1]:=0; rows[2]:=0; rows[3]:=0; rows[4]:=2; end;
    ',': begin rows[0]:=0; rows[1]:=0; rows[2]:=0; rows[3]:=2; rows[4]:=4; end;

    'A': begin rows[0]:=2; rows[1]:=5; rows[2]:=7; rows[3]:=5; rows[4]:=5; end;
    'B': begin rows[0]:=6; rows[1]:=5; rows[2]:=6; rows[3]:=5; rows[4]:=6; end;
    'C': begin rows[0]:=7; rows[1]:=4; rows[2]:=4; rows[3]:=4; rows[4]:=7; end;
    'D': begin rows[0]:=6; rows[1]:=5; rows[2]:=5; rows[3]:=5; rows[4]:=6; end;
    'E': begin rows[0]:=7; rows[1]:=4; rows[2]:=7; rows[3]:=4; rows[4]:=7; end;
    'F': begin rows[0]:=7; rows[1]:=4; rows[2]:=7; rows[3]:=4; rows[4]:=4; end;
    'G': begin rows[0]:=7; rows[1]:=4; rows[2]:=5; rows[3]:=5; rows[4]:=7; end;
    'H': begin rows[0]:=5; rows[1]:=5; rows[2]:=7; rows[3]:=5; rows[4]:=5; end;
    'I': begin rows[0]:=7; rows[1]:=2; rows[2]:=2; rows[3]:=2; rows[4]:=7; end;
    'J': begin rows[0]:=1; rows[1]:=1; rows[2]:=1; rows[3]:=5; rows[4]:=2; end;
    'K': begin rows[0]:=5; rows[1]:=5; rows[2]:=6; rows[3]:=5; rows[4]:=5; end;
    'L': begin rows[0]:=4; rows[1]:=4; rows[2]:=4; rows[3]:=4; rows[4]:=7; end;
    'M': begin rows[0]:=5; rows[1]:=7; rows[2]:=5; rows[3]:=5; rows[4]:=5; end;
    'N': begin rows[0]:=5; rows[1]:=7; rows[2]:=7; rows[3]:=5; rows[4]:=5; end;
    'O': begin rows[0]:=7; rows[1]:=5; rows[2]:=5; rows[3]:=5; rows[4]:=7; end;
    'P': begin rows[0]:=7; rows[1]:=5; rows[2]:=7; rows[3]:=4; rows[4]:=4; end;
    'Q': begin rows[0]:=7; rows[1]:=5; rows[2]:=5; rows[3]:=6; rows[4]:=3; end;
    'R': begin rows[0]:=6; rows[1]:=5; rows[2]:=6; rows[3]:=5; rows[4]:=5; end;
    'S': begin rows[0]:=7; rows[1]:=4; rows[2]:=7; rows[3]:=1; rows[4]:=7; end;
    'T': begin rows[0]:=7; rows[1]:=2; rows[2]:=2; rows[3]:=2; rows[4]:=2; end;
    'U': begin rows[0]:=5; rows[1]:=5; rows[2]:=5; rows[3]:=5; rows[4]:=7; end;
    'V': begin rows[0]:=5; rows[1]:=5; rows[2]:=5; rows[3]:=5; rows[4]:=2; end;
    'W': begin rows[0]:=5; rows[1]:=5; rows[2]:=5; rows[3]:=7; rows[4]:=5; end;
    'Y': begin rows[0]:=5; rows[1]:=5; rows[2]:=2; rows[3]:=2; rows[4]:=2; end;
    'Z': begin rows[0]:=7; rows[1]:=1; rows[2]:=2; rows[3]:=4; rows[4]:=7; end;
    else
      begin rows[0]:=0; rows[1]:=0; rows[2]:=0; rows[3]:=0; rows[4]:=0; end;
  end;

  // Render kotak piksel yang aktif
  for r := 0 to 4 do
  begin
    rowVal := rows[r];
    for c := 0 to 2 do
    begin
      if (rowVal and (1 shl (2 - c))) <> 0 then
      begin
        pixelRect.x := posX + c * pixelSize;
        pixelRect.y := posY + r * pixelSize;
        pixelRect.w := pixelSize;
        pixelRect.h := pixelSize;
        SDL_RenderFillRect(renderer, @pixelRect);
      end;
    end;
  end;
end;

function GetTextWidth(const txt: String; pixelSize: Integer): Integer;
begin
  if Length(txt) = 0 then
    GetTextWidth := 0
  else
    GetTextWidth := Length(txt) * (4 * pixelSize) - pixelSize;
end;

procedure DrawText(renderer: PSDL_Renderer; const txt: String; posX, posY, pixelSize: Integer);
var
  idx, curX: Integer;
begin
  curX := posX;
  for idx := 1 to Length(txt) do
  begin
    DrawChar(renderer, txt[idx], curX, posY, pixelSize);
    curX := curX + (4 * pixelSize);
  end;
end;

procedure DrawTextCentered(renderer: PSDL_Renderer; const txt: String; centerX, posY, pixelSize: Integer);
var
  w: Integer;
begin
  w := GetTextWidth(txt, pixelSize);
  DrawText(renderer, txt, centerX - (w div 2), posY, pixelSize);
end;

procedure DrawHeart(renderer: PSDL_Renderer; posX, posY, pixelSize: Integer; filled: Boolean);
var
  r, c: Integer;
  pixelRect: TSDL_Rect;
  rowVal: Byte;
  rows: array[0..4] of Byte;
begin
  if filled then
  begin
    // Pola hati menyala (merah)
    rows[0] := 10;
    rows[1] := 31;
    rows[2] := 31;
    rows[3] := 14;
    rows[4] := 4;
    SDL_SetRenderDrawColor(renderer, 255, 60, 80, 255);
  end
  else
  begin
    // Pola hati kosong (abu-abu)
    rows[0] := 10;
    rows[1] := 21;
    rows[2] := 17;
    rows[3] := 10;
    rows[4] := 4;
    SDL_SetRenderDrawColor(renderer, 80, 80, 95, 255);
  end;

  for r := 0 to 4 do
  begin
    rowVal := rows[r];
    for c := 0 to 4 do
    begin
      if (rowVal and (1 shl (4 - c))) <> 0 then
      begin
        pixelRect.x := posX + c * pixelSize;
        pixelRect.y := posY + r * pixelSize;
        pixelRect.w := pixelSize;
        pixelRect.h := pixelSize;
        SDL_RenderFillRect(renderer, @pixelRect);
      end;
    end;
  end;
end;

end.

{ ============================================================================
  Unit        : UGameRenderer
  Deskripsi   : Modul grafis & tampilan (View): menangani seluruh proses
                penggambaran antarmuka (UI), arena grid, makanan, cacing,
                serta pop-up dialog Game Over menggunakan SDL2.
  Tugas Akhir : Pemrograman Dasar
  ============================================================================ }
unit UGameRenderer;

interface

uses
  SDL2, UTypes, UFont, UMathEngine, UGameLogic;

{ Prosedur utama untuk merender seluruh frame permainan ke layar }
procedure RenderGame(renderer: PSDL_Renderer; var g: TGame);

implementation

{ ----------------------------------------------------------------------------
  1. Penggambaran Header Baris Atas (Top Bar):
     - Kiri   : Skor pemain berwarna emas.
     - Tengah : Teks Soal Matematika berwarna cyan.
     - Kanan  : Ikon hati indikator sisa nyawa pemain.
     - Bawah  : Notifikasi status singkat "BENAR!" atau "SALAH!".
  ---------------------------------------------------------------------------- }
procedure DrawTopBar(renderer: PSDL_Renderer; var g: TGame);
var
  i, hx: Integer;
  questionStr: String;
begin
  { Label dan Angka Skor di sisi kiri }
  SDL_SetRenderDrawColor(renderer, 180, 190, 205, 255);
  DrawText(renderer, 'SKOR:', 40, 28, 2);

  SDL_SetRenderDrawColor(renderer, 255, 215, 0, 255); { Warna Emas }
  DrawText(renderer, NumberToString(g.score), 40 + GetTextWidth('SKOR: ', 2), 24, 3);

  { Teks Soal Matematika di bagian tengah }
  questionStr := 'SOAL: ' + NumberToString(g.question.op1) + ' ' +
                 g.question.opChar + ' ' +
                 NumberToString(g.question.op2) + ' = ?';
  SDL_SetRenderDrawColor(renderer, 80, 225, 255, 255); { Warna Cyan }
  DrawTextCentered(renderer, questionStr, 400, 24, 3);

  { Label dan Ikon Nyawa Hati di sisi kanan }
  SDL_SetRenderDrawColor(renderer, 180, 190, 205, 255);
  DrawText(renderer, 'NYAWA:', 615, 28, 2);

  hx := 685;
  for i := 1 to MAX_LIVES do
  begin
    { Gambar hati merah terang jika nyawa masih ada, abu-abu jika sudah hilang }
    DrawHeart(renderer, hx, 26, 3, i <= g.lives);
    hx := hx + 24;
  end;

  { Menampilkan teks umpan balik sementara jika ada ("BENAR! / SALAH!") }
  if g.feedback.timer > 0 then
  begin
    SDL_SetRenderDrawColor(renderer, g.feedback.r, g.feedback.g, g.feedback.b, 255);
    DrawTextCentered(renderer, g.feedback.text, 400, 58, 2);
    Dec(g.feedback.timer);
  end;
end;

{ ----------------------------------------------------------------------------
  2. Penggambaran Arena dan Garis-garis Grid Permainan
  ---------------------------------------------------------------------------- }
procedure DrawArenaAndGrid(renderer: PSDL_Renderer; const g: TGame);
var
  col, row: Integer;
  gridRect: TSDL_Rect;
begin
  { Latar belakang arena utama }
  SDL_SetRenderDrawColor(renderer, 28, 36, 48, 255);
  SDL_RenderFillRect(renderer, @g.area);

  { Garis tepi (border) arena }
  SDL_SetRenderDrawColor(renderer, 55, 68, 88, 255);
  SDL_RenderDrawRect(renderer, @g.area);

  { Garis-garis grid vertikal & horizontal tipis }
  SDL_SetRenderDrawColor(renderer, 35, 44, 56, 255);

  for col := 0 to (g.area.w div CELL_SIZE) do
  begin
    gridRect.x := g.area.x + col * CELL_SIZE;
    gridRect.y := g.area.y;
    gridRect.w := 1;
    gridRect.h := g.area.h;
    SDL_RenderFillRect(renderer, @gridRect);
  end;

  for row := 0 to (g.area.h div CELL_SIZE) do
  begin
    gridRect.x := g.area.x;
    gridRect.y := g.area.y + row * CELL_SIZE;
    gridRect.w := g.area.w;
    gridRect.h := 1;
    SDL_RenderFillRect(renderer, @gridRect);
  end;
end;

{ ----------------------------------------------------------------------------
  3. Penggambaran Makanan (Pilihan Jawaban)
     Setiap makanan berwujud kotak oranye keemasan dengan angka di tengahnya.
  ---------------------------------------------------------------------------- }
procedure DrawFoods(renderer: PSDL_Renderer; const g: TGame);
var
  k: Integer;
  foodRect: TSDL_Rect;
  numStr: String;
  tw, tx, ty: Integer;
begin
  for k := 0 to g.question.numChoices - 1 do
  begin
    if g.foods.active[k] then
    begin
      foodRect.x := g.foods.pos[k].x;
      foodRect.y := g.foods.pos[k].y;
      foodRect.w := CELL_SIZE;
      foodRect.h := CELL_SIZE;

      { Warna dasar makanan (oranye keemasan) }
      SDL_SetRenderDrawColor(renderer, 245, 166, 35, 255);
      SDL_RenderFillRect(renderer, @foodRect);

      { Border terang makanan }
      SDL_SetRenderDrawColor(renderer, 255, 215, 120, 255);
      SDL_RenderDrawRect(renderer, @foodRect);

      { Tuliskan angka pilihan jawaban tepat di tengah kotak makanan }
      numStr := NumberToString(g.question.choices[k]);
      tw := GetTextWidth(numStr, 2);
      tx := g.foods.pos[k].x + (CELL_SIZE - tw) div 2;
      ty := g.foods.pos[k].y + (CELL_SIZE - 10) div 2;

      SDL_SetRenderDrawColor(renderer, 20, 24, 32, 255);
      DrawText(renderer, numStr, tx, ty, 2);
    end;
  end;
end;

{ ----------------------------------------------------------------------------
  4. Penggambaran Ular / Cacing:
     - Badan : Warna hijau zamrud dengan margin 1 piksel agar terlihat beruas.
     - Kepala: Hijau terang saat hidup, atau merah kusam saat mati.
     - Mata  : Menghadap ke arah gerakan, atau berubah jadi 'X X' jika Game Over.
  ---------------------------------------------------------------------------- }
procedure DrawWorm(renderer: PSDL_Renderer; const g: TGame);
var
  j: Integer;
  wormRect: TSDL_Rect;
  eye1, eye2: TSDL_Rect;
  headX, headY: Integer;
begin
  { Gambar seluruh ruas badan cacing }
  for j := g.worm.length - 1 downto 1 do
  begin
    wormRect.x := g.worm.segments[j].x + 1;
    wormRect.y := g.worm.segments[j].y + 1;
    wormRect.w := CELL_SIZE - 2;
    wormRect.h := CELL_SIZE - 2;

    SDL_SetRenderDrawColor(renderer, 46, 204, 113, 255); { Hijau Zamrud }
    SDL_RenderFillRect(renderer, @wormRect);
  end;

  { Posisi kepala cacing }
  headX := g.worm.segments[0].x;
  headY := g.worm.segments[0].y;

  wormRect.x := headX + 1;
  wormRect.y := headY + 1;
  wormRect.w := CELL_SIZE - 2;
  wormRect.h := CELL_SIZE - 2;

  { Tentukan warna kepala berdasarkan status hidup atau mati }
  if g.state = STATE_GAMEOVER then
    SDL_SetRenderDrawColor(renderer, 235, 75, 85, 255)  { Merah Mati }
  else
    SDL_SetRenderDrawColor(renderer, 80, 245, 140, 255); { Hijau Muda Hidup }

  SDL_RenderFillRect(renderer, @wormRect);

  { Gambar mata cacing }
  if g.state = STATE_GAMEOVER then
  begin
    { Tampilan mata silang 'X X' saat Game Over }
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    DrawChar(renderer, 'X', headX + 3, headY + 4, 1);
    DrawChar(renderer, 'X', headX + 13, headY + 4, 1);
  end
  else
  begin
    { Tampilan mata normal yang menoleh sesuai arah jalan ular }
    eye1.w := 3; eye1.h := 3;
    eye2.w := 3; eye2.h := 3;

    if g.worm.dx > 0 then { Menghadap Kanan }
    begin
      eye1.x := headX + 16; eye1.y := headY + 5;
      eye2.x := headX + 16; eye2.y := headY + 16;
    end
    else if g.worm.dx < 0 then { Menghadap Kiri }
    begin
      eye1.x := headX + 5; eye1.y := headY + 5;
      eye2.x := headX + 5; eye2.y := headY + 16;
    end
    else if g.worm.dy < 0 then { Menghadap Atas }
    begin
      eye1.x := headX + 5; eye1.y := headY + 5;
      eye2.x := headX + 16; eye2.y := headY + 5;
    end
    else { Menghadap Bawah }
    begin
      eye1.x := headX + 5; eye1.y := headY + 16;
      eye2.x := headX + 16; eye2.y := headY + 16;
    end;

    SDL_SetRenderDrawColor(renderer, 15, 20, 25, 255);
    SDL_RenderFillRect(renderer, @eye1);
    SDL_RenderFillRect(renderer, @eye2);
  end;
end;

{ ----------------------------------------------------------------------------
  5. Penggambaran Pop-up Modal Game Over:
     Muncul di atas arena permainan saat cacing mati atau nyawa habis.
  ---------------------------------------------------------------------------- }
procedure DrawGameOverModal(renderer: PSDL_Renderer; const g: TGame);
var
  overlayRect, cardRect, headerRect, innerBorder, statBox, btnRect: TSDL_Rect;
begin
  { Lapisan bayangan gelap transparan di seluruh area game }
  overlayRect.x := g.area.x;
  overlayRect.y := g.area.y;
  overlayRect.w := g.area.w;
  overlayRect.h := g.area.h;

  SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
  SDL_SetRenderDrawColor(renderer, 10, 14, 22, 220);
  SDL_RenderFillRect(renderer, @overlayRect);

  { Kotak Card Pop-up di tengah }
  cardRect.x := 170;
  cardRect.y := 125;
  cardRect.w := 460;
  cardRect.h := 380;

  SDL_SetRenderDrawColor(renderer, 22, 28, 42, 255);
  SDL_RenderFillRect(renderer, @cardRect);

  { Pita garis merah aksen atas }
  headerRect.x := cardRect.x + 4;
  headerRect.y := cardRect.y + 4;
  headerRect.w := cardRect.w - 8;
  headerRect.h := 8;
  SDL_SetRenderDrawColor(renderer, 255, 65, 85, 255);
  SDL_RenderFillRect(renderer, @headerRect);

  { Garis tepi ganda pop-up }
  SDL_SetRenderDrawColor(renderer, 255, 65, 85, 255);
  SDL_RenderDrawRect(renderer, @cardRect);
  innerBorder.x := cardRect.x + 3;
  innerBorder.y := cardRect.y + 3;
  innerBorder.w := cardRect.w - 6;
  innerBorder.h := cardRect.h - 6;
  SDL_SetRenderDrawColor(renderer, 70, 35, 50, 255);
  SDL_RenderDrawRect(renderer, @innerBorder);

  { Judul GAME OVER }
  SDL_SetRenderDrawColor(renderer, 255, 65, 85, 255);
  DrawTextCentered(renderer, 'GAME OVER', 400, 150, 6);

  { Pesan penyebab kekalahan (Nabrak badan / Nyawa habis) }
  SDL_SetRenderDrawColor(renderer, 255, 195, 65, 255);
  DrawTextCentered(renderer, g.gameOverReason, 400, 220, 2);

  { Kotak rekap statistik hasil bermain }
  statBox.x := 210;
  statBox.y := 250;
  statBox.w := 380;
  statBox.h := 85;
  SDL_SetRenderDrawColor(renderer, 14, 18, 28, 255);
  SDL_RenderFillRect(renderer, @statBox);
  SDL_SetRenderDrawColor(renderer, 45, 55, 75, 255);
  SDL_RenderDrawRect(renderer, @statBox);

  { Teks Skor Akhir }
  SDL_SetRenderDrawColor(renderer, 180, 195, 215, 255);
  DrawText(renderer, 'SKOR AKHIR', 235, 268, 2);
  SDL_SetRenderDrawColor(renderer, 255, 215, 50, 255);
  DrawText(renderer, NumberToString(g.score), 470, 264, 3);

  { Teks Panjang Akhir Ular }
  SDL_SetRenderDrawColor(renderer, 180, 195, 215, 255);
  DrawText(renderer, 'PANJANG ULAR', 235, 302, 2);
  SDL_SetRenderDrawColor(renderer, 70, 240, 140, 255);
  DrawText(renderer, NumberToString(g.worm.length), 470, 298, 3);

  { Tombol interaksi Main Lagi }
  btnRect.x := 230;
  btnRect.y := 355;
  btnRect.w := 340;
  btnRect.h := 38;
  SDL_SetRenderDrawColor(renderer, 25, 70, 48, 255);
  SDL_RenderFillRect(renderer, @btnRect);
  SDL_SetRenderDrawColor(renderer, 60, 210, 120, 255);
  SDL_RenderDrawRect(renderer, @btnRect);

  SDL_SetRenderDrawColor(renderer, 120, 255, 180, 255);
  DrawTextCentered(renderer, 'SPASI: MAIN LAGI', 400, 365, 2);

  { Keterangan Tombol ESC }
  SDL_SetRenderDrawColor(renderer, 140, 155, 175, 255);
  DrawTextCentered(renderer, 'ESC: KELUAR', 400, 415, 2);

  SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE);
end;

{ ----------------------------------------------------------------------------
  Prosedur Utama RenderGame:
  Mengatur urutan rendering dari layer paling belakang ke paling depan.
  ---------------------------------------------------------------------------- }
procedure RenderGame(renderer: PSDL_Renderer; var g: TGame);
begin
  { 1. Hapus layar dan isi latar belakang jendela }
  SDL_SetRenderDrawColor(renderer, 15, 20, 30, 255);
  SDL_RenderClear(renderer);

  { 2. Gambar baris header atas (Skor, Soal Matematika, Nyawa) }
  DrawTopBar(renderer, g);

  { 3. Gambar arena permainan dan garis grid petak }
  DrawArenaAndGrid(renderer, g);

  { 4. Gambar kumpulan makanan angka jawaban di arena }
  DrawFoods(renderer, g);

  { 5. Gambar cacing (badan dan kepala) }
  DrawWorm(renderer, g);

  { 6. Gambar jendela pop-up Game Over jika status permainan kalah }
  if g.state = STATE_GAMEOVER then
    DrawGameOverModal(renderer, g);

  { 7. Tampilkan hasil buffer rendering ke layar monitor }
  SDL_RenderPresent(renderer);
end;

end.

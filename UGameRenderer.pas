unit UGameRenderer;

interface

uses
  SDL2, UTypes, UFont, UMathEngine, UGameLogic;

procedure RenderGame(renderer: PSDL_Renderer; var g: TGame);

implementation

// Menggambar header atas (skor, soal matematika, dan nyawa)
procedure DrawTopBar(renderer: PSDL_Renderer; var g: TGame);
var
  i, hx: Integer;
  questionStr: String;
begin
  // Skor
  SDL_SetRenderDrawColor(renderer, 180, 190, 205, 255);
  DrawText(renderer, 'SKOR:', 40, 28, 2);

  SDL_SetRenderDrawColor(renderer, 255, 215, 0, 255);
  DrawText(renderer, NumberToString(g.score), 40 + GetTextWidth('SKOR: ', 2), 24, 3);

  // Soal matematika
  questionStr := 'SOAL: ' + NumberToString(g.question.op1) + ' ' +
                 g.question.opChar + ' ' +
                 NumberToString(g.question.op2) + ' = ?';
  SDL_SetRenderDrawColor(renderer, 80, 225, 255, 255);
  DrawTextCentered(renderer, questionStr, 400, 24, 3);

  // Ikon hati nyawa
  SDL_SetRenderDrawColor(renderer, 180, 190, 205, 255);
  DrawText(renderer, 'NYAWA:', 615, 28, 2);

  hx := 685;
  for i := 1 to MAX_LIVES do
  begin
    DrawHeart(renderer, hx, 26, 3, i <= g.lives);
    hx := hx + 24;
  end;

  // Notifikasi singkat (Benar / Salah)
  if g.feedback.timer > 0 then
  begin
    SDL_SetRenderDrawColor(renderer, g.feedback.r, g.feedback.g, g.feedback.b, 255);
    DrawTextCentered(renderer, g.feedback.text, 400, 58, 2);
    Dec(g.feedback.timer);
  end;
end;

// Menggambar batas arena dan garis grid
procedure DrawArenaAndGrid(renderer: PSDL_Renderer; const g: TGame);
var
  col, row: Integer;
  gridRect: TSDL_Rect;
begin
  // Background arena
  SDL_SetRenderDrawColor(renderer, 28, 36, 48, 255);
  SDL_RenderFillRect(renderer, @g.area);

  // Garis tepi arena
  SDL_SetRenderDrawColor(renderer, 55, 68, 88, 255);
  SDL_RenderDrawRect(renderer, @g.area);

  // Garis grid vertikal & horizontal
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

// Menggambar makanan dengan angka di dalamnya
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

      // Kotak makanan
      SDL_SetRenderDrawColor(renderer, 245, 166, 35, 255);
      SDL_RenderFillRect(renderer, @foodRect);

      SDL_SetRenderDrawColor(renderer, 255, 215, 120, 255);
      SDL_RenderDrawRect(renderer, @foodRect);

      // Angka di tengah kotak
      numStr := NumberToString(g.question.choices[k]);
      tw := GetTextWidth(numStr, 2);
      tx := g.foods.pos[k].x + (CELL_SIZE - tw) div 2;
      ty := g.foods.pos[k].y + (CELL_SIZE - 10) div 2;

      SDL_SetRenderDrawColor(renderer, 20, 24, 32, 255);
      DrawText(renderer, numStr, tx, ty, 2);
    end;
  end;
end;

// Menggambar badan, kepala, dan mata ular
procedure DrawWorm(renderer: PSDL_Renderer; const g: TGame);
var
  j: Integer;
  wormRect: TSDL_Rect;
  eye1, eye2: TSDL_Rect;
  headX, headY: Integer;
begin
  // Ruas badan
  for j := g.worm.length - 1 downto 1 do
  begin
    wormRect.x := g.worm.segments[j].x + 1;
    wormRect.y := g.worm.segments[j].y + 1;
    wormRect.w := CELL_SIZE - 2;
    wormRect.h := CELL_SIZE - 2;

    SDL_SetRenderDrawColor(renderer, 46, 204, 113, 255);
    SDL_RenderFillRect(renderer, @wormRect);
  end;

  // Kepala ular
  headX := g.worm.segments[0].x;
  headY := g.worm.segments[0].y;

  wormRect.x := headX + 1;
  wormRect.y := headY + 1;
  wormRect.w := CELL_SIZE - 2;
  wormRect.h := CELL_SIZE - 2;

  if g.state = STATE_GAMEOVER then
    SDL_SetRenderDrawColor(renderer, 235, 75, 85, 255)
  else
    SDL_SetRenderDrawColor(renderer, 80, 245, 140, 255);

  SDL_RenderFillRect(renderer, @wormRect);

  // Mata ular
  if g.state = STATE_GAMEOVER then
  begin
    // Mata silang saat game over
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    DrawChar(renderer, 'X', headX + 3, headY + 4, 1);
    DrawChar(renderer, 'X', headX + 13, headY + 4, 1);
  end
  else
  begin
    // Arah mata sesuai arah gerak
    eye1.w := 3; eye1.h := 3;
    eye2.w := 3; eye2.h := 3;

    if g.worm.dx > 0 then
    begin
      eye1.x := headX + 16; eye1.y := headY + 5;
      eye2.x := headX + 16; eye2.y := headY + 16;
    end
    else if g.worm.dx < 0 then
    begin
      eye1.x := headX + 5; eye1.y := headY + 5;
      eye2.x := headX + 5; eye2.y := headY + 16;
    end
    else if g.worm.dy < 0 then
    begin
      eye1.x := headX + 5; eye1.y := headY + 5;
      eye2.x := headX + 16; eye2.y := headY + 5;
    end
    else
    begin
      eye1.x := headX + 5; eye1.y := headY + 16;
      eye2.x := headX + 16; eye2.y := headY + 16;
    end;

    SDL_SetRenderDrawColor(renderer, 15, 20, 25, 255);
    SDL_RenderFillRect(renderer, @eye1);
    SDL_RenderFillRect(renderer, @eye2);
  end;
end;

// Layar Menu Utama (Start Menu)
procedure DrawMainMenu(renderer: PSDL_Renderer);
var
  menuBox, headerRect, innerBorder, infoBox, ctrlBox, btnRect, lineRect: TSDL_Rect;
begin
  // Background jendela
  SDL_SetRenderDrawColor(renderer, 15, 20, 30, 255);
  SDL_RenderClear(renderer);

  // Kotak utama menu
  menuBox.x := 80;
  menuBox.y := 35;
  menuBox.w := 640;
  menuBox.h := 530;

  SDL_SetRenderDrawColor(renderer, 22, 28, 42, 255);
  SDL_RenderFillRect(renderer, @menuBox);

  // Garis border menu
  SDL_SetRenderDrawColor(renderer, 80, 245, 140, 255);
  SDL_RenderDrawRect(renderer, @menuBox);
  innerBorder.x := menuBox.x + 3;
  innerBorder.y := menuBox.y + 3;
  innerBorder.w := menuBox.w - 6;
  innerBorder.h := menuBox.h - 6;
  SDL_SetRenderDrawColor(renderer, 45, 60, 85, 255);
  SDL_RenderDrawRect(renderer, @innerBorder);

  // Pita aksen atas
  headerRect.x := menuBox.x + 4;
  headerRect.y := menuBox.y + 4;
  headerRect.w := menuBox.w - 8;
  headerRect.h := 8;
  SDL_SetRenderDrawColor(renderer, 80, 245, 140, 255);
  SDL_RenderFillRect(renderer, @headerRect);

  // Judul Utama Game
  SDL_SetRenderDrawColor(renderer, 80, 245, 140, 255);
  DrawTextCentered(renderer, 'MATH WORM', 400, 65, 7);

  // Subjudul
  SDL_SetRenderDrawColor(renderer, 255, 215, 0, 255);
  DrawTextCentered(renderer, 'GAME EDUKASI MATEMATIKA INTERAKTIF', 400, 130, 2);

  // Garis pembatas
  lineRect.x := 120;
  lineRect.y := 155;
  lineRect.w := 560;
  lineRect.h := 2;
  SDL_SetRenderDrawColor(renderer, 45, 58, 80, 255);
  SDL_RenderFillRect(renderer, @lineRect);

  // Kotak Panduan Bermain
  infoBox.x := 120;
  infoBox.y := 175;
  infoBox.w := 560;
  infoBox.h := 130;
  SDL_SetRenderDrawColor(renderer, 16, 20, 32, 255);
  SDL_RenderFillRect(renderer, @infoBox);
  SDL_SetRenderDrawColor(renderer, 45, 55, 75, 255);
  SDL_RenderDrawRect(renderer, @infoBox);

  SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
  DrawText(renderer, 'CARA BERMAIN:', 140, 190, 2);

  SDL_SetRenderDrawColor(renderer, 80, 225, 255, 255);
  DrawText(renderer, '1. LIHAT SOAL (+, -, X, :) DI HEADER ATAS', 140, 215, 2);

  SDL_SetRenderDrawColor(renderer, 120, 255, 170, 255);
  DrawText(renderer, '2. MAKAN ANGKA JAWABAN YANG BENAR (+10 SKOR)', 140, 240, 2);

  SDL_SetRenderDrawColor(renderer, 255, 185, 65, 255);
  DrawText(renderer, '3. HINDARI JAWABAN SALAH (MODAL 3 NYAWA)', 140, 265, 2);

  SDL_SetRenderDrawColor(renderer, 255, 95, 95, 255);
  DrawText(renderer, '4. JANGAN SAMPAI MENABRAK BADAN SENDIRI!', 140, 290, 2);

  // Kotak Petunjuk Kontrol
  ctrlBox.x := 120;
  ctrlBox.y := 320;
  ctrlBox.w := 560;
  ctrlBox.h := 80;
  SDL_SetRenderDrawColor(renderer, 16, 20, 32, 255);
  SDL_RenderFillRect(renderer, @ctrlBox);
  SDL_SetRenderDrawColor(renderer, 45, 55, 75, 255);
  SDL_RenderDrawRect(renderer, @ctrlBox);

  SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
  DrawText(renderer, 'KONTROL:', 140, 335, 2);

  SDL_SetRenderDrawColor(renderer, 180, 195, 215, 255);
  DrawText(renderer, 'WASD / TOMBOL PANAH : MENGARAHKAN ULAR', 140, 358, 2);
  DrawText(renderer, 'P : JEDA (PAUSE)    |  ESC : KELUAR', 140, 380, 2);

  // Tombol Mulai
  btnRect.x := 200;
  btnRect.y := 420;
  btnRect.w := 400;
  btnRect.h := 46;
  SDL_SetRenderDrawColor(renderer, 25, 75, 50, 255);
  SDL_RenderFillRect(renderer, @btnRect);
  SDL_SetRenderDrawColor(renderer, 80, 245, 140, 255);
  SDL_RenderDrawRect(renderer, @btnRect);

  SDL_SetRenderDrawColor(renderer, 120, 255, 180, 255);
  DrawTextCentered(renderer, 'ENTER: MULAI MAIN', 400, 434, 3);

  // Keterangan keluar
  SDL_SetRenderDrawColor(renderer, 140, 155, 175, 255);
  DrawTextCentered(renderer, 'ESC: KELUAR DARI GAME', 400, 490, 2);
end;

// Pop-up dialog saat game di-Pause (Jeda)
procedure DrawPauseModal(renderer: PSDL_Renderer; const g: TGame);
var
  overlayRect, cardRect, headerRect, innerBorder, btnRect: TSDL_Rect;
begin
  // Overlay gelap transparan di arena
  overlayRect.x := g.area.x;
  overlayRect.y := g.area.y;
  overlayRect.w := g.area.w;
  overlayRect.h := g.area.h;

  SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
  SDL_SetRenderDrawColor(renderer, 10, 14, 22, 215);
  SDL_RenderFillRect(renderer, @overlayRect);

  // Kotak dialog jeda
  cardRect.x := 190;
  cardRect.y := 150;
  cardRect.w := 420;
  cardRect.h := 310;

  SDL_SetRenderDrawColor(renderer, 22, 28, 42, 255);
  SDL_RenderFillRect(renderer, @cardRect);

  headerRect.x := cardRect.x + 4;
  headerRect.y := cardRect.y + 4;
  headerRect.w := cardRect.w - 8;
  headerRect.h := 8;
  SDL_SetRenderDrawColor(renderer, 80, 225, 255, 255);
  SDL_RenderFillRect(renderer, @headerRect);

  SDL_SetRenderDrawColor(renderer, 80, 225, 255, 255);
  SDL_RenderDrawRect(renderer, @cardRect);
  innerBorder.x := cardRect.x + 3;
  innerBorder.y := cardRect.y + 3;
  innerBorder.w := cardRect.w - 6;
  innerBorder.h := cardRect.h - 6;
  SDL_SetRenderDrawColor(renderer, 45, 65, 85, 255);
  SDL_RenderDrawRect(renderer, @innerBorder);

  // Judul
  SDL_SetRenderDrawColor(renderer, 80, 225, 255, 255);
  DrawTextCentered(renderer, 'PAUSED', 400, 180, 6);

  SDL_SetRenderDrawColor(renderer, 255, 215, 0, 255);
  DrawTextCentered(renderer, 'PERMAINAN SEDANG DIJEDA', 400, 245, 2);

  // Info status saat ini
  SDL_SetRenderDrawColor(renderer, 180, 195, 215, 255);
  DrawTextCentered(renderer, 'SKOR SAAT INI: ' + NumberToString(g.score), 400, 285, 2);

  // Tombol lanjut
  btnRect.x := 230;
  btnRect.y := 325;
  btnRect.w := 340;
  btnRect.h := 38;
  SDL_SetRenderDrawColor(renderer, 25, 60, 75, 255);
  SDL_RenderFillRect(renderer, @btnRect);
  SDL_SetRenderDrawColor(renderer, 80, 225, 255, 255);
  SDL_RenderDrawRect(renderer, @btnRect);

  SDL_SetRenderDrawColor(renderer, 130, 235, 255, 255);
  DrawTextCentered(renderer, 'ENTER: LANJUT MAIN', 400, 335, 2);

  SDL_SetRenderDrawColor(renderer, 140, 155, 175, 255);
  DrawTextCentered(renderer, 'M: MENU UTAMA  |  ESC: KELUAR', 400, 395, 2);

  SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE);
end;

// Dialog pop-up layar Game Over
procedure DrawGameOverModal(renderer: PSDL_Renderer; const g: TGame);
var
  overlayRect, cardRect, headerRect, innerBorder, statBox, btnRect: TSDL_Rect;
begin
  // Overlay gelap transparan
  overlayRect.x := g.area.x;
  overlayRect.y := g.area.y;
  overlayRect.w := g.area.w;
  overlayRect.h := g.area.h;

  SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
  SDL_SetRenderDrawColor(renderer, 10, 14, 22, 220);
  SDL_RenderFillRect(renderer, @overlayRect);

  // Kotak dialog modal
  cardRect.x := 170;
  cardRect.y := 125;
  cardRect.w := 460;
  cardRect.h := 380;

  SDL_SetRenderDrawColor(renderer, 22, 28, 42, 255);
  SDL_RenderFillRect(renderer, @cardRect);

  headerRect.x := cardRect.x + 4;
  headerRect.y := cardRect.y + 4;
  headerRect.w := cardRect.w - 8;
  headerRect.h := 8;
  SDL_SetRenderDrawColor(renderer, 255, 65, 85, 255);
  SDL_RenderFillRect(renderer, @headerRect);

  SDL_SetRenderDrawColor(renderer, 255, 65, 85, 255);
  SDL_RenderDrawRect(renderer, @cardRect);
  innerBorder.x := cardRect.x + 3;
  innerBorder.y := cardRect.y + 3;
  innerBorder.w := cardRect.w - 6;
  innerBorder.h := cardRect.h - 6;
  SDL_SetRenderDrawColor(renderer, 70, 35, 50, 255);
  SDL_RenderDrawRect(renderer, @innerBorder);

  // Teks judul & alasan kalah
  SDL_SetRenderDrawColor(renderer, 255, 65, 85, 255);
  DrawTextCentered(renderer, 'GAME OVER', 400, 150, 6);

  SDL_SetRenderDrawColor(renderer, 255, 195, 65, 255);
  DrawTextCentered(renderer, g.gameOverReason, 400, 220, 2);

  // Kotak statistik hasil
  statBox.x := 210;
  statBox.y := 250;
  statBox.w := 380;
  statBox.h := 85;
  SDL_SetRenderDrawColor(renderer, 14, 18, 28, 255);
  SDL_RenderFillRect(renderer, @statBox);
  SDL_SetRenderDrawColor(renderer, 45, 55, 75, 255);
  SDL_RenderDrawRect(renderer, @statBox);

  SDL_SetRenderDrawColor(renderer, 180, 195, 215, 255);
  DrawText(renderer, 'SKOR AKHIR', 235, 268, 2);
  SDL_SetRenderDrawColor(renderer, 255, 215, 50, 255);
  DrawText(renderer, NumberToString(g.score), 470, 264, 3);

  SDL_SetRenderDrawColor(renderer, 180, 195, 215, 255);
  DrawText(renderer, 'PANJANG ULAR', 235, 302, 2);
  SDL_SetRenderDrawColor(renderer, 70, 240, 140, 255);
  DrawText(renderer, NumberToString(g.worm.length), 470, 298, 3);

  // Tombol aksi
  btnRect.x := 210;
  btnRect.y := 355;
  btnRect.w := 380;
  btnRect.h := 38;
  SDL_SetRenderDrawColor(renderer, 25, 70, 48, 255);
  SDL_RenderFillRect(renderer, @btnRect);
  SDL_SetRenderDrawColor(renderer, 60, 210, 120, 255);
  SDL_RenderDrawRect(renderer, @btnRect);

  SDL_SetRenderDrawColor(renderer, 120, 255, 180, 255);
  DrawTextCentered(renderer, 'ENTER: MAIN LAGI', 400, 365, 2);

  SDL_SetRenderDrawColor(renderer, 140, 155, 175, 255);
  DrawTextCentered(renderer, 'M: MENU UTAMA  |  ESC: KELUAR', 400, 415, 2);

  SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE);
end;

procedure RenderGame(renderer: PSDL_Renderer; var g: TGame);
begin
  // Jika sedang di menu utama, gambar tampilan menu
  if g.state = STATE_MENU then
  begin
    DrawMainMenu(renderer);
    SDL_RenderPresent(renderer);
    Exit;
  end;

  // Latar belakang game
  SDL_SetRenderDrawColor(renderer, 15, 20, 30, 255);
  SDL_RenderClear(renderer);

  DrawTopBar(renderer, g);
  DrawArenaAndGrid(renderer, g);
  DrawFoods(renderer, g);
  DrawWorm(renderer, g);

  // Modal dialog pop-up sesuai kondisi
  if g.state = STATE_PAUSED then
    DrawPauseModal(renderer, g)
  else if g.state = STATE_GAMEOVER then
    DrawGameOverModal(renderer, g);

  SDL_RenderPresent(renderer);
end;

end.

{ ============================================================================
  Unit        : UGameLogic
  Deskripsi   : Modul logika utama permainan (Model): penanganan posisi ular,
                pergerakan, pembungkusan dinding (wrap-around), deteksi
                tabrakan badan sendiri, proses makan, skor, dan nyawa.
  Tugas Akhir : Pemrograman Dasar
  ============================================================================ }
unit UGameLogic;

interface

uses
  SDL2, Math, UTypes, UMathEngine;

{ Struktur data gabungan yang menyimpan seluruh kondisi dunia permainan }
type
  TGame = record
    area: TSDL_Rect;            { Batas koordinat & ukuran arena permainan }
    worm: TWorm;                { Data badan, posisi, dan arah ular }
    foods: TFoodState;          { Data posisi & status makanan di arena }
    question: TMathQuestion;    { Soal matematika yang sedang aktif }
    score: Integer;             { Skor pemain }
    lives: Integer;             { Jumlah nyawa tersisa }
    state: Integer;             { Status game: STATE_PLAYING atau STATE_GAMEOVER }
    gameOverReason: String;     { Alasan kalah untuk ditampilkan di pop-up }
    feedback: TFeedback;        { Data teks notifikasi singkat (Benar/Salah) }
  end;

{ Menginisialisasi atau mereset seluruh variabel permainan ke kondisi awal }
procedure InitGame(var g: TGame);

{ Mengacak dan menempatkan paket makanan baru pada petak grid yang valid }
procedure SpawnFoods(var g: TGame);

{ Mengubah arah pergerakan ular berdasarkan tombol yang ditekan pemain }
procedure ChangeDirection(var g: TGame; newDX, newDY: Integer);

{ Melakukan 1 langkah pergerakan game: tabrakan, makan makanan, dan geser badan }
procedure UpdateGameStep(var g: TGame);

implementation

{ ----------------------------------------------------------------------------
  Prosedur SpawnFoods:
  1. Memanggil generator soal dari UMathEngine.
  2. Menentukan koordinat petak acak untuk tiap makanan.
  3. Memvalidasi agar makanan tidak menimpa badan ular, makanan lain,
     atau tepat 1 petak di depan kepala ular.
  ---------------------------------------------------------------------------- }
procedure SpawnFoods(var g: TGame);
var
  k, m, j: Integer;
  fx, fy: Integer;
  validPosition: Boolean;
  maxCols, maxRows: Integer;
begin
  GenerateNewMathQuestion(g.question);

  maxCols := g.area.w div CELL_SIZE;
  maxRows := g.area.h div CELL_SIZE;

  for k := 0 to g.question.numChoices - 1 do
  begin
    g.foods.active[k] := True;
    repeat
      validPosition := True;
      fx := g.area.x + Random(maxCols) * CELL_SIZE;
      fy := g.area.y + Random(maxRows) * CELL_SIZE;

      { Cek 1: Tidak boleh menimpa bagian manapun dari badan ular }
      for j := 0 to g.worm.length - 1 do
      begin
        if (g.worm.segments[j].x = fx) and (g.worm.segments[j].y = fy) then
        begin
          validPosition := False;
          Break;
        end;
      end;

      { Cek 2: Tidak boleh menimpa makanan lain yang sudah ditentukan posisinya }
      if validPosition then
      begin
        for m := 0 to k - 1 do
        begin
          if (g.foods.pos[m].x = fx) and (g.foods.pos[m].y = fy) then
          begin
            validPosition := False;
            Break;
          end;
        end;
      end;

      { Cek 3: Hindari spawn tepat 1 petak di depan kepala ular }
      if (fx = g.worm.segments[0].x + g.worm.dx) and
         (fy = g.worm.segments[0].y + g.worm.dy) then
        validPosition := False;

    until validPosition;

    g.foods.pos[k].x := fx;
    g.foods.pos[k].y := fy;
  end;
end;

{ ----------------------------------------------------------------------------
  Prosedur InitGame:
  Mengatur ulang arena, cacing (3 segmen di tengah), arah awal ke kanan,
  skor 0, 3 nyawa, dan langsung memunculkan soal matematika pertama.
  ---------------------------------------------------------------------------- }
procedure InitGame(var g: TGame);
begin
  { Menentukan batas arena: lebar 720 (30 petak), tinggi 480 (20 petak) }
  g.area.x := 40;
  g.area.y := 84;
  g.area.w := 720;
  g.area.h := 480;

  { Posisi awal cacing terdiri dari 3 segmen horizontal }
  g.worm.length := START_LENGTH;

  g.worm.segments[0].x := g.area.x + 10 * CELL_SIZE; { Kepala }
  g.worm.segments[0].y := g.area.y + 10 * CELL_SIZE;

  g.worm.segments[1].x := g.worm.segments[0].x - CELL_SIZE; { Badan }
  g.worm.segments[1].y := g.worm.segments[0].y;

  g.worm.segments[2].x := g.worm.segments[1].x - CELL_SIZE; { Ekor }
  g.worm.segments[2].y := g.worm.segments[0].y;

  { Arah awal pergerakan: ke kanan }
  g.worm.dx := CELL_SIZE;
  g.worm.dy := 0;
  g.worm.nextDX := g.worm.dx;
  g.worm.nextDY := g.worm.dy;

  { Status awal permainan }
  g.score := 0;
  g.lives := MAX_LIVES;
  g.state := STATE_PLAYING;
  g.gameOverReason := '';

  g.feedback.timer := 0;
  g.feedback.text := '';

  { Munculkan makanan dan soal awal }
  SpawnFoods(g);
end;

{ ----------------------------------------------------------------------------
  Prosedur ChangeDirection:
  Mencegah pembalikan arah 180 derajat langsung (misal sedang jalan ke kanan
  tidak boleh langsung berbalik ke kiri karena akan menabrak leher sendiri).
  ---------------------------------------------------------------------------- }
procedure ChangeDirection(var g: TGame; newDX, newDY: Integer);
begin
  if g.state <> STATE_PLAYING then Exit;

  if (newDY <> 0) and (g.worm.dy = 0) then
  begin
    g.worm.nextDX := 0;
    g.worm.nextDY := newDY;
  end
  else if (newDX <> 0) and (g.worm.dx = 0) then
  begin
    g.worm.nextDX := newDX;
    g.worm.nextDY := 0;
  end;
end;

{ ----------------------------------------------------------------------------
  Prosedur UpdateGameStep:
  Dieksekusi setiap interval waktu tick permainan (150 ms):
  1. Mengarahkan kepala ular ke posisi baru.
  2. Wrap-around menembus batas arena.
  3. Cek Self-Collision (nabrak badan sendiri -> GAME OVER).
  4. Cek makanan yang disentuh:
     - Jawaban benar: Skor +10, panjang bertambah, regenerasi soal.
     - Jawaban salah: Nyawa -1, jika habis -> GAME OVER.
  5. Menggeser setiap segmen badan mengikuti kepala.
  ---------------------------------------------------------------------------- }
procedure UpdateGameStep(var g: TGame);
var
  headX, headY: Integer;
  selfCollision, ateFood: Boolean;
  eatenIdx, i, k: Integer;
begin
  if g.state <> STATE_PLAYING then Exit;

  { Terapkan arah yang telah divalidasi }
  g.worm.dx := g.worm.nextDX;
  g.worm.dy := g.worm.nextDY;

  { Hitung calon koordinat kepala berikutnya }
  headX := g.worm.segments[0].x + g.worm.dx;
  headY := g.worm.segments[0].y + g.worm.dy;

  { Menembus dinding arena (Wrap Around) }
  if headX < g.area.x then
    headX := g.area.x + g.area.w - CELL_SIZE
  else if headX >= g.area.x + g.area.w then
    headX := g.area.x;

  if headY < g.area.y then
    headY := g.area.y + g.area.h - CELL_SIZE
  else if headY >= g.area.y + g.area.h then
    headY := g.area.y;

  { Deteksi tabrakan dengan badan sendiri (Self-Collision) }
  selfCollision := False;
  for i := 1 to g.worm.length - 1 do
  begin
    if (headX = g.worm.segments[i].x) and (headY = g.worm.segments[i].y) then
    begin
      selfCollision := True;
      Break;
    end;
  end;

  if selfCollision then
  begin
    g.state := STATE_GAMEOVER;
    g.gameOverReason := 'MENABRAK BADAN SENDIRI!';
    Exit; { Berhenti melangkah agar posisi ular membeku di titik tabrakan }
  end;

  { Deteksi apakah kepala menyentuh salah satu makanan }
  ateFood := False;
  eatenIdx := -1;

  for k := 0 to g.question.numChoices - 1 do
  begin
    if g.foods.active[k] and
       (headX = g.foods.pos[k].x) and
       (headY = g.foods.pos[k].y) then
    begin
      ateFood := True;
      eatenIdx := k;
      Break;
    end;
  end;

  if ateFood then
  begin
    if eatenIdx = g.question.correctChoiceIndex then
    begin
      { ======================================================================
        JAWABAN BENAR: Skor bertambah +10 dan panjang badan memanjang
        ====================================================================== }
      Inc(g.score, 10);
      if g.worm.length < MAX_WORM_LENGTH then
      begin
        { Gandakan segmen terakhir untuk menambah 1 ruas panjang }
        g.worm.segments[g.worm.length] := g.worm.segments[g.worm.length - 1];
        Inc(g.worm.length);
      end;

      { Notifikasi visual hijau }
      g.feedback.text := 'BENAR! +10 SKOR';
      g.feedback.r := 70;
      g.feedback.g := 240;
      g.feedback.b := 120;
      g.feedback.timer := 15;

      { Regenerasi soal baru dan posisi makanan baru }
      SpawnFoods(g);
    end
    else
    begin
      { ======================================================================
        JAWABAN SALAH: Nyawa berkurang 1
        ====================================================================== }
      Dec(g.lives);

      { Notifikasi visual merah }
      g.feedback.text := 'SALAH! -1 NYAWA';
      g.feedback.r := 255;
      g.feedback.g := 65;
      g.feedback.b := 80;
      g.feedback.timer := 15;

      if g.lives <= 0 then
      begin
        g.state := STATE_GAMEOVER;
        g.gameOverReason := 'NYAWA TELAH HABIS!';
      end
      else
        SpawnFoods(g);
    end;
  end;

  { Geser posisi setiap ruas badan mengikuti ruas di depannya }
  for i := g.worm.length - 1 downto 1 do
    g.worm.segments[i] := g.worm.segments[i - 1];

  { Letakkan kepala di koordinat baru }
  g.worm.segments[0].x := headX;
  g.worm.segments[0].y := headY;
end;

end.

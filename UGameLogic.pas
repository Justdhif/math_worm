unit UGameLogic;

interface

uses
  SDL2, Math, UTypes, UMathEngine;

type
  TGame = record
    area: TSDL_Rect;
    worm: TWorm;
    foods: TFoodState;
    question: TMathQuestion;
    score: Integer;
    lives: Integer;
    state: Integer;
    gameOverReason: String;
    feedback: TFeedback;
  end;

procedure InitGame(var g: TGame);
procedure SpawnFoods(var g: TGame);
procedure ChangeDirection(var g: TGame; newDX, newDY: Integer);
procedure UpdateGameStep(var g: TGame);

implementation

// Menempatkan makanan acak di grid tanpa menimpa ular atau makanan lain
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

      // Cek tidak menimpa badan ular
      for j := 0 to g.worm.length - 1 do
      begin
        if (g.worm.segments[j].x = fx) and (g.worm.segments[j].y = fy) then
        begin
          validPosition := False;
          Break;
        end;
      end;

      // Cek tidak menimpa makanan lain
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

      // Hindari spawn tepat 1 petak di depan kepala
      if (fx = g.worm.segments[0].x + g.worm.dx) and
         (fy = g.worm.segments[0].y + g.worm.dy) then
        validPosition := False;

    until validPosition;

    g.foods.pos[k].x := fx;
    g.foods.pos[k].y := fy;
  end;
end;

// Reset status permainan ke kondisi awal
procedure InitGame(var g: TGame);
begin
  g.area.x := 40;
  g.area.y := 84;
  g.area.w := 720;
  g.area.h := 480;

  g.worm.length := START_LENGTH;

  // Tiga ruas cacing awal
  g.worm.segments[0].x := g.area.x + 10 * CELL_SIZE;
  g.worm.segments[0].y := g.area.y + 10 * CELL_SIZE;

  g.worm.segments[1].x := g.worm.segments[0].x - CELL_SIZE;
  g.worm.segments[1].y := g.worm.segments[0].y;

  g.worm.segments[2].x := g.worm.segments[1].x - CELL_SIZE;
  g.worm.segments[2].y := g.worm.segments[0].y;

  // Arah gerak awal ke kanan
  g.worm.dx := CELL_SIZE;
  g.worm.dy := 0;
  g.worm.nextDX := g.worm.dx;
  g.worm.nextDY := g.worm.dy;

  g.score := 0;
  g.lives := MAX_LIVES;
  g.state := STATE_PLAYING;
  g.gameOverReason := '';

  g.feedback.timer := 0;
  g.feedback.text := '';

  SpawnFoods(g);
end;

// Validasi input arah (mencegah berbalik 180 derajat langsung)
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

// Satu siklus langkah permainan (bergerak, tabrakan, dan makan)
procedure UpdateGameStep(var g: TGame);
var
  headX, headY: Integer;
  selfCollision, ateFood: Boolean;
  eatenIdx, i, k: Integer;
begin
  if g.state <> STATE_PLAYING then Exit;

  g.worm.dx := g.worm.nextDX;
  g.worm.dy := g.worm.nextDY;

  headX := g.worm.segments[0].x + g.worm.dx;
  headY := g.worm.segments[0].y + g.worm.dy;

  // Tembus batas arena (wrap-around)
  if headX < g.area.x then
    headX := g.area.x + g.area.w - CELL_SIZE
  else if headX >= g.area.x + g.area.w then
    headX := g.area.x;

  if headY < g.area.y then
    headY := g.area.y + g.area.h - CELL_SIZE
  else if headY >= g.area.y + g.area.h then
    headY := g.area.y;

  // Cek tabrak badan sendiri (self-collision)
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
    Exit;
  end;

  // Cek makan jawaban
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
      // Jawaban benar: tambah skor dan panjang
      Inc(g.score, 10);
      if g.worm.length < MAX_WORM_LENGTH then
      begin
        g.worm.segments[g.worm.length] := g.worm.segments[g.worm.length - 1];
        Inc(g.worm.length);
      end;

      g.feedback.text := 'BENAR! +10 SKOR';
      g.feedback.r := 70;
      g.feedback.g := 240;
      g.feedback.b := 120;
      g.feedback.timer := 15;

      SpawnFoods(g);
    end
    else
    begin
      // Jawaban salah: kurangi nyawa
      Dec(g.lives);
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

  // Geser posisi badan
  for i := g.worm.length - 1 downto 1 do
    g.worm.segments[i] := g.worm.segments[i - 1];

  // Posisikan kepala
  g.worm.segments[0].x := headX;
  g.worm.segments[0].y := headY;
end;

end.

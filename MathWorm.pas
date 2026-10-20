program MathWorm;

uses
  SDL2,
  UTypes,
  UGameLogic,
  UGameRenderer;

var
  window: PSDL_Window;
  renderer: PSDL_Renderer;
  event: TSDL_Event;
  game: TGame;
  running: Boolean;
  lastMove, currentTime: UInt32;

begin
  Randomize;

  // Inisialisasi video SDL2
  if SDL_Init(SDL_INIT_VIDEO) < 0 then
  begin
    WriteLn('Error: Gagal menginisialisasi subsistem video SDL2.');
    Halt(1);
  end;

  // Buat jendela aplikasi
  window := SDL_CreateWindow(
    'Math Worm - Game Cacing Edukasi Matematika',
    SDL_WINDOWPOS_CENTERED,
    SDL_WINDOWPOS_CENTERED,
    WINDOW_WIDTH,
    WINDOW_HEIGHT,
    SDL_WINDOW_SHOWN
  );

  if window = nil then
  begin
    WriteLn('Error: Gagal membuat jendela SDL2.');
    SDL_Quit;
    Halt(1);
  end;

  // Buat renderer akselerasi GPU
  renderer := SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
  if renderer = nil then
  begin
    WriteLn('Error: Gagal membuat renderer SDL2.');
    SDL_DestroyWindow(window);
    SDL_Quit;
    Halt(1);
  end;

  // Inisialisasi kondisi permainan
  InitGame(game);

  running := True;
  lastMove := SDL_GetTicks;

  // Loop utama game
  while running do
  begin
    // Polling event input
    while SDL_PollEvent(@event) = 1 do
    begin
      if event.type_ = Cardinal(SDL_QUITEV) then
        running := False;

      if event.type_ = SDL_KEYDOWN then
      begin
        case event.key.keysym.sym of
          SDLK_ESCAPE:
            running := False;

          SDLK_SPACE, SDLK_RETURN:
            if game.state = STATE_GAMEOVER then
              InitGame(game);

          SDLK_UP, SDLK_w:
            ChangeDirection(game, 0, -CELL_SIZE);

          SDLK_DOWN, SDLK_s:
            ChangeDirection(game, 0, CELL_SIZE);

          SDLK_LEFT, SDLK_a:
            ChangeDirection(game, -CELL_SIZE, 0);

          SDLK_RIGHT, SDLK_d:
            ChangeDirection(game, CELL_SIZE, 0);
        end;
      end;
    end;

    // Update gerakan ular setiap interval 150 ms
    currentTime := SDL_GetTicks;
    if (game.state = STATE_PLAYING) and (currentTime - lastMove >= 150) then
    begin
      lastMove := currentTime;
      UpdateGameStep(game);
    end;

    // Render tampilan frame
    RenderGame(renderer, game);
    SDL_Delay(1);
  end;

  // Bersihkan resource SDL2
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit;
end.

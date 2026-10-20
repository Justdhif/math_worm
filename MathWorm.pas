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

  // Inisialisasi status awal (masuk ke Menu Utama)
  InitGame(game);

  running := True;
  lastMove := SDL_GetTicks;

  // Loop utama game
  while running do
  begin
    // Polling event input keyboard & window
    while SDL_PollEvent(@event) = 1 do
    begin
      if event.type_ = Cardinal(SDL_QUITEV) then
        running := False;

      if event.type_ = SDL_KEYDOWN then
      begin
        case game.state of
          // 1. INPUT PADA MENU UTAMA
          STATE_MENU:
          begin
            case event.key.keysym.sym of
              SDLK_SPACE, SDLK_RETURN:
                StartNewGame(game);
              SDLK_ESCAPE:
                running := False;
            end;
          end;

          // 2. INPUT SAAT BERMAIN
          STATE_PLAYING:
          begin
            case event.key.keysym.sym of
              SDLK_p:
                TogglePause(game);
              SDLK_ESCAPE:
                TogglePause(game);

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

          // 3. INPUT SAAT JEDA (PAUSE)
          STATE_PAUSED:
          begin
            case event.key.keysym.sym of
              SDLK_p, SDLK_SPACE:
                TogglePause(game);
              SDLK_m, SDLK_ESCAPE:
                game.state := STATE_MENU;
            end;
          end;

          // 4. INPUT SAAT GAME OVER
          STATE_GAMEOVER:
          begin
            case event.key.keysym.sym of
              SDLK_SPACE, SDLK_RETURN:
                StartNewGame(game);
              SDLK_m:
                game.state := STATE_MENU;
              SDLK_ESCAPE:
                running := False;
            end;
          end;
        end;
      end;
    end;

    // Update gerakan ular setiap interval 150 ms jika sedang aktif bermain
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

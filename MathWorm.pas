program MathWorm;

uses
  SDL3,
  UTypes,
  UAudio,
  UGameLogic,
  UGameRenderer;

var
  window: PSDL_Window;
  renderer: PSDL_Renderer;
  event: TSDL_Event;
  game: TGame;
  running: Boolean;
  lastMove, currentTime: UInt64;

begin
  Randomize;

  // Inisialisasi video & audio SDL3
  if not SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO) then
  begin
    WriteLn('Error: Gagal menginisialisasi subsistem SDL3 (', SDL_GetError, ').');
    Halt(1);
  end;

  // Buat jendela aplikasi dengan ukuran baru (1024x768) dan mendukung resize
  window := SDL_CreateWindow(
    'Math Worm - Game Cacing Edukasi Matematika',
    WINDOW_WIDTH,
    WINDOW_HEIGHT,
    SDL_WINDOW_RESIZABLE
  );

  if window = nil then
  begin
    WriteLn('Error: Gagal membuat jendela SDL3 (', SDL_GetError, ').');
    SDL_Quit;
    Halt(1);
  end;

  // Tempatkan jendela di tengah layar monitor
  SDL_SetWindowPosition(window, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);

  // Buat renderer grafis
  renderer := SDL_CreateRenderer(window, nil);
  if renderer = nil then
  begin
    WriteLn('Error: Gagal membuat renderer SDL3 (', SDL_GetError, ').');
    SDL_DestroyWindow(window);
    SDL_Quit;
    Halt(1);
  end;

  // Skalakan resolusi logika internal (800x600) ke ukuran jendela (letterbox tajam)
  SDL_SetRenderLogicalPresentation(renderer, LOGICAL_WIDTH, LOGICAL_HEIGHT, SDL_LOGICAL_PRESENTATION_LETTERBOX);

  // Inisialisasi sistem audio (SFX dan musik latar)
  InitAudio;

  // Inisialisasi status awal (masuk ke Menu Utama)
  InitGame(game);

  running := True;
  lastMove := SDL_GetTicks;

  // Loop utama game
  while running do
  begin
    // Polling event input keyboard & window
    while SDL_PollEvent(@event) do
    begin
      if event.type_ = SDL_EVENT_QUIT then
        running := False;

      if event.type_ = SDL_EVENT_KEY_DOWN then
      begin
        // Tombol global kontrol musik BGM
        if event.key.key = SDLK_b then
          ToggleBGM;

        case game.state of
          // 1. INPUT PADA MENU UTAMA
          STATE_MENU:
          begin
            case event.key.key of
              SDLK_RETURN, SDLK_KP_ENTER:
                StartNewGame(game);
              SDLK_ESCAPE:
                running := False;
            end;
          end;

          // 2. INPUT SAAT BERMAIN
          STATE_PLAYING:
          begin
            case event.key.key of
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
            case event.key.key of
              SDLK_p, SDLK_RETURN, SDLK_KP_ENTER:
                TogglePause(game);
              SDLK_m, SDLK_ESCAPE:
                game.state := STATE_MENU;
            end;
          end;

          // 4. INPUT SAAT GAME OVER
          STATE_GAMEOVER:
          begin
            case event.key.key of
              SDLK_RETURN, SDLK_KP_ENTER:
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

    // Update buffer streaming audio sintesis
    UpdateAudio;

    // Render tampilan frame
    RenderGame(renderer, game);
    SDL_Delay(1);
  end;

  // Bersihkan resource audio & SDL3
  CloseAudio;
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit;
end.

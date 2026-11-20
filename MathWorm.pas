{
  MathWorm.pas
  Program utama game edukasi matematika Math Worm.
  Mengontrol inisialisasi SDL3 (video & audio), jendela, siklus utama
  permainan (event loop, update status, rendering), dan terminasi.
}
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

  if not SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO) then
  begin
    WriteLn('Error: Gagal inisialisasi SDL3 (', SDL_GetError, ').');
    Halt(1);
  end;

  window := SDL_CreateWindow(
    'Math Worm - Game Cacing Edukasi Matematika',
    WINDOW_WIDTH,
    WINDOW_HEIGHT,
    SDL_WINDOW_RESIZABLE
  );

  if window = nil then
  begin
    WriteLn('Error: Gagal membuat jendela (', SDL_GetError, ').');
    SDL_Quit;
    Halt(1);
  end;

  SDL_SetWindowPosition(window, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);

  renderer := SDL_CreateRenderer(window, nil);
  if renderer = nil then
  begin
    WriteLn('Error: Gagal membuat renderer (', SDL_GetError, ').');
    SDL_DestroyWindow(window);
    SDL_Quit;
    Halt(1);
  end;

  SDL_SetRenderLogicalPresentation(renderer, LOGICAL_WIDTH, LOGICAL_HEIGHT, SDL_LOGICAL_PRESENTATION_LETTERBOX);

  InitAudio;
  InitGame(game);

  running := True;
  lastMove := SDL_GetTicks;

  { Siklus utama game: Penanganan Event -> Update Logika -> Render Grafis }
  while running do
  begin
    while SDL_PollEvent(@event) do
    begin
      if event.type_ = SDL_EVENT_QUIT then
        running := False;

      if event.type_ = SDL_EVENT_KEY_DOWN then
      begin
        if event.key.key = SDLK_b then
          ToggleBGM;

        case game.state of
          STATE_MENU:
          begin
            case event.key.key of
              SDLK_RETURN, SDLK_KP_ENTER:
                StartNewGame(game);
              SDLK_ESCAPE:
                running := False;
            end;
          end;

          STATE_PLAYING:
          begin
            case event.key.key of
              SDLK_p, SDLK_ESCAPE:
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

          STATE_PAUSED:
          begin
            case event.key.key of
              SDLK_p, SDLK_RETURN, SDLK_KP_ENTER:
                TogglePause(game);
              SDLK_m, SDLK_ESCAPE:
                game.state := STATE_MENU;
            end;
          end;

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

    currentTime := SDL_GetTicks;
    if (game.state = STATE_PLAYING) and (currentTime - lastMove >= 150) then
    begin
      lastMove := currentTime;
      UpdateGameStep(game);
    end;

    UpdateAudio;
    RenderGame(renderer, game);
    SDL_Delay(1);
  end;

  CloseAudio;
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit;
end.

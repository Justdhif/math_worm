{ ============================================================================
  Program     : MathWorm
  Deskripsi   : Game Edukasi Cacing Matematika berbasis Pascal dan SDL2.
                Pemain mengendalikan cacing untuk memakan angka jawaban yang benar
                dari soal matematika yang ditampilkan di atas arena.
  Tugas Akhir : Pemrograman Dasar
  Arsitektur  : Modular MVC (Model-View-Controller)
  ============================================================================ }
program MathWorm;

uses
  SDL2,           { Library SDL2 untuk grafis, jendela, dan input }
  UTypes,         { Konstanta, record data, dan fungsi utilitas }
  UGameLogic,     { Logika pergerakan cacing, tabrakan, dan aturan game }
  UGameRenderer;  { Seluruh proses penggambaran visual grafis ke layar }

var
  { Variabel pointer utama SDL2 }
  window: PSDL_Window;        { Pointer ke jendela aplikasi Windows }
  renderer: PSDL_Renderer;    { Pointer ke mesin rendering grafis (GPU/Direct3D) }
  event: TSDL_Event;          { Struktur penampung event input (keyboard, mouse, window) }

  { Variabel status dunia game }
  game: TGame;                { Record lengkap penyimpan data game }
  running: Boolean;           { Status apakah program game masih berjalan }

  { Variabel pengatur waktu (Timer Loop) }
  lastMove: UInt32;           { Waktu dalam milidetik saat cacing terakhir bergerak }
  currentTime: UInt32;        { Waktu saat ini dalam milidetik }

begin
  { Inisialisasi generator bilangan acak bawaan Pascal }
  Randomize;

  { --------------------------------------------------------------------------
    1. INISIALISASI SUBSISTEM SDL2 (Video & Input)
    -------------------------------------------------------------------------- }
  if SDL_Init(SDL_INIT_VIDEO) < 0 then
  begin
    WriteLn('Error: Gagal menginisialisasi subsistem video SDL2.');
    Halt(1);
  end;

  { --------------------------------------------------------------------------
    2. MEMBUAT JENDELA APLIKASI (Window)
    -------------------------------------------------------------------------- }
  window := SDL_CreateWindow(
    'Math Worm - Game Cacing Edukasi Matematika',
    SDL_WINDOWPOS_CENTERED,  { Posisi horizontal di tengah monitor }
    SDL_WINDOWPOS_CENTERED,  { Posisi vertikal di tengah monitor }
    WINDOW_WIDTH,            { Lebar jendela: 800 piksel }
    WINDOW_HEIGHT,           { Tinggi jendela: 600 piksel }
    SDL_WINDOW_SHOWN         { Tampilkan jendela langsung ke layar }
  );

  if window = nil then
  begin
    WriteLn('Error: Gagal membuat jendela SDL2.');
    SDL_Quit;
    Halt(1);
  end;

  { --------------------------------------------------------------------------
    3. MEMBUAT RENDERER GRAFIS (Hardware Accelerated)
    -------------------------------------------------------------------------- }
  renderer := SDL_CreateRenderer(
    window,
    -1, { Pilih driver grafis pertama yang cocok }
    SDL_RENDERER_ACCELERATED { Menggunakan akselerasi GPU agar grafis mulus }
  );

  if renderer = nil then
  begin
    WriteLn('Error: Gagal membuat renderer SDL2.');
    SDL_DestroyWindow(window);
    SDL_Quit;
    Halt(1);
  end;

  { --------------------------------------------------------------------------
    4. PERSIAPAN AWAL DUNIA PERMAINAN
    -------------------------------------------------------------------------- }
  InitGame(game); { Inisialisasi posisi ular, nyawa, skor, dan soal awal }

  running := True;
  lastMove := SDL_GetTicks; { Catat milidetik awal }

  { --------------------------------------------------------------------------
    5. GAME LOOP UTAMA
    Looping terus berjalan selama variabel running bernilai True.
    -------------------------------------------------------------------------- }
  while running do
  begin
    { A. MENANGANI EVENT INPUT (Keyboard & Window) }
    while SDL_PollEvent(@event) = 1 do
    begin
      { Jika tombol silang merah jendela (X) diklik }
      if event.type_ = Cardinal(SDL_QUITEV) then
        running := False;

      { Jika ada tombol keyboard yang ditekan }
      if event.type_ = SDL_KEYDOWN then
      begin
        case event.key.keysym.sym of
          { Tombol ESC: Keluar dari game kapan saja }
          SDLK_ESCAPE:
            running := False;

          { Tombol SPASI atau ENTER: Restart game saat layar Game Over }
          SDLK_SPACE, SDLK_RETURN:
            if game.state = STATE_GAMEOVER then
              InitGame(game);

          { Kontrol Belok Atas (Panah Atas atau W) }
          SDLK_UP, SDLK_w:
            ChangeDirection(game, 0, -CELL_SIZE);

          { Kontrol Belok Bawah (Panah Bawah atau S) }
          SDLK_DOWN, SDLK_s:
            ChangeDirection(game, 0, CELL_SIZE);

          { Kontrol Belok Kiri (Panah Kiri atau A) }
          SDLK_LEFT, SDLK_a:
            ChangeDirection(game, -CELL_SIZE, 0);

          { Kontrol Belok Kanan (Panah Kanan atau D) }
          SDLK_RIGHT, SDLK_d:
            ChangeDirection(game, CELL_SIZE, 0);
        end;
      end;
    end;

    { B. LOGIKA WAKTU DAN PERGERAKAN (Tick Timer) }
    currentTime := SDL_GetTicks;

    { Cacing melangkah 1 petak setiap 150 milidetik jika masih bermain }
    if (game.state = STATE_PLAYING) and (currentTime - lastMove >= 150) then
    begin
      lastMove := currentTime;
      UpdateGameStep(game); { Update langkah, tabrakan, dan makanan }
    end;

    { C. MENGGAMBAR TAMPILAN KE LAYAR (Rendering) }
    RenderGame(renderer, game);

    { Beri jeda kecil 1 ms agar pemakaian CPU tidak 100% }
    SDL_Delay(1);
  end;

  { --------------------------------------------------------------------------
    6. MEMBERSIHKAN MEMORI DAN KELUAR (Clean Up)
    -------------------------------------------------------------------------- }
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit;
end.

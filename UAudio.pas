unit UAudio;

interface

uses
  SDL3, Math;

type
  TSFXType = (
    SFX_NONE,
    SFX_START,
    SFX_CORRECT,
    SFX_WRONG,
    SFX_PAUSE,
    SFX_GAMEOVER
  );

// Inisialisasi dan penutupan sistem audio
function InitAudio: Boolean;
procedure CloseAudio;

// Update buffer audio (dipanggil di game loop utama)
procedure UpdateAudio;

// Kontrol efek suara (SFX)
procedure PlaySFX(sfx: TSFXType);

// Kontrol musik latar (BGM)
procedure SetBGMEnabled(enabled: Boolean);
function IsBGMEnabled: Boolean;
procedure ToggleBGM;

// Kontrol mute seluruh audio (SFX + BGM)
procedure SetAudioMuted(muted: Boolean);
function IsAudioMuted: Boolean;
procedure ToggleAudioMute;

implementation

const
  SAMPLE_RATE = 44100;
  CHUNK_SAMPLES = 1024;
  TARGET_QUEUED_BYTES = 8820; // ~100 ms audio buffer

  // Nada melodi BGM (Frekuensi Hz)
  BGM_STEPS = 32;
  BGM_STEP_SAMPLES = 5292; // ~120 ms per step (tempo 125 BPM)

  // Tabel frekuensi melodi BGM (Channel 1: Lead)
  MELODY_PITCH: array[0..BGM_STEPS - 1] of Single = (
    523.25,      0, 392.00,      0, 440.00, 493.88, 523.25,      0,
    587.33, 659.25, 587.33,      0, 392.00,      0, 493.88,      0,
    523.25,      0, 392.00,      0, 440.00, 493.88, 523.25,      0,
    659.25,      0, 587.33,      0, 523.25,      0,      0,      0
  );

  // Tabel frekuensi bassline BGM (Channel 2: Bass)
  BASS_PITCH: array[0..BGM_STEPS - 1] of Single = (
    130.81, 130.81, 196.00, 196.00, 174.61, 174.61, 174.61, 174.61,
    196.00, 196.00, 196.00, 196.00, 196.00, 196.00, 246.94, 246.94,
    130.81, 130.81, 196.00, 196.00, 174.61, 174.61, 174.61, 174.61,
    196.00, 196.00, 196.00, 196.00, 130.81, 130.81, 130.81, 130.81
  );

var
  audioStream: PSDL_AudioStream = nil;
  audioReady: Boolean = False;
  audioMuted: Boolean = False;
  bgmEnabled: Boolean = True;

  // Status sintesis BGM
  bgmSamplePos: Int64 = 0;
  bgmLeadPhase: Single = 0.0;
  bgmBassPhase: Single = 0.0;

  // Status sintesis SFX
  activeSFX: TSFXType = SFX_NONE;
  sfxSamplePos: Integer = 0;
  sfxTotalSamples: Integer = 0;
  sfxPhase: Single = 0.0;

// Memulai sistem audio SDL3
function InitAudio: Boolean;
var
  spec: TSDL_AudioSpec;
begin
  if audioReady then
  begin
    InitAudio := True;
    Exit;
  end;

  spec.format := SDL_AUDIO_S16LE;
  spec.channels := 1;
  spec.freq := SAMPLE_RATE;

  audioStream := SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, @spec, nil, nil);
  if audioStream = nil then
  begin
    WriteLn('Peringatan: Gagal membuka audio device (', SDL_GetError, '). Game berjalan tanpa suara.');
    audioReady := False;
    InitAudio := False;
    Exit;
  end;

  SDL_ResumeAudioStreamDevice(audioStream);
  audioReady := True;
  audioMuted := False;
  bgmEnabled := True;
  InitAudio := True;
end;

// Menutup sistem audio
procedure CloseAudio;
begin
  if audioStream <> nil then
  begin
    SDL_DestroyAudioStream(audioStream);
    audioStream := nil;
  end;
  audioReady := False;
end;

// Memicu efek suara baru
procedure PlaySFX(sfx: TSFXType);
begin
  if (not audioReady) or audioMuted then Exit;

  activeSFX := sfx;
  sfxSamplePos := 0;
  sfxPhase := 0.0;

  case sfx of
    SFX_START:
      sfxTotalSamples := 8000;    // ~180 ms
    SFX_CORRECT:
      sfxTotalSamples := 8500;    // ~190 ms
    SFX_WRONG:
      sfxTotalSamples := 10000;   // ~225 ms
    SFX_PAUSE:
      sfxTotalSamples := 4000;    // ~90 ms
    SFX_GAMEOVER:
      sfxTotalSamples := 28000;   // ~635 ms
    else
      sfxTotalSamples := 0;
  end;
end;

procedure SetBGMEnabled(enabled: Boolean);
begin
  bgmEnabled := enabled;
end;

function IsBGMEnabled: Boolean;
begin
  IsBGMEnabled := bgmEnabled;
end;

procedure ToggleBGM;
begin
  bgmEnabled := not bgmEnabled;
end;

procedure SetAudioMuted(muted: Boolean);
begin
  audioMuted := muted;
end;

function IsAudioMuted: Boolean;
begin
  IsAudioMuted := audioMuted;
end;

procedure ToggleAudioMute;
begin
  audioMuted := not audioMuted;
end;

// Menghasilkan sample SFX berdasarkan status efek suara aktif
function GenerateSFXSample: Integer;
var
  freq, amp: Single;
  val: Integer;
begin
  if activeSFX = SFX_NONE then
  begin
    GenerateSFXSample := 0;
    Exit;
  end;

  freq := 0;
  amp := 0;

  case activeSFX of
    SFX_START:
    begin
      amp := 4500;
      if sfxSamplePos < 2500 then
        freq := 392.00 // G4
      else if sfxSamplePos < 5000 then
        freq := 523.25 // C5
      else
        freq := 659.25; // E5
      // Decay lembut di ujung nada
      amp := amp * (1.0 - (sfxSamplePos / sfxTotalSamples) * 0.4);
    end;

    SFX_CORRECT:
    begin
      // Arpeggio nada tinggi C5 -> E5 -> G5
      amp := 5500;
      if sfxSamplePos < 2500 then
        freq := 523.25 // C5
      else if sfxSamplePos < 5000 then
        freq := 659.25 // E5
      else
        freq := 783.99; // G5
      amp := amp * (1.0 - (sfxSamplePos / sfxTotalSamples) * 0.5);
    end;

    SFX_WRONG:
    begin
      // Nada rendah meluncur ke bawah (pitch drop)
      amp := 5500;
      freq := 170.0 - 90.0 * (sfxSamplePos / sfxTotalSamples);
      amp := amp * (1.0 - (sfxSamplePos / sfxTotalSamples) * 0.6);
    end;

    SFX_PAUSE:
    begin
      amp := 4000;
      if sfxSamplePos < 2000 then
        freq := 440.00
      else
        freq := 880.00;
      amp := amp * (1.0 - (sfxSamplePos / sfxTotalSamples) * 0.5);
    end;

    SFX_GAMEOVER:
    begin
      amp := 5000;
      if sfxSamplePos < 7000 then
        freq := 440.00  // A4
      else if sfxSamplePos < 14000 then
        freq := 392.00  // G4
      else if sfxSamplePos < 21000 then
        freq := 349.23  // F4
      else
        freq := 261.63; // C4
      amp := amp * (1.0 - (sfxSamplePos / sfxTotalSamples) * 0.6);
    end;
  end;

  // Sintesis gelombang kotak (Square wave)
  sfxPhase := sfxPhase + (freq / SAMPLE_RATE);
  if sfxPhase >= 1.0 then
    sfxPhase := sfxPhase - Trunc(sfxPhase);

  if sfxPhase < 0.5 then
    val := Round(amp)
  else
    val := -Round(amp);

  Inc(sfxSamplePos);
  if sfxSamplePos >= sfxTotalSamples then
    activeSFX := SFX_NONE;

  GenerateSFXSample := val;
end;

// Menghasilkan sample BGM retro chiptune (Lead + Bass)
function GenerateBGMSample: Integer;
var
  stepIdx, stepSample: Integer;
  leadFreq, bassFreq: Single;
  leadAmp, bassAmp: Single;
  leadVal, bassVal: Integer;
begin
  if not bgmEnabled then
  begin
    GenerateBGMSample := 0;
    Exit;
  end;

  // Posisi step dalam loop melodi
  stepIdx := (bgmSamplePos div BGM_STEP_SAMPLES) mod BGM_STEPS;
  stepSample := bgmSamplePos mod BGM_STEP_SAMPLES;

  leadFreq := MELODY_PITCH[stepIdx];
  bassFreq := BASS_PITCH[stepIdx];

  // Channel 1: Melodi Utama (Square wave 25% duty cycle agar berkarakter NES)
  if leadFreq > 10 then
  begin
    leadAmp := 2400.0 * (1.0 - (stepSample / BGM_STEP_SAMPLES) * 0.65);
    bgmLeadPhase := bgmLeadPhase + (leadFreq / SAMPLE_RATE);
    if bgmLeadPhase >= 1.0 then
      bgmLeadPhase := bgmLeadPhase - Trunc(bgmLeadPhase);

    if bgmLeadPhase < 0.25 then
      leadVal := Round(leadAmp)
    else
      leadVal := -Round(leadAmp * 0.5);
  end
  else
    leadVal := 0;

  // Channel 2: Bassline Pengiring (Triangle/Saw wave halus)
  if bassFreq > 10 then
  begin
    bassAmp := 2000.0 * (1.0 - (stepSample / BGM_STEP_SAMPLES) * 0.4);
    bgmBassPhase := bgmBassPhase + (bassFreq / SAMPLE_RATE);
    if bgmBassPhase >= 1.0 then
      bgmBassPhase := bgmBassPhase - Trunc(bgmBassPhase);

    // Gelombang segitiga (triangle wave)
    if bgmBassPhase < 0.5 then
      bassVal := Round(bassAmp * (4.0 * bgmBassPhase - 1.0))
    else
      bassVal := Round(bassAmp * (3.0 - 4.0 * bgmBassPhase));
  end
  else
    bassVal := 0;

  Inc(bgmSamplePos);
  GenerateBGMSample := leadVal + bassVal;
end;

// Mengisi buffer audio secara berkelanjutan
procedure UpdateAudio;
var
  queued: Integer;
  buffer: array[0..CHUNK_SAMPLES - 1] of SmallInt;
  i: Integer;
  bgmSample, sfxSample, mixed: Integer;
begin
  if (not audioReady) or (audioStream = nil) then Exit;

  queued := SDL_GetAudioStreamQueued(audioStream);
  // Isi buffer jika tersisa kurang dari batas target antrean
  while queued < TARGET_QUEUED_BYTES do
  begin
    for i := 0 to CHUNK_SAMPLES - 1 do
    begin
      if audioMuted then
        buffer[i] := 0
      else
      begin
        bgmSample := GenerateBGMSample;
        sfxSample := GenerateSFXSample;
        mixed := bgmSample + sfxSample;

        // Clamping agar tidak terjadi audio clipping
        if mixed > 32000 then mixed := 32000
        else if mixed < -32000 then mixed := -32000;

        buffer[i] := SmallInt(mixed);
      end;
    end;

    SDL_PutAudioStreamData(audioStream, @buffer[0], SizeOf(buffer));
    queued := queued + SizeOf(buffer);
  end;
end;

end.

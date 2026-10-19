{ ============================================================================
  Unit        : UMathEngine
  Deskripsi   : Modul generator soal matematika (+, -, *, /) serta pembentuk
                pilihan jawaban (jawaban benar & jawaban pengecoh yang unik).
  Tugas Akhir : Pemrograman Dasar
  ============================================================================ }
unit UMathEngine;

interface

uses
  Math, UTypes;

{ Struktur data lengkap untuk satu paket soal matematika }
type
  TMathQuestion = record
    op1, op2: Integer;                          { Operan 1 dan Operan 2 (misal: 12 dan 5) }
    opChar: Char;                               { Simbol operasi: '+', '-', 'X', ':' }
    correctAnswer: Integer;                     { Nilai hasil perhitungan yang benar }
    numChoices: Integer;                        { Jumlah pilihan jawaban (3 atau 4) }
    choices: array[0..MAX_FOODS - 1] of Integer;{ Nilai angka untuk masing-masing pilihan }
    correctChoiceIndex: Integer;                { Indeks posisi jawaban yang benar (0..numChoices-1) }
  end;

{ Menghasilkan paket soal baru beserta pilihan jawaban yang sudah teracak }
procedure GenerateNewMathQuestion(var q: TMathQuestion);

implementation

procedure GenerateNewMathQuestion(var q: TMathQuestion);
var
  opType: Integer;
  k, m: Integer;
  delta, fake: Integer;
  isUnique: Boolean;
begin
  { --------------------------------------------------------------------------
    Langkah 1: Pilih operasi hitung secara acak (0 s/d 3)
    0 = Penjumlahan, 1 = Pengurangan, 2 = Perkalian, 3 = Pembagian
    Semua operasi dirancang menghasilkan bilangan bulat positif <= 99.
    -------------------------------------------------------------------------- }
  opType := Random(4);

  case opType of
    0: { PENJUMLAHAN (+) }
    begin
      q.op1 := 1 + Random(45);
      q.op2 := 1 + Random(45);
      q.correctAnswer := q.op1 + q.op2;
      q.opChar := '+';
    end;

    1: { PENGURANGAN (-) }
    begin
      { op1 berkisar 6..55, op2 lebih kecil dari op1 sehingga hasil selalu positif }
      q.op1 := 6 + Random(50);
      q.op2 := 1 + Random(q.op1 - 1);
      q.correctAnswer := q.op1 - q.op2;
      q.opChar := '-';
    end;

    2: { PERKALIAN (X) }
    begin
      { Faktor 2..10 sehingga hasil perkalian maksimal 10x10 = 100 }
      q.op1 := 2 + Random(9);
      q.op2 := 2 + Random(9);
      q.correctAnswer := q.op1 * q.op2;
      q.opChar := 'X';
    end;

    3: { PEMBAGIAN (:) }
    begin
      { Menghasilkan pembagian bulat tanpa sisa / desimal:
        op2 = pembagi, correctAnswer = hasil bagi, op1 = op2 * hasil }
      q.op2 := 2 + Random(8);           { Pembagi: 2..9 }
      q.correctAnswer := 1 + Random(10);{ Hasil bagi: 1..10 }
      q.op1 := q.op2 * q.correctAnswer; { Angka yang dibagi: 2..90 }
      q.opChar := ':';
    end;
  end;

  { --------------------------------------------------------------------------
    Langkah 2: Tentukan jumlah pilihan jawaban di arena (acak antara 3 atau 4)
    -------------------------------------------------------------------------- }
  q.numChoices := 3 + Random(2);

  { Pilih salah satu slot indeks secara acak untuk menaruh jawaban yang benar }
  q.correctChoiceIndex := Random(q.numChoices);

  { --------------------------------------------------------------------------
    Langkah 3: Buat nilai untuk setiap slot pilihan makanan
    - Slot jawaban benar diisi correctAnswer.
    - Slot lainnya diisi jawaban pengecoh yang nilainya mendekati jawaban benar,
      berada pada rentang 0..99, dan dipastikan unik (tidak ada angka kembar).
    -------------------------------------------------------------------------- }
  for k := 0 to q.numChoices - 1 do
  begin
    if k = q.correctChoiceIndex then
      q.choices[k] := q.correctAnswer
    else
    begin
      repeat
        { Buat selisih acak antara -7 sampai +7 (hindari 0) }
        delta := Random(15) - 7;
        if delta = 0 then delta := 1 + Random(3);

        fake := q.correctAnswer + delta;

        { Pastikan angka tidak negatif dan tidak melebihi 99 }
        if fake < 0 then fake := q.correctAnswer + Abs(delta) + 1;
        if fake > 99 then fake := q.correctAnswer - Abs(delta) - 1;

        { Periksa apakah angka ini unik dan belum pernah dipakai di slot sebelumnya }
        isUnique := (fake <> q.correctAnswer);
        if isUnique then
        begin
          for m := 0 to k - 1 do
            if q.choices[m] = fake then isUnique := False;
        end;
      until isUnique;

      q.choices[k] := fake;
    end;
  end;
end;

end.

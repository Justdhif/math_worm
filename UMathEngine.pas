unit UMathEngine;

interface

uses
  Math, UTypes;

type
  TMathQuestion = record
    op1, op2: Integer;
    opChar: Char;
    correctAnswer: Integer;
    numChoices: Integer;
    choices: array[0..MAX_FOODS - 1] of Integer;
    correctChoiceIndex: Integer;
  end;

// Membuat soal baru dan mengacak opsi jawaban
procedure GenerateNewMathQuestion(var q: TMathQuestion);

implementation

procedure GenerateNewMathQuestion(var q: TMathQuestion);
var
  opType: Integer;
  k, m: Integer;
  delta, fake: Integer;
  isUnique: Boolean;
begin
  // Pilih operasi: 0 = +, 1 = -, 2 = X, 3 = :
  opType := Random(4);

  case opType of
    0: // Penjumlahan
    begin
      q.op1 := 1 + Random(45);
      q.op2 := 1 + Random(45);
      q.correctAnswer := q.op1 + q.op2;
      q.opChar := '+';
    end;

    1: // Pengurangan (hasil selalu positif)
    begin
      q.op1 := 6 + Random(50);
      q.op2 := 1 + Random(q.op1 - 1);
      q.correctAnswer := q.op1 - q.op2;
      q.opChar := '-';
    end;

    2: // Perkalian
    begin
      q.op1 := 2 + Random(9);
      q.op2 := 2 + Random(9);
      q.correctAnswer := q.op1 * q.op2;
      q.opChar := 'X';
    end;

    3: // Pembagian (pembagian bulat tanpa sisa)
    begin
      q.op2 := 2 + Random(8);
      q.correctAnswer := 1 + Random(10);
      q.op1 := q.op2 * q.correctAnswer;
      q.opChar := ':';
    end;
  end;

  // Acak jumlah pilihan di arena (3 atau 4)
  q.numChoices := 3 + Random(2);
  q.correctChoiceIndex := Random(q.numChoices);

  // Buat nilai jawaban benar dan pengecoh yang unik
  for k := 0 to q.numChoices - 1 do
  begin
    if k = q.correctChoiceIndex then
      q.choices[k] := q.correctAnswer
    else
    begin
      repeat
        delta := Random(15) - 7;
        if delta = 0 then delta := 1 + Random(3);

        fake := q.correctAnswer + delta;
        if fake < 0 then fake := q.correctAnswer + Abs(delta) + 1;
        if fake > 99 then fake := q.correctAnswer - Abs(delta) - 1;

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

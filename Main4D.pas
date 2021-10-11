unit Main4D;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Menus, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Game1: TMenuItem;
    Quit1: TMenuItem;
    SB1: TStatusBar;
    NewGame1: TMenuItem;
    Image1: TImage;
    Deal: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Undo1: TMenuItem;
    Contens1: TMenuItem;
    N3: TMenuItem;
    procedure Quit1Click(Sender: TObject);
    procedure NewGame1Click(Sender: TObject);
    procedure Form1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Form1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Form1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure DealClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure Contens1Click(Sender: TObject);
  private
   //  procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
  public
    { Public declarations }

  end;

(*
     Diamonds - Бубны
     Hearts   - Черви
     Clubs    - Крести
     Spades   - Пики
*)
  Suits = (Diamonds,Hearts,Spades,Clubs);

  CPack = record   { Описание карты }
    Suit : Suits; { Масти }
    Card : Byte;  { Величина карты }
    BPos : Byte;  { Поз. карты в колоде }
   end;

  XY = record
     X : Integer;
     Y : Integer;
     B : Boolean;
  end;

const
   { Координаты позиции карт на экране }
  _PosC : array[1..4,1..9] of TPoint =
         (((x:0;y:0),  (x:70;y:0),  (x:140;y:0),  (x:210;y:0),  (x:280;y:0),  (x:350;y:0),  (x:420;y:0),  (x:490;y:0),  (x:560;y:0)),
          ((x:0;y:95), (x:70;y:95), (x:140;y:95), (x:210;y:95), (x:280;y:95), (x:350;y:95), (x:420;y:95), (x:490;y:95), (x:560;y:95)),
          ((x:0;y:190),(x:70;y:190),(x:140;y:190),(x:210;y:190),(x:280;y:190),(x:350;y:190),(x:420;y:190),(x:490;y:190),(x:560;y:190)),
          ((x:0;y:285),(x:70;y:285),(x:140;y:285),(x:210;y:285),(x:280;y:285),(x:350;y:285),(x:420;y:285),(x:490;y:285),(x:560;y:285)));
   BitmapName : array[0..35] of ShortString =
                ('B1_6','B2_7','B3_8','B4_9','B5_10','B6_J','B7_Q','B8_K','B9_A',
                 'C1_6','C2_7','C3_8','C4_9','C5_10','C6_J','C7_Q','C8_K','C9_A',
                 'P1_6','P2_7','P3_8','P4_9','P5_10','P6_J','P7_Q','P8_K','P9_A',
                 'T1_6','T2_7','T3_8','T4_9','T5_10','T6_J','T7_Q','T8_K','T9_A');
   HCard      : Byte = 96; { Высота карты }
   WCard      : Byte = 71; { Ширина карты }

var
  Form1      : TForm1;
  Pack       : array[1..4,1..9] of CPack; // Колода
  Lines      : array[1..4] of Byte;       // Длина "дорожки"
  TCards     : array[0..35] of CPack;
  Attempt    : Byte;    // Счетчик попыток
  Drag       : Boolean; // Потащили карту???
  CBitmap    : TBitmap;
  Background,
  Card       : TRect;
  OPX,OPY    : Integer;  // Предыдущие координаты при перемещении
  OSX,OSY    : Integer;  // Сдвиг координат относительно мыши
  SPX,SPY    : Integer;  // Начало старта
  UnX1,UnX2,
  UnY1,UnY2  : Byte;
  _Pos : array[1..4,1..9] of TPoint;

procedure Convert(var X,Y:Integer);
procedure CheckStatus;
procedure Delay(MSecond : LongWord);
function  CheckPos(X,Y : Integer) : Boolean;

implementation

{$R *.DFM}

procedure Delay(MSecond : LongWord);
var
  StartValue, CurrentValue: LongWord;
begin
  if MSecond <= 0 then Exit;
                           //Слегонца подкорректируем значение
  MSecond := MSecond * 10; //чтобы не задавать огромные числа во
                           //входных параметрах
  StartValue := GetTickCount;
  repeat
    CurrentValue := GetTickCount;
  until CurrentValue >= StartValue+MSecond;
end;

procedure TForm1.Quit1Click(Sender: TObject);
begin
   Close;
end;

procedure TForm1.NewGame1Click(Sender: TObject);
const
  SuitOfCard : array[1..4] of Suits = (Diamonds,Hearts,Spades,Clubs);
var
  Card    : CPack;
  Bitmap1 : TBitmap;
  I       : Word;
  X,Y     : Byte;
begin
  for Y:=1 to 4 do //Очищаем стол
    for X:=1 to 9 do
      //Затираем карту фоном
      Form1.Canvas.RoundRect(_Pos[Y,X].X,_Pos[Y,X].Y,_Pos[Y,X].X+WCard,_Pos[Y,X].Y+HCard,6,6);
  // Подготавливаем колоду}
  for Y:=1 to 4 do
    for X:=1 to 9 do
    begin
      Pack[Y,X].Suit:=SuitOfCard[Y]; { Простановка масти }
      Pack[Y,X].Card:=X;             { Простановка значения карты }
      Pack[Y,X].BPos:=(Y-1)*9+(X-1);   { \                          }
      TCards[(Y-1)*9+(X-1)]:=Pack[Y,X];  { Заполнение вспом. массива  }
    end;
  Attempt:=1; { Первая попытка }
  SB1.Panels[1].Text := 'Первая попытка';
  Deal.Enabled := TRUE;
  Undo1.Enabled := FALSE;
  SB1.Panels[0].Text := 'Нажмите F3 чтобы перетасовать оставшиеся карты';
  { Тасуем колоду }
  Randomize;
  for I:=1 to 2000 do
  begin
    repeat
       X:=Random(36);
       Y:=Random(36);
    until X<>Y;
    Card:=TCards[X];
    TCards[X]:=TCards[Y];
    TCards[Y]:=Card;
  end;

  { Выкладываем карты }
  for Y:=1 to 4 do
   for X:=1 to 9 do
   begin
     Bitmap1 := TBitmap.Create;
     Pack[Y,X]:=TCards[(Y-1)*9+(X-1)];
     Bitmap1.LoadFromResourceName(hInstance, BitmapName[Pack[Y,X].BPos]);
     Form1.Canvas.Draw(_Pos[Y,X].X,_Pos[Y,X].Y,Bitmap1);
     Bitmap1.Free;
     Delay(2);
   end;
  CheckStatus;
  SB1.Panels[2].Text := 'Осталось карт :' + IntToStr(32 - (Lines[1]+Lines[2]+Lines[3]+Lines[4]));
  Delay(30);
 { Удаляем тузы и обновляем колоду}
  for Y:=1 to 4 do
    for X:=1 to 9 do
      if TCards[(Y-1)*9+(X-1)].Card = 9 then
      begin
        Pack[Y,X].Card:=0;              { Пусто }
        //Затираем карту фоном
        Form1.Canvas.RoundRect(_Pos[Y,X].X,_Pos[Y,X].Y,_Pos[Y,X].X+WCard,_Pos[Y,X].Y+HCard,6,6);
      end else Pack[Y,X]:=TCards[(Y-1)*9+(X-1)];
end;

function CheckPos(X,Y : Integer) : Boolean;
begin
  if ((X > 20) AND (X < 651)) AND ((Y > 20) AND (Y < 401))
   then CheckPos := TRUE
   else CheckPos := FALSE;
end;

Procedure Convert(var X,Y:Integer);
Var
 X1,Y1 : Integer;
begin
  for Y1 := 1 to 4 do
    if (_Pos[Y1,1].Y+1 <= Y) AND (Y < _Pos[Y1,1].Y+HCard+1) then Break;
  for X1 := 1 to 9 do
    if (_Pos[1,X1].X+1 <= X) AND (X < _Pos[1,X1].X+WCard+1) then Break;
  X:=X1;
  Y:=Y1
end;

procedure TForm1.Form1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Dest, Source: TRect;
begin
  if Not Drag then Exit;
  if ((X < 0) OR (Y < 0) OR (X > 670) OR (Y > 440)) then Exit;//Не даём карте полностью уйти за пределы окна
  X := X-OSX;
  Y := Y-OSY;
  Form1.Canvas.CopyMode := cmSrcCopy;
  if OPY <= Y then
  begin
   Dest   := Rect(OPX,OPY,OPX+WCard,Y); // Определяем зону копирования для источника
   Source := Rect(OPX,OPY,OPX+WCard,Y); // Определяем зону копирования для приемника}
  end else
  begin
   Dest   := Rect(OPX,Y+HCard,OPX+WCard,OPY+HCard); // Определяем зону копирования для источника
   Source := Rect(OPX,Y+HCard,OPX+WCard,OPY+HCard); // Определяем зону копирования для приемника}
  end;
  Form1.Canvas.CopyRect(Dest,Image1.Canvas,Source);
  if OPX <= X then
  begin
   Dest   := Rect(OPX,OPY,X,OPY+HCard); // Определяем зону копирования для источника
   Source := Rect(OPX,OPY,X,OPY+HCard); // Определяем зону копирования для приемника}
  end else
  begin
   Dest   := Rect(X+WCard,OPY,OPX+WCard,OPY+HCard); // Определяем зону копирования для источника
   Source := Rect(X+WCard,OPY,OPX+WCard,OPY+HCard); // Определяем зону копирования для приемника}
  end;
  Form1.Canvas.CopyRect(Dest,Image1.Canvas,Source);
  Form1.Canvas.Draw(X,Y,CBitmap);
  OPX := X;
  OPY := Y;
end;

procedure TForm1.Form1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Dest, Source: TRect;
begin
  Image1.Canvas.CopyMode := cmSrcCopy; //Обычная отрисовка при копировании
  Dest   := Rect(0,0,Image1.Width,Image1.Height); // Определяем зону копирования для источника
  Source := Rect(0,0,Image1.Width,Image1.Height); // Определяем зону копирования для приемника
  {Впредь использовать Image для этих целей. PaintBox глючит, по крайней мере у меня}
  Image1.Canvas.CopyRect(Dest,Form1.Canvas,Source); //Скопируем состояние стола перед перемещением для востановления фона
  OSX := X;
  OSY := Y;
  Drag:=FALSE;
  if NOT CheckPos(X,Y) then Exit;
  Convert(X, Y);  // Переводим координаты к виду 1..9,1..4
  SPX := X; // Запомним, если придётся возвертаться
  SPY := Y;
  if Pack[Y,X].Card = 0 then Exit; //Если тута пуста
  Drag:=TRUE; //Кнопка нажата
  OSX := OSX - _Pos[Y,X].X; //Вычисление сдвига
  OSY := OSY - _Pos[Y,X].Y;
  CBitmap := TBitmap.Create;
  CBitmap.LoadFromResourceName(hInstance, BitmapName[Pack[Y,X].BPos]); // Загружаем изоб. карты
  //Затираем карту фоном
  Form1.Canvas.RoundRect(_Pos[Y,X].X,_Pos[Y,X].Y,_Pos[Y,X].X+WCard,_Pos[Y,X].Y+HCard,6,6);
  //Впредь использовать Image для этих целей. PaintBox глючит, по крайней мере у меня
  Image1.Canvas.CopyRect(Dest,Form1.Canvas,Source); //Скопируем состояние стола перед перемещением для востановления фона
  Form1.Canvas.Draw(_Pos[Y,X].X,_Pos[Y,X].Y,CBitmap); //Поехали! Первая отрисовка карты
  OPX := _Pos[Y,X].X;
  OPY := _Pos[Y,X].Y;
end;

procedure TForm1.Form1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Dest, Source     : TRect;
  OneMoreCondition : Boolean; // Хоть одно условие выполняется ?
  Vr1              : Word;
  Bitmap           : TBitmap;
  Crd              : array[0..4] of XY;
  BRes1            : Boolean;
begin
  OneMoreCondition := CheckPos(X,Y);   //Курсор в пределах окна программы ?
  if OneMoreCondition then    //Если да вычисляем координаты всех углов карты
  begin                       //и проверяем виден ли угол в окне
    Crd[0].B := TRUE;
    Crd[0].X := X;
    Crd[0].Y := Y;
  end else Crd[0].B := FALSE;
  // OSX,OSY  cдвиг координат относительно мыши
  OneMoreCondition := CheckPos(X-OSX,Y-OSY);
  if OneMoreCondition then
  begin
    Crd[1].B := TRUE;
    Crd[1].X := X-OSX;
    Crd[1].Y := Y-OSY;
  end else Crd[1].B := FALSE;
  OneMoreCondition := CheckPos(X-OSX,Y-OSY+HCard);
  if OneMoreCondition then
  begin
    Crd[2].B := TRUE;
    Crd[2].X := X-OSX;
    Crd[2].Y := Y-OSY+HCard;
  end else Crd[2].B := FALSE;
  OneMoreCondition := CheckPos(X-OSX+WCard,Y-OSY);
  if OneMoreCondition then
  begin
    Crd[3].B := TRUE;
    Crd[3].X := X-OSX+WCard;
    Crd[3].Y := Y-OSY;
  end else Crd[3].B := FALSE;
  OneMoreCondition := CheckPos(X-OSX+WCard,Y-OSY+HCard);
  if OneMoreCondition then
  begin
    Crd[4].B := TRUE;
    Crd[4].X := X-OSX+WCard;
    Crd[4].Y := Y-OSY+HCard;
  end else Crd[4].B := FALSE;
  if NOT Drag then Exit;
  OneMoreCondition := FALSE;
  X := Crd[0].X;
  Y := Crd[0].Y;
  for Vr1 := 0 to 4 do
    if Crd[Vr1].B then
    begin
      Convert(Crd[Vr1].X, Crd[Vr1].Y);  // Переводим координаты к виду 1..9,1..4
      if Pack[Crd[Vr1].Y,Crd[Vr1].X].Card = 0 then   //Определяем, попадает ли карта
      begin                                          //каким-нибудь углом в свободную ячейку
        X := Crd[Vr1].X;
        Y := Crd[Vr1].Y;
        OneMoreCondition := TRUE;     //Попадает!
        Break;
      end;
    end;
  if NOT OneMoreCondition then Convert(X, Y);
  Dest   := Rect(0,0,Image1.Width,Image1.Height); // Определяем зону копирования для источника
  Source := Rect(0,0,Image1.Width,Image1.Height); // Определяем зону копирования для приемника
  Form1.Canvas.CopyRect(Dest,Image1.Canvas,Source); // Востанавливаем фон

  // ЭТУ карту можно положить в ЭТУ ячейку ?
  BRes1 := (Pack[Y,X].Card = 0) AND OneMoreCondition;
  if X > 1 then  //Два свободных поля не идут подряд?
      BRes1 := BRes1  AND (Pack[Y,X-1].Card <> 0);
  if X = 1 then  //Если первая ячейка
      BRes1 := BRes1  AND (Pack[SPY,SPX].Card = 1)  //Перетаск. карта шестерка ?(SPX,SPY Начало старта)
  else           //Масть и старшинство?
      BRes1 := BRes1  AND ((Pack[SPY,SPX].Card - Pack[Y,X-1].Card = 1)
                                AND (Pack[SPY,SPX].Suit = Pack[Y,X-1].Suit));

  if BRes1 then  //Да! Кладем.
  begin
     Form1.Canvas.Draw(_Pos[Y,X].X,_Pos[Y,X].Y,CBitmap);
     UnX1 := X; UnY1 := Y; UnX2 := SPX; UnY2 := SPY;
     Pack[Y,X].Suit := Pack[SPY,SPX].Suit;
     Pack[Y,X].Card := Pack[SPY,SPX].Card;
     Pack[Y,X].BPos := Pack[SPY,SPX].BPos;
     Pack[SPY,SPX].Card:=0;
     Undo1.Enabled := TRUE;
     CheckStatus;
     SB1.Panels[2].Text := 'Осталось карт: ' + IntToStr(32 - (Lines[1]+Lines[2]+Lines[3]+Lines[4]));
     if Lines[1]+Lines[2]+Lines[3]+Lines[4] = 32 then
     begin
       for Y := 1 to 4 do
       begin
          Pack[Y,9].Suit := Pack[Y,1].Suit;
          Pack[Y,9].Card := 9;
          Pack[Y,9].BPos := (Y-1)*9+8;
          Bitmap := TBitmap.Create;
          Bitmap.LoadFromResourceName(hInstance, BitmapName[Pack[Y,9].BPos]);
          Form1.Canvas.Draw(_Pos[Y,9].X,_Pos[Y,9].Y,Bitmap);
          Bitmap.Free;
          Delay(2);
       end;
       Deal.Enabled := FALSE;
       Vr1 := MessageBox(Application.Handle, PChar('Вы выйграли! Попробуем ещё раз?'),'Пасьянс', MB_YESNO+MB_ICONINFORMATION);
       if Vr1 = mrYes then NewGame1.Click else Close;
     end;
  end else
  begin
     if (_Pos[SPY,SPX].X < 20)  OR
        (_Pos[SPY,SPX].X > 651) OR
        (_Pos[SPY,SPX].Y < 20)  OR
        (_Pos[SPY,SPX].Y > 401)
     then Exit;
     if Pack[SPY,SPX].Card <> 0 then Form1.Canvas.Draw(_Pos[SPY,SPX].X,_Pos[SPY,SPX].Y,CBitmap);
  end;
  if Drag then CBitmap.Free;
  Drag:=FALSE;
  Form1.Paint;
end;

procedure TForm1.FormPaint(Sender: TObject);
var
  Bitmap1 : TBitmap;
  X,Y     : Byte;
  ShiftX,
  ShiftY  : Byte;
begin
   Form1.ClientHeight := 440;
   Form1.ClientWidth := 670;
   ShiftY := 20;
   if GetSystemMetrics(SM_CXFULLSCREEN) < 800
    then ShiftX := 7
    else ShiftX := 20;
   for Y:=1 to 4 do    // Изменяем коор. с учётом поправки
    for X:=1 to 9 do
    begin
      _Pos[Y,X].X := _PosC[Y,X].X + ShiftX;
      _Pos[Y,X].Y := _PosC[Y,X].Y + ShiftY;
    end;
   for Y:=1 to 4 do
    for X:=1 to 9 do
      if Pack[Y,X].Card=0 then
      with Form1.Canvas do
      begin  //Затираем карту фоном
        Pen.Width := 1;
        Pen.Color := $00808040;
        Brush.Color := clGreen;
        RoundRect(_Pos[Y,X].X,_Pos[Y,X].Y,_Pos[Y,X].X+WCard,_Pos[Y,X].Y+HCard,6,6);
      end else
      begin
        Bitmap1 := TBitmap.Create;
        Bitmap1.LoadFromResourceName(hInstance, BitmapName[Pack[Y,X].BPos]);
        Form1.Canvas.Draw(_Pos[Y,X].X,_Pos[Y,X].Y,Bitmap1);
        Bitmap1.Free;
      end;
end;

procedure CheckStatus;
var
  X,Y:Byte;
  Suit:Suits;
begin
  for Y:=1 to 4 do
  begin
   Lines[Y]:=0;
   if Pack[Y,1].Card = 1 then
   begin
      Suit:=Pack[Y,1].Suit;
      Lines[Y]:=1;
      X:=2;
      while ((X<=9) and (Pack[Y,X].Card=X) and (Pack[Y,X].Suit=Suit)) do
      begin
       Lines[Y]:=X;
       Inc(X);
      end; { do }
   end; { if }
 end; { for }
end; { End Of CheckStatus }

procedure TForm1.DealClick(Sender: TObject);
Var
  Cnt, X, Y, N   : Byte;
  I              : Integer;
  Card2          : CPack;
  ButtonSelected : Word;
  TCards2        : array[0..32] of CPack;
begin
  CheckStatus;
  Inc(Attempt);
  if (Lines[1]+Lines[2]+Lines[3]+Lines[4] = 32) OR (Attempt >= 5) then
  begin
    //Beep;
    Dec(Attempt);
    Exit;
  end;
  case Attempt of
      2 : SB1.Panels[1].Text := 'Вторая попытка';
      3 : SB1.Panels[1].Text := 'Последняя попытка';
   4..5 : SB1.Panels[1].Text := '';
  end;
  if Attempt <= 3 then
  begin
    if Attempt = 3 then SB1.Panels[0].Text := 'Нажмите F2 чтобы начать новую игру';
    Undo1.Enabled := FALSE;
    N := 0;
    Cnt := 32; { Предпологаемое число оставшихся карт }
    // Собираем карты
    for Y := 1 to 4 do
    begin
      Dec(Cnt,Lines[Y]);
      for X := Lines[Y]+1 to 9 do
        if Pack[Y,X].Card<>0 then
        begin
          TCards2[N] := Pack[Y,X];
          with Form1.Canvas do
          begin  //Затираем карту фоном
            Pen.Width := 1;
            Pen.Color := $00808040;
            Brush.Color := clGreen;
            RoundRect(_Pos[Y,X].X,_Pos[Y,X].Y,_Pos[Y,X].X+WCard,_Pos[Y,X].Y+HCard,6,6);
          end;
          Inc(N);
          Delay(2);
        end;
    end;
    // Тасуем колоду
    Randomize;
    for I:=1 to 2000 do
    begin
      repeat
        X:=Random(Cnt);
        Y:=Random(Cnt);
      until X<>Y;
      Card2:=TCards2[X];
      TCards2[X]:=TCards2[Y];
      TCards2[Y]:=Card2;
    end;
    // Сдаем
    for Y:=1 to 4 do Inc(Lines[Y]);
    N:=0;
    for Y:=1 to 4 do
      for X:=Lines[Y] to 9 do
        if X = Lines[Y] then Pack[Y,X].Card:=0
        else begin
          CBitmap := TBitmap.Create;
          Pack[Y,X]:=TCards2[N];
          CBitmap.LoadFromResourceName(hInstance, BitmapName[Pack[Y,X].BPos]);
          Form1.Canvas.Draw(_Pos[Y,X].X,_Pos[Y,X].Y,CBitmap);
          CBitmap.Free;
          Inc(N);
          Delay(2);
        end;
  end
  else begin
    Deal.Enabled := FALSE;
    ButtonSelected := MessageBox(Application.Handle, PChar('Попытки исчерпаны. Попробуем ещё раз?'),'Пасьянс', MB_YESNO+MB_ICONINFORMATION);
    if ButtonSelected = mrYes then NewGame1.Click else Close;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Deal.Enabled := FALSE;
  SB1.Panels[0].Text := 'Нажмите F2 чтобы начать новую игру';
  Attempt := 0;
  with Form1.Canvas do
  begin
     Pen.Width := 1;
     Pen.Color := $00808040;
     Brush.Color := clGreen;
  end;
end;

procedure TForm1.About1Click(Sender: TObject);
var
  S : PChar;
begin
  S := 'Пасьянс "Четыре линии"' + #13 +
       'Версия 1.0 Beta (24.10.2001)' + #13 + #13 +
       'Copyright © 1994, 1999, 2001 by A. V. Tumanov aka Andrews';
  MessageBox(Application.Handle, S, 'О программе', MB_ICONINFORMATION);
end;

procedure TForm1.Undo1Click(Sender: TObject);
var
  Bitmap : TBitmap;
  X, Y   : Byte;
begin
  Pack[UnY2,UnX2] := Pack[UnY1,UnX1];
  Pack[UnY1,UnX1].Card := 0;
  Bitmap := TBitmap.Create;
  Bitmap.LoadFromResourceName(hInstance, BitmapName[Pack[UnY2,UnX2].BPos]);
  Form1.Canvas.Draw(_Pos[UnY2,UnX2].X,_Pos[UnY2,UnX2].Y,Bitmap);
  Bitmap.Free;
  Form1.Canvas.RoundRect(_Pos[UnY1,UnX1].X,_Pos[UnY1,UnX1].Y,_Pos[UnY1,UnX1].X+WCard,_Pos[UnY1,UnX1].Y+HCard,6,6);
  X := UnX2; Y := UnY2;
  UnX2 := UnX1; UnY2 := UnY1;
  UnX1 := X; UnY1 := Y;
end;

procedure TForm1.Contens1Click(Sender: TObject);
begin
  Application.HelpFile := 'Solitaire4L.HLP';
  Application.HelpCommand(HELP_CONTENTS, 0);
end;

end.

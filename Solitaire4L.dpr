// Пасьянс "Четыре линии" Version 1.0 Beta (24.10.2001)
// Copyright (c) A. V. Tumanov aka Andrews, FREEWARE
// E-mail: avtum@fromru.com
// Игра изначально была написана мной
// в 1994 году под DOS на Borland Pascal 7.0 :o)
// в 1999 переписана на Delphi, 2001 - BugFix.
// P.S. Каждая последняя ошибка - на деле предпоследняя.

program Solitaire4L;

uses
  Forms,
  Main4D in 'Main4D.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Пасьянс "Четыре линии"';
  Application.HelpFile := 'Solitaire4L.hlp';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

// ������� "������ �����" Version 1.0 Beta (24.10.2001)
// Copyright (c) A. V. Tumanov aka Andrews, FREEWARE
// E-mail: avtum@fromru.com
// ���� ���������� ���� �������� ����
// � 1994 ���� ��� DOS �� Borland Pascal 7.0 :o)
// � 1999 ���������� �� Delphi, 2001 - BugFix.
// P.S. ������ ��������� ������ - �� ���� �������������.

program Solitaire4L;

uses
  Forms,
  Main4D in 'Main4D.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := '������� "������ �����"';
  Application.HelpFile := 'Solitaire4L.hlp';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

program SearchClientDataSet;

uses
  Vcl.Forms,
  unitMain in 'unitMain.pas' {Form1},
  unitLibrary in 'unitLibrary.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

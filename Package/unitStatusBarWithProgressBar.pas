unit unitStatusBarWithProgressBar;

interface

uses
  System.Classes, System.Types,
  Vcl.ComCtrls;

type
  TStatusBarWithProgressBar = class(TCustomStatusBar)
  private
     FprogressBar: TProgressBar;
  protected
     procedure DrawPanel(Panel: TStatusPanel; const Rect: TRect); override;
  public
     constructor Create(AOwner: TComponent); override;
  published
     property ProgressBar: TProgressBar read FprogressBar;
  end;

  procedure Register;

implementation

{ TStatusBarWithProgressBar }

constructor TStatusBarWithProgressBar.Create(AOwner: TComponent);
begin
  inherited;

  with Panels.Add do
  begin
    Style := psOwnerDraw;
  end;

  FprogressBar := TProgressBar.Create(Self);
  FprogressBar.Name := 'ProgressBar';
  FprogressBar.Parent := Self;
end;

procedure TStatusBarWithProgressBar.DrawPanel(Panel: TStatusPanel; const Rect: TRect);
begin
  inherited;

  if Panel = Panels[0] then
  with FprogressBar do
  begin
    Top := Rect.Top;
    Left := Rect.Left;
    Width := Rect.Right - Rect.Left - 15;
    Height := Rect.Bottom - Rect.Top;
  end;
end;

procedure Register;
begin
  RegisterComponents('Search ClientDataSet', [TStatusBarWithProgressBar]);
end;

end.

unit unitMain;

interface

uses
  System.SysUtils, System.Classes, System.UITypes,
  Winapi.Windows,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.DBGrids,
  Data.DB, Data.Win.ADODB,
  Datasnap.DBClient, Datasnap.Provider,
  Generics.Collections, Generics.Defaults,
  Vcl.Grids, Vcl.Dialogs, Vcl.Clipbrd, Vcl.ComCtrls,
  unitAdvancedSearch, unitLibrary, unitComboBoxStoredProcedures,
  unitStatusBarWithProgressBar;

type
  TForm1 = class(TForm)
    conDemo: TADOConnection;
    stpDemo: TADOStoredProc;
    dsSearch: TDataSource;
    grdSearch: TDBGrid;
    txtSearch: TEdit;
    lblZoeken: TLabel;
    proDemo: TDataSetProvider;
    cdDemo: TClientDataSet;
    btnSearch: TButton;
    chkStrict: TCheckBox;
    chkShowExcluded: TCheckBox;
    chkRefresh: TCheckBox;
    btnBuildConnectionString: TButton;
    btnOpenStoredProcedure: TButton;
    lblStoredProcedures: TLabel;
    chkCalcFieldsVisible: TCheckBox;
    cmbStoredProcedures: TComboBoxStoredProcedures;
    advancedSearch: TAdvancedSearch;
    stbSearch: TStatusBarWithProgressBar;

    procedure FormActivate(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure chkStrictClick(Sender: TObject);
    procedure txtSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnBuildConnectionStringClick(Sender: TObject);
    procedure btnOpenStoredProcedureClick(Sender: TObject);
    procedure chkShowExcludedClick(Sender: TObject);
  private
    bActivated: Boolean;

    procedure FirstTimeLoad;
  public
    procedure AdvancedSearchProgress(position: Integer; maximum: Integer; text: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnBuildConnectionStringClick(Sender: TObject);
begin
  SetConnection(conDemo, cmbStoredProcedures);
end;

procedure TForm1.chkShowExcludedClick(Sender: TObject);
begin
  if (chkShowExcluded.Checked) then
  begin
    chkCalcFieldsVisible.Checked := True;
  end;
end;

procedure TForm1.chkStrictClick(Sender: TObject);
begin
  if (chkStrict.Checked) then
  begin
    btnSearch.Caption := 'Zoek(AND)'
  end
  else
  begin
    btnSearch.Caption := 'Zoek(OR)';
  end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  if (bActivated) then
  begin
    Exit;
  end;

  if (conDemo.ConnectionString = EmptyStr) or
    (stpDemo.ProcedureName = EmptyStr)
  then
  begin
    if (not SetConnection(conDemo, cmbStoredProcedures)) then
    begin
      Exit;
    end;
  end;

  conDemo.Open();

  cmbStoredProcedures.ListStoredProcedures(conDemo, cmbStoredProcedures);
  FormStyle := fsStayOnTop;
  FormStyle := fsNormal;
  bActivated := True;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (cdDemo.Active) then
  begin
    cdDemo.Close;
  end;

  FreeAndNil(advancedSearch);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  advancedSearch := TAdvancedSearch.Create(Self);
  advancedSearch.OnProgress := AdvancedSearchProgress;

end;

procedure TForm1.txtSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) then
  begin
    btnSearchClick(Sender);
  end;
end;

procedure TForm1.btnOpenStoredProcedureClick(Sender: TObject);
begin
    cmbStoredProcedures.OpenProcedure(conDemo, stpDemo);

    FirstTimeLoad;
end;

procedure TForm1.btnSearchClick(Sender: TObject);
begin
  if not (cdDemo.Active) then
  begin
    Exit;
  end;

  advancedSearch.CreateAndFillSearchDataSet(cdDemo, grdSearch, False, txtSearch.Text, chkStrict.Checked, chkShowExcluded.Checked ,chkRefresh.Checked, chkCalcFieldsVisible.Checked);
end;

procedure TForm1.FirstTimeLoad;
begin
  chkStrict.Checked := False;
  chkShowExcluded.Checked := False;
  chkRefresh.Checked := False;
  chkCalcFieldsVisible.Checked := False;

  txtSearch.Text := EmptyStr;

  advancedSearch.CreateAndFillSearchDataSet(cdDemo, grdSearch, True);
end;

procedure TForm1.AdvancedSearchProgress(position: Integer; maximum: Integer; text: string);
begin
  if (position = -1) then
  begin
    Caption := Format(text,[maximum]);
  end
  else
  begin
    stbSearch.ProgressBar.Style := pbstNormal;
    stbSearch.ProgressBar.Max := maximum;
    stbSearch.ProgressBar.Position := position;
    Caption := Format(text, [position, maximum]);
    stbSearch.ProgressBar.Visible := position < maximum;
  end;

  stbSearch.ProgressBar.Refresh;
end;

end.

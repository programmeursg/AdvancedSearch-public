unit unitComboBoxStoredProcedures;

interface

uses
  System.Classes, System.SysUtils, System.UITypes,
  Vcl.StdCtrls, Vcl.Controls, Vcl.Dialogs,
  Data.Win.ADODB;

type
  TComboBoxStoredProcedures = class(TComboBox)
    procedure ListStoredProcedures(condemo: TAdoConnection; cmbStoredProcedures: TComboBox);
    procedure OpenProcedure(conDemo:TADOConnection; stpDemo:TADOStoredProc);
  end;

  procedure Register;

implementation

procedure TComboBoxStoredProcedures.ListStoredProcedures(condemo: TAdoConnection; cmbStoredProcedures: TComboBox);
var
  ADOQuery: TADOQuery;
begin
  ADOQuery := TADOQuery.Create(nil);
  try
    ADOQuery.Connection := conDemo;
    ADOQuery.SQL.Text :=
      'SELECT SPECIFIC_NAME ' +
      'FROM INFORMATION_SCHEMA.ROUTINES ' +
      'WHERE ROUTINE_TYPE = ''PROCEDURE'' ' +
      'ORDER BY SPECIFIC_NAME';
    ADOQuery.Open;

    cmbStoredProcedures.Items.Clear;
    cmbStoredProcedures.Text := EmptyStr;
    // Process the list of stored procedures
    while not ADOQuery.Eof do
    begin
      cmbStoredProcedures.Items.Add(ADOQuery.FieldByName('SPECIFIC_NAME').AsString);
      ADOQuery.Next;
    end;
  finally
    ADOQuery.Free;
  end;
end;

procedure TComboBoxStoredProcedures.OpenProcedure(conDemo:TADOConnection; stpDemo:TADOStoredProc);
begin
  if (ItemIndex = -1) then
  begin
    Exit;
  end;

  if (MessageDlg('Do you want to open the stored procedure:' + sLineBreak + sLineBreak +
    Items[ItemIndex] + sLineBreak + sLineBreak +
    'and are you sure this stored procedure is not harmfull!' + sLineBreak +
    'Maybe it contains DELETE or INSERT statements or other harmfull statements',
    mtWarning, [mbYes,mbNo], 0) = mrYes) then
  begin
    conDemo.Close;

    stpDemo.ProcedureName := Items[ItemIndex];
    stpDemo.Parameters.Refresh;


    if (stpDemo.Parameters.Count = 0)  then
    begin
      MessageDlg('This storedprocdure doesn''t exist', mtInformation, [TMsgDlgBtn.mbOK], 0);
      Exit;
    end;

    if NOT ((stpDemo.Parameters.Count = 1) AND (stpDemo.Parameters[0].Name = '@RETURN_VALUE'))  then
    begin
      MessageDlg('This storedprocdure has parameters and that is not allowed with this button', mtInformation, [TMsgDlgBtn.mbOK], 0);
      Exit;
    end;

    conDemo.Open;
  end;
end;

procedure Register;
begin
  RegisterComponents('Search ClientDataSet', [TComboBoxStoredProcedures]);
end;

end.

unit unitLibrary;

interface

uses
  System.SysUtils, System.Classes, System.UITypes,
  Data.Win.ADODB,
  Vcl.StdCtrls, Vcl.Dialogs, Vcl.Clipbrd, Vcl.Controls,
  unitComboBoxStoredProcedures;

function SetConnection(conDemo:TAdoConnection; cmbStoredProcedures: TComboBoxStoredProcedures) : Boolean; forward;

implementation

function SetConnection(conDemo:TAdoConnection; cmbStoredProcedures: TComboBoxStoredProcedures) : Boolean;
var
  failed: Boolean;
  connectionStringParameters: TStringList;
  connectionStringParameterKeyValue: TStringList;
  I: Integer;
begin
  repeat
    failed := False;
    conDemo.Close;
    conDemo.ConnectionString := PromptDataSource(0, conDemo.ConnectionString);

    if (conDemo.ConnectionString = EmptyStr) then
    begin
       if MessageDlg('You have not choosen a connection, do you want to exit the wizard?', mtError,[mbYes,mbNo], 0) = mrYes then
       begin
         Break;
       end;
    end
    else
    begin
      try
        try
          conDemo.Close;
          conDemo.Open;
        except
          on E: Exception do
          begin
            failed := True;
            if (MessageDlg('Testing the connection failed, do you want to retry the wizard? ', mtError, [mbYes,mbNo], 0) = mrNo) then
            begin
              Break;
            end;
          end;
        end;
      finally
        conDemo.Close;
      end;
    end;
    //Parse catalog
    failed := True;
    connectionStringParameters := TStringList.Create;
    try
      connectionStringParameters.Delimiter := ';';
      connectionStringParameters.QuoteChar := '"';
      connectionStringParameters.StrictDelimiter := True;
      connectionStringParameters.DelimitedText := conDemo.ConnectionString;

      for I := 0 to connectionStringParameters.Count-1 do
      begin
        connectionStringParameterKeyValue := TStringList.Create;
        try
          connectionStringParameterKeyValue.Delimiter := '=';
          connectionStringParameterKeyValue.QuoteChar := '"';
          connectionStringParameterKeyValue.StrictDelimiter := True;
          connectionStringParameterKeyValue.DelimitedText := connectionStringParameters[I];
          if connectionStringParameterKeyValue.Count = 2 then
          begin

            if connectionStringParameterKeyValue[0] = 'Initial Catalog' then
            begin
              if connectionStringParameterKeyValue[1] <> EmptyStr then
              begin
                if (MessageDlg('Do you want to use this database: '+connectionStringParameterKeyValue[1],TMsgDlgType.mtConfirmation,[mbYes,mbNo],0) = mrYes) then
                begin
                  failed := False;
                  Break;
                end
                else
                begin
                  Result := False;
                  Exit;
                end;
              end
              else
              begin
                if (MessageDlg('No database selected! Do you want to retry the wizard? ', mtError, [mbYes,mbNo], 0) = mrYes) then
                begin
                  failed := True;
                  Break;
                end
                else
                begin
                  Result := False;
                  Exit;
                end;
              end;

            end;
          end;

        finally
          FreeAndNil(connectionStringParameterKeyValue);
        end;
      end;
    finally
      FreeAndNil(connectionStringParameters);
    end;


  until (conDemo.ConnectionString <> EmptyStr) and (not failed);

  if (conDemo.ConnectionString <> EmptyStr) and (not failed) and
    (MessageDlg('Do you want to copy the connectionstring:' + sLineBreak +
      conDemo.ConnectionString + sLineBreak +
      'to the clipboard so you can paste the connectionstring' + sLineBreak +
      'into the ConnectionString of the conDemo control?',TMsgDlgType.mtConfirmation,[mbYes,mbNo], 0) = mrYes) then
  begin
    ClipBoard.AsText := conDemo.ConnectionString;
  end;

  if (conDemo.ConnectionString <> EmptyStr) and (not failed) then
  begin
    cmbStoredProcedures.ListStoredProcedures(conDemo, cmbStoredProcedures);
  end;

  Result := (conDemo.ConnectionString <> EmptyStr) and (not failed);
end;

end.

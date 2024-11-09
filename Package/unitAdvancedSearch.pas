unit unitAdvancedSearch;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Generics.Defaults,
  System.Variants, System.UITypes,
  DataSnap.DbClient, DataSnap.Provider,
  Data.DB, Data.Win.ADODB,
  Vcl.DBGrids, Vcl.Dialogs;

type
  TAdvancedSearchProgress = procedure(position: Integer; maximum: Integer; text: string) of object;

  TAdvancedSearch = class(TComponent)
  private
    FSearchProgress: TAdvancedSearchProgress;

    enableCalcFields: Boolean;
    calcFieldsCounter: Integer;
    cloneCursorWithoutOpen: Boolean;
    orSearch, showExcluded, calculatedFieldsVisible: Boolean;
    FsearchString: string;

    procedure ExtendSearchDataSet(clonedDataSet: TClientDataSet; calculatedFieldsVisible: Boolean);
    procedure MemoGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure DataSetFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure DataSetCalcFields(DataSet: TDataSet);
    procedure DataSetBeforeOpen(DataSet: TDataSet);
    procedure DataSetAfterOpen(DataSet: TDataSet);
    procedure OriginalDataSetAfterOpen(DataSet: TDataSet);
    procedure OrginalStpAfterOpen(DataSet: TDataSet);
    procedure OrginalStpFetchComplete(DataSet: TCustomADODataSet; const Error: Error; var EventStatus: TEventStatus);
  public
    refreshRecordCounter: Integer;
    recordCount: Integer;
    searchDataSet: TClientDataSet;
    autoIncField: TField;

    procedure CreateAndFillSearchDataSet(originalDataSet: TClientDataSet; searchGrid: TDBGrid;  firstLoad: Boolean; searchString: string = ''; strictSearch: Boolean = False; includeExcluded: Boolean = False; refreshData: Boolean = False; showCalculated: Boolean = False);
    function GetStoredProcFromClientDataSet(clientDataSet:TClientDataSet): TAdoStoredProc;

    property OnProgress: TAdvancedSearchProgress read FSearchProgress write FSearchProgress;

    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
  end;

  procedure Register;

implementation

constructor TAdvancedSearch.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  searchDataSet := TClientDataSet.Create(nil);
end;

destructor TAdvancedSearch.Destroy;
begin
  FreeAndNil(searchDataSet);
  inherited Destroy;
end;


procedure TAdvancedSearch.ExtendSearchDataSet(clonedDataSet: TClientDataSet; calculatedFieldsVisible: Boolean);
begin
  with clonedDataSet.FieldDefs.AddFieldDef do
  begin
    Name := 'Gewicht';
    DataType := ftInteger;
    InternalCalcField := True;
    with CreateField(clonedDataSet) do
    begin
      Visible := calculatedFieldsVisible;
    end;
  end;

  with clonedDataSet.FieldDefs.AddFieldDef do
  begin
    Name := 'Count';
    DataType := ftInteger;
    InternalCalcField := True;
    with CreateField(clonedDataSet) do
    begin
      Visible := calculatedFieldsVisible;
    end;
  end;

  with clonedDataSet.FieldDefs.AddFieldDef do
  begin
    Name := 'ExcludedWordsCount';
    DataType := ftInteger;
    InternalCalcField := True;
    with CreateField(clonedDataSet) do
    begin
      Visible := calculatedFieldsVisible;
    end;
  end;

  with clonedDataSet.FieldDefs.AddFieldDef do
  begin
    Name := 'ExcludedWords';
    DataType := ftWideString;
    Size := 250;
    InternalCalcField := True;
    with CreateField(clonedDataSet) do
    begin
      Visible := calculatedFieldsVisible;
    end;
  end;

  clonedDataSet.OnFilterRecord := DataSetFilterRecord;
  clonedDataSet.OnCalcFields := DataSetCalcFields;

  clonedDataSet.PacketRecords := 1000;
  clonedDataSet.AfterOpen := DataSetAfterOpen;
end;

procedure TAdvancedSearch.CreateAndFillSearchDataSet(originalDataSet: TClientDataSet; searchGrid: TDBGrid;  firstLoad: Boolean; searchString: string = ''; strictSearch: Boolean = False; includeExcluded: Boolean = False; refreshData: Boolean = False; showCalculated: Boolean = False);
var
  clonedDataSetFieldCounter: Integer;
  clonedDataSetFieldDefCounter: integer;
  dataSourceSearch: TDataSource;
  storedProcedureOriginal: TADOStoredProc;
  clonedDataSet: TClientDataSet;

begin
  orSearch := not strictSearch;
  showExcluded := includeExcluded;
  calculatedFieldsVisible := showCalculated;
  FsearchString := searchString;

  clonedDataSet := searchDataSet;

  clonedDataSet.DisableControls;
  try
    if (firstLoad) then
    begin
      dataSourceSearch := searchGrid.DataSource;
      dataSourceSearch.DataSet := clonedDataSet;
      searchGrid.DataSource := dataSourceSearch;

      storedProcedureOriginal := GetStoredProcFromClientDataSet(originalDataSet);

      if not Assigned(storedProcedureOriginal) then
      begin
        messageDlg('No storedprocedure connected to the original clientdataset', mtError, [mbOK], 0);
        Exit;
      end;

      originalDataSet.AfterOpen := OriginalDataSetAfterOpen;
      storedProcedureOriginal.AfterOpen := OrginalStpAfterOpen;
      storedProcedureOriginal.OnFetchComplete := OrginalStpFetchComplete;
    end;

    enableCalcFields := False;

    if (RefreshData) or (firstLoad) then
    begin
      originalDataSet.Close;
      originalDataSet.PacketRecords := 0;
      originalDataSet.Open;
    end;

    if (not originalDataSet.Active) then
    begin
      Exit;
    end;

    clonedDataSet.FieldDefs.Clear;
    clonedDataSet.Fields.Clear;
    clonedDataSet.Filtered := False;
    clonedDataSet.IndexName := '';
    enableCalcFields := False;

    //Makes sure that the originalDataSet is not opened in CloneCursor
    //Abort causes everything to be aborted in BeforeOpen
    //But the except block prevents this, because the Abort exception is catched
    clonedDataSet.BeforeOpen := DataSetBeforeOpen;
    cloneCursorWithoutOpen := True;
    try
      clonedDataSet.CloneCursor(originalDataSet, True);
    except
      on E: EAbort do
      begin
        //Catch the EAbort exception and do nothing, all other exceptions will not be catched
      end
    end;

    cloneCursorWithoutOpen := False;

    clonedDataSet.FieldDefs.Update;
    for clonedDataSetFieldDefCounter := 0 to clonedDataSet.FieldDefs.Count - 1 do
      clonedDataSet.FieldDefs[clonedDataSetFieldDefCounter].CreateField(clonedDataSet);



    for clonedDataSetFieldCounter := 0 to clonedDataSet.Fields.Count-1 do
    begin
      if (clonedDataSet.Fields[clonedDataSetFieldCounter].DataType = ftWideMemo) then
      begin
        clonedDataSet.Fields[clonedDataSetFieldCounter].OnGetText := MemoGetText;
      end;
    end;

    ExtendSearchDataSet(clonedDataSet, calculatedFieldsVisible);

    if (firstLoad) then
    begin
      clonedDataSet.IndexDefs.Clear;
      with clonedDataSet.IndexDefs.AddIndexDef do
      begin
        DescFields:= 'Count';
        Fields := 'Count;Gewicht;ExcludedWordsCount;' + autoIncField.FieldName;
        Name := 'idxGewicht';
        Options := [ixDescending];
      end;

      clonedDataSet.Open;
    end
    else
    begin
      if (searchString = EmptyStr) then
      begin
        enableCalcFields := False;
        clonedDataSet.Filtered := False;
        clonedDataSet.IndexName := '';
        clonedDataSet.Open;
      end
      else
      begin
        calcFieldsCounter := 0;

        clonedDataSet.Close;
        clonedDataSet.IndexName := '';
        clonedDataSet.Filtered := False;
        enableCalcFields := True;

        clonedDataSet.Open;

        OnProgress(-1, refreshRecordCounter, 'Applying filter on %d records');

        clonedDataSet.Filtered := True;

        OnProgress(-1, clonedDataSet.RecordCount, 'Applying index on %d records');

        clonedDataSet.IndexName := 'idxGewicht';
      end;
    end;

    clonedDataSet.First;

    OnProgress(-1, clonedDataSet.RecordCount, 'Found %d records');
  finally
    clonedDataSet.EnableControls;
  end;
end;

procedure TAdvancedSearch.MemoGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  Text := Sender.AsString;
end;

procedure TAdvancedSearch.DataSetFilterRecord(DataSet: TDataSet; var Accept: Boolean);
var
  fieldValue: string;
  fieldTeller : integer;
  posCount: Integer;
  strings: TStringList;
  stringTeller: Integer;
  stringValue: string;
  referenceCount: integer;
begin
  referenceCount := 0;

  if (FsearchString = EmptyStr) then
  begin
    Accept := True;
    Exit;
  end;

  //Split search terms
  strings := TStringList.Create();

  strings.QuoteChar := '"';

  strings.Delimiter := ' ';
  strings.DelimitedText := FsearchString;

  Accept := showExcluded;
  //Loop through serach terms
  for stringTeller := 0 to strings.Count-1 do
  begin
    Accept := showExcluded;
    stringValue := strings[stringTeller];
    //Loop through fields
    for fieldTeller := 0 to  DataSet.FieldList.Count-1 do
    begin
      if (DataSet.Fields[fieldTeller] <> DataSet.FieldByName('Gewicht'))
        and (DataSet.Fields[fieldTeller] <> DataSet.FieldByName('Count'))
        and (DataSet.Fields[fieldTeller] <> DataSet.FieldByName('ExcludedWords'))
         then
      begin
        fieldValue := DataSet.Fields[fieldTeller].AsString;

        posCount := Pos(UpperCase(stringValue), UpperCase(fieldValue), 1);

        if (posCount > 0) then
        begin
          Accept:= True;
          Inc(referenceCount);

          if (orSearch) then
          begin
            Break;
          end
          else
          begin
            Break;
          end;
        end;
      end;
    end;

    if (referenceCount > 0) and (orSearch) then
    begin
      Accept := True;
    end;

    if ((not orSearch) and (Accept =false)) then
    begin
      Exit;
    end;
  end;
end;

procedure TAdvancedSearch.DataSetCalcFields(DataSet: TDataSet);
var
  fieldValue: string;
  fieldCounter : integer;
  posCount: Integer;
  strings: TStringList;
  stringCounter: Integer;
  stringValue: string;
  referenceCount: Integer;
  stringNumber: Integer;
  stringsNotFound: array of Boolean;
  notFoundCounter: Integer;
  notFoundString: string;
  finallyNotFoundCounter: Integer;
begin
  if (not enableCalcFields) then
  begin
    Exit;
  end;

  if (FsearchString = EmptyStr) then
  begin
    DataSet.FieldByName('Gewicht').AsInteger := 1;
    Exit;
  end;

  Inc(calcFieldsCounter);

  if (calcFieldsCounter mod 1000 = 0)  or (calcFieldsCounter = recordCount ) then
  begin
    OnProgress(calcFieldsCounter, recordCount,'Calculating fields: %d of %d');
  end;

  //Split search terms
  strings := TStringList.Create();

  strings.QuoteChar := '"';

  strings.Delimiter := ' ';
  strings.DelimitedText := FsearchString;

  SetLength(stringsNotFound,strings.Count);

  DataSet.FieldByName('Gewicht').AsInteger := 0;

  stringNumber := 0;
  referenceCount := 0;

  //Loop through searchterms
  for stringCounter := 0 to strings.Count-1 do
  begin
    stringsNotFound[stringCounter] := True;

    DataSet.FieldByName('Gewicht').AsInteger := 0;

    stringValue := strings[stringCounter];

    //Loop through fields
    for fieldCounter := 0 to  DataSet.FieldList.Count-1 do
    begin
      if (DataSet.Fields[fieldCounter] <> DataSet.FieldByName('Gewicht'))
        and (DataSet.Fields[fieldCounter] <> DataSet.FieldByName('Count'))
        and (DataSet.Fields[fieldCounter] <> DataSet.FieldByName('ExcludedWords')) then
      begin

        fieldValue := DataSet.Fields[fieldCounter].AsString;

        posCount := Pos(UpperCase(stringValue), UpperCase(fieldValue), 1);

        if (posCount > 0) then
        begin
          stringsNotFound[stringCounter] := False;

          DataSet.FieldByName('Gewicht').AsInteger := stringCounter + 1;

          Inc(referenceCount);
          DataSet.FieldByName('Count').AsInteger := referenceCount;

          stringNumber := stringCounter + 1;

          if (orSearch) then
          begin
            Continue;
          end
          else
          begin
            Continue;
          end;
        end;
      end;
    end;

    if (referenceCount > 0) then
    begin
      DataSet.FieldByName('Gewicht').AsInteger := stringNumber;
    end;

    if ((not orSearch) and (DataSet.FieldByName('Gewicht').AsInteger = 0)) then
    begin
      Exit;
    end;
  end;

  notFoundString := EmptyStr;
  finallyNotFoundCounter := 0;

  for notFoundCounter := 0 to Length(stringsNotFound) - 1 do
  begin
    if stringsNotFound[notFoundCounter] then
    begin
      Inc(finallyNotFoundCounter);
      notFoundString := notFoundString + strings[notFoundCounter] + ' ';
    end;
  end;

  notFoundString := Trim(notFoundString);

  DataSet.FieldByName('ExcludedWords').AsString := notFoundString;
  DataSet.FieldByName('ExcludedWordsCount').AsInteger := finallyNotFoundCounter;
end;

procedure TAdvancedSearch.DataSetBeforeOpen(DataSet: TDataSet);
begin
  if (cloneCursorWithoutOpen) then
  begin
    Abort;
  end;
end;

procedure TAdvancedSearch.DataSetAfterOpen(DataSet: TDataSet);
begin
  repeat
    refreshRecordCounter := DataSet.RecordCount;

    OnProgress(refreshRecordCounter, recordCount, 'Opening search dataset: %d of %d');
  until TClientDataSet(Dataset).GetNextPacket = 0;
end;

procedure TAdvancedSearch.OriginalDataSetAfterOpen(DataSet: TDataSet);
var
  dataSetFieldCounter: Integer;
begin
  autoIncField := nil;

  for dataSetFieldCounter := 0 to DataSet.Fields.Count-1 do
  begin
    if (DataSet.Fields[dataSetFieldCounter].DataType = ftAutoInc) then
    begin
      if (not Assigned(autoIncField)) then
      begin
        autoIncField := DataSet.Fields[dataSetFieldCounter];
      end;
    end;
  end;

  if (not Assigned(autoIncField)) then
  begin
    MessageDlg('The stored procedure doesn''t contain a ftAutoInc field, the creation of the dataset is aborted.', mtError, [mbOK], 0);
    DataSet.Close;
    Abort;
  end
  else
  begin
    TClientDataSet(DataSet).PacketRecords := 1000;
  end;

  repeat
    refreshRecordCounter := DataSet.RecordCount;

    OnProgress(refreshRecordCounter, recordCount, 'Opening original dataset: %d of %d');


  until TClientDataSet(DataSet).GetNextPacket = 0;
end;

procedure TAdvancedSearch.OrginalStpAfterOpen(DataSet: TDataSet);
begin
  with TCustomADODataSet(DataSet) do
  begin
    if not DataSet.Eof then
    begin
      Recordset.MoveFirst;
      CursorPosChanged;
      Resync([]);
    end;
  end;
end;

procedure TAdvancedSearch.OrginalStpFetchComplete(DataSet: TCustomADODataSet;
  const Error: Error; var EventStatus: TEventStatus);
begin
  recordCount := DataSet.RecordCount;
end;

function TAdvancedSearch.GetStoredProcFromClientDataSet(clientDataSet:TClientDataSet): TAdoStoredProc;
var
  dataSetProvider: TDataSetProvider;
begin
  Result := nil;

  dataSetProvider := TDataSetProvider(Owner.FindComponent(clientDataSet.ProviderName));

  if Assigned(dataSetProvider) and (dataSetProvider.DataSet is TADOStoredProc) then
  begin
    Result := TADOStoredProc(dataSetProvider.DataSet);
  end;
end;

procedure Register;
begin
  RegisterComponents('Search ClientDataSet', [TAdvancedSearch]);
end;

end.

object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 
    'Search on multiple words  AND and OR with weight and words count' +
    'er'
  ClientHeight = 838
  ClientWidth = 1534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 13
  object lblZoeken: TLabel
    Left = 9
    Top = 13
    Width = 33
    Height = 13
    Caption = 'Search'
  end
  object lblStoredProcedures: TLabel
    Left = 1200
    Top = 13
    Width = 89
    Height = 13
    Caption = 'Stored procedures'
  end
  object grdSearch: TDBGrid
    AlignWithMargins = True
    Left = 8
    Top = 95
    Width = 1518
    Height = 716
    Margins.Left = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = dsSearch
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object txtSearch: TEdit
    Left = 50
    Top = 10
    Width = 217
    Height = 21
    TabOrder = 1
    OnKeyDown = txtSearchKeyDown
  end
  object btnSearch: TButton
    Left = 273
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Zoek(OR)'
    TabOrder = 2
    OnClick = btnSearchClick
  end
  object chkStrict: TCheckBox
    Left = 355
    Top = 12
    Width = 47
    Height = 17
    Caption = 'Strict'
    TabOrder = 3
    OnClick = chkStrictClick
  end
  object chkShowExcluded: TCheckBox
    Left = 355
    Top = 32
    Width = 106
    Height = 17
    Caption = 'Include excluded'
    TabOrder = 4
    OnClick = chkShowExcludedClick
  end
  object chkRefresh: TCheckBox
    Left = 355
    Top = 52
    Width = 66
    Height = 17
    Caption = 'Refresh'
    TabOrder = 5
  end
  object btnBuildConnectionString: TButton
    Left = 1065
    Top = 8
    Width = 129
    Height = 25
    Caption = 'Build connectionstring'
    TabOrder = 6
    OnClick = btnBuildConnectionStringClick
  end
  object btnOpenStoredProcedure: TButton
    Left = 1451
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 7
    OnClick = btnOpenStoredProcedureClick
  end
  object chkCalcFieldsVisible: TCheckBox
    Left = 355
    Top = 72
    Width = 97
    Height = 17
    Caption = 'Show calculated fields'
    TabOrder = 8
  end
  object cmbStoredProcedures: TComboBoxStoredProcedures
    Left = 1297
    Top = 10
    Width = 148
    Height = 21
    TabOrder = 9
  end
  object stbSearch: TStatusBarWithProgressBar
    Left = 0
    Top = 819
    Width = 1534
    Height = 19
    ExplicitTop = 818
    ExplicitWidth = 1530
  end
  object conDemo: TADOConnection
    LoginPrompt = False
    Provider = 'MSOLEDBSQL.1'
    Left = 48
    Top = 440
  end
  object stpDemo: TADOStoredProc
    Connection = conDemo
    CursorType = ctStatic
    ExecuteOptions = [eoAsyncExecute, eoAsyncFetch]
    Parameters = <>
    Left = 128
    Top = 440
  end
  object dsSearch: TDataSource
    Left = 608
    Top = 448
  end
  object proDemo: TDataSetProvider
    DataSet = stpDemo
    Left = 208
    Top = 440
  end
  object cdDemo: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'naw_Id'
        Attributes = [faReadonly]
        DataType = ftAutoInc
      end
      item
        Name = 'naw_Memo'
        DataType = ftWideMemo
      end
      item
        Name = 'naw_Number'
        DataType = ftInteger
      end
      item
        Name = 'naw_Datum'
        DataType = ftDateTime
      end>
    IndexDefs = <>
    PacketRecords = 1
    Params = <>
    ProviderName = 'proDemo'
    StoreDefs = True
    Left = 304
    Top = 440
  end
  object advancedSearch: TAdvancedSearch
    Left = 56
    Top = 128
  end
end

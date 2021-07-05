object frmMainClassGenerator: TfrmMainClassGenerator
  Left = 0
  Top = 0
  Caption = 'Class Generator'
  ClientHeight = 628
  ClientWidth = 1068
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter4: TSplitter
    Left = 0
    Top = 305
    Width = 1068
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 300
    ExplicitWidth = 301
  end
  object pnlTop: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 1062
    Height = 299
    Align = alTop
    TabOrder = 0
    object Splitter3: TSplitter
      Left = 460
      Top = 1
      Height = 297
      ExplicitLeft = 348
      ExplicitHeight = 326
    end
    object pnlLeft: TPanel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 453
      Height = 291
      Align = alLeft
      TabOrder = 1
      object lblhost_name: TLabel
        Left = 61
        Top = 15
        Width = 61
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Host Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lbldatabase_name: TLabel
        Left = 33
        Top = 37
        Width = 89
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Database Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lblport_name: TLabel
        Left = 81
        Top = 59
        Width = 41
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Port No'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lbluser_name: TLabel
        Left = 265
        Top = 15
        Width = 61
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'User Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lblpassword: TLabel
        Left = 272
        Top = 37
        Width = 54
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Password'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lblschema_name: TLabel
        Left = 246
        Top = 59
        Width = 80
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Schema Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object Label2: TLabel
        Left = 62
        Top = 184
        Width = 60
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Class Type'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object Label4: TLabel
        Left = 256
        Top = 184
        Width = 70
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Source Code'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object Label5: TLabel
        Left = 17
        Top = 139
        Width = 105
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Project File (*.dpr)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lblInputFormCaption: TLabel
        Left = 251
        Top = 228
        Width = 75
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Form Caption'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lblInputFormName: TLabel
        Left = 24
        Top = 228
        Width = 98
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Input Form Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lblOutputFormCaption: TLabel
        Left = 251
        Top = 206
        Width = 75
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Form Caption'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lblOutputFormName: TLabel
        Left = 16
        Top = 206
        Width = 106
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Output Form Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lbltable_name: TLabel
        Left = 56
        Top = 162
        Width = 66
        Height = 13
        BiDiMode = bdRightToLeft
        Caption = 'Table Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edthost_name: TEdit
        Left = 124
        Top = 12
        Width = 112
        Height = 21
        TabOrder = 0
        Text = '127.0.0.1'
      end
      object edtdatabase_name: TEdit
        Left = 124
        Top = 34
        Width = 112
        Height = 21
        TabOrder = 2
        Text = 'ths_erp_per'
      end
      object edtport_name: TEdit
        Left = 124
        Top = 56
        Width = 112
        Height = 21
        TabOrder = 4
        Text = '5432'
      end
      object edtuser_name: TEdit
        Left = 328
        Top = 12
        Width = 112
        Height = 21
        TabOrder = 1
        Text = 'ths_admin'
      end
      object edtpassword: TEdit
        Left = 328
        Top = 34
        Width = 112
        Height = 21
        PasswordChar = '*'
        TabOrder = 3
        Text = 'THS'
      end
      object edtschema_name: TEdit
        Left = 328
        Top = 56
        Width = 112
        Height = 21
        TabOrder = 5
        Text = 'public'
      end
      object btnConnect: TButton
        Left = 124
        Top = 77
        Width = 316
        Height = 27
        Action = actConnect
        TabOrder = 6
      end
      object btnSaveToFiles: TButton
        AlignWithMargins = True
        Left = 124
        Top = 247
        Width = 316
        Height = 27
        Caption = 'Save To Files'
        TabOrder = 15
        OnClick = btnSaveToFilesClick
      end
      object edtClassType: TEdit
        Left = 124
        Top = 181
        Width = 112
        Height = 21
        TabOrder = 9
      end
      object edtInputFormCaption: TEdit
        Left = 328
        Top = 225
        Width = 112
        Height = 21
        TabOrder = 14
      end
      object edtInputFormName: TEdit
        Left = 124
        Top = 225
        Width = 112
        Height = 21
        TabOrder = 13
      end
      object edtMainProjectDirectory: TEdit
        Left = 124
        Top = 137
        Width = 316
        Height = 21
        TabOrder = 7
        OnDblClick = edtMainProjectDirectoryDblClick
      end
      object edtOutputFormCaption: TEdit
        Left = 328
        Top = 203
        Width = 112
        Height = 21
        TabOrder = 12
      end
      object edtOutputFormName: TEdit
        Left = 124
        Top = 203
        Width = 112
        Height = 21
        TabOrder = 11
      end
      object edtSourceCode: TEdit
        Left = 328
        Top = 181
        Width = 112
        Height = 21
        TabOrder = 10
      end
      object cbbtable_name: TComboBox
        Left = 124
        Top = 159
        Width = 316
        Height = 21
        Style = csDropDownList
        TabOrder = 8
        OnChange = cbbtable_nameChange
        Items.Strings = (
          'ftString'
          'ftWideString'
          'ftInteger'
          'ftLongInt'
          'ftFloat'
          'ftDate'
          'ftDateTime'
          'ftTime'
          'ftWord'
          'ftBoolean')
      end
    end
    object grdColumns: TDBGrid
      Left = 463
      Top = 1
      Width = 598
      Height = 297
      Align = alClient
      DataSource = dsColumns
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      Columns = <
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'field_name'
          Title.Alignment = taCenter
          Title.Caption = 'Field Name'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 100
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'field_type'
          Title.Alignment = taCenter
          Title.Caption = 'Field Type'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 100
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'column_caption'
          Title.Alignment = taCenter
          Title.Caption = 'Grid Col Caption'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 150
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'input_caption'
          Title.Alignment = taCenter
          Title.Caption = 'Label Caption'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 150
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'is_gui'
          Title.Alignment = taCenter
          Title.Caption = 'GUI'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 40
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'input_type'
          PickList.Strings = (
            'Edit'
            'ComboBox'
            'Memo'
            'CheckBox')
          Title.Alignment = taCenter
          Title.Caption = 'Input Type'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 75
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'is_numeric'
          Title.Alignment = taCenter
          Title.Caption = 'Numeric?'
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWindowText
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 60
          Visible = True
        end>
    end
  end
  object pgcMemos: TPageControl
    AlignWithMargins = True
    Left = 3
    Top = 311
    Width = 1062
    Height = 314
    ActivePage = tsInput
    Align = alClient
    TabOrder = 1
    object tsClass: TTabSheet
      Caption = 'Class Section'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object mmoClass: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 1048
        Height = 234
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
        OnKeyDown = mmoKeyDown
      end
      object pnlClass: TPanel
        AlignWithMargins = True
        Left = 3
        Top = 243
        Width = 1048
        Height = 40
        Align = alBottom
        TabOrder = 1
        object btnAddClassToMemo: TButton
          AlignWithMargins = True
          Left = 969
          Top = 4
          Width = 75
          Height = 32
          Align = alRight
          Caption = 'Add Memo'
          TabOrder = 0
          OnClick = btnAddClassToMemoClick
        end
      end
    end
    object tsOutput: TTabSheet
      Caption = 'Output Form Section'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Splitter1: TSplitter
        Left = 500
        Top = 0
        Height = 286
        ExplicitLeft = 421
        ExplicitHeight = 360
      end
      object pnlOutputDFM: TPanel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 494
        Height = 280
        Align = alLeft
        Caption = 'pnlOutputDFM'
        TabOrder = 0
        object mmoOutputDFM: TMemo
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 486
          Height = 226
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          OnKeyDown = mmoKeyDown
        end
        object pnlOutputBottomDFM: TPanel
          AlignWithMargins = True
          Left = 4
          Top = 236
          Width = 486
          Height = 40
          Align = alBottom
          TabOrder = 1
        end
      end
      object pnlOutputPAS: TPanel
        AlignWithMargins = True
        Left = 506
        Top = 3
        Width = 545
        Height = 280
        Align = alClient
        Caption = 'pnlOutputPAS'
        TabOrder = 1
        object mmoOutputPAS: TMemo
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 537
          Height = 226
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          OnKeyDown = mmoKeyDown
        end
        object pnlOutputBottomPAS: TPanel
          AlignWithMargins = True
          Left = 4
          Top = 236
          Width = 537
          Height = 40
          Align = alBottom
          TabOrder = 1
          object btnAddOutputPASToMemo: TButton
            AlignWithMargins = True
            Left = 458
            Top = 4
            Width = 75
            Height = 32
            Align = alRight
            Caption = 'Add Memo'
            TabOrder = 0
            OnClick = btnAddOutputPASToMemoClick
          end
        end
      end
    end
    object tsInput: TTabSheet
      Caption = 'Input Form Caption'
      ImageIndex = 2
      object Splitter2: TSplitter
        Left = 420
        Top = 0
        Height = 286
        ExplicitLeft = 428
        ExplicitHeight = 360
      end
      object pnlInputDFM: TPanel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 414
        Height = 280
        Align = alLeft
        Caption = 'pnlOutputDFM'
        TabOrder = 0
        object mmoInputDFM: TMemo
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 406
          Height = 226
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          OnKeyDown = mmoKeyDown
        end
        object pnlInputBottomDFM: TPanel
          AlignWithMargins = True
          Left = 4
          Top = 236
          Width = 406
          Height = 40
          Align = alBottom
          TabOrder = 1
        end
      end
      object pnlInputPAS: TPanel
        AlignWithMargins = True
        Left = 426
        Top = 3
        Width = 625
        Height = 280
        Align = alClient
        Caption = 'pnlOutputPAS'
        TabOrder = 1
        object mmoInputPAS: TMemo
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 617
          Height = 226
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          OnKeyDown = mmoKeyDown
        end
        object pnlInputBottomPAS: TPanel
          AlignWithMargins = True
          Left = 4
          Top = 236
          Width = 617
          Height = 40
          Align = alBottom
          TabOrder = 1
          object btnAddInputPASToMemo: TButton
            AlignWithMargins = True
            Left = 538
            Top = 4
            Width = 75
            Height = 32
            Align = alRight
            Caption = 'Add Memo'
            TabOrder = 0
            OnClick = btnAddInputPASToMemoClick
          end
        end
      end
    end
  end
  object pmBase: TPopupMenu
    Left = 752
    Top = 160
    object mniDeleteRow: TMenuItem
      Caption = 'Delete Row'
    end
    object mniSaveToFile: TMenuItem
      Caption = 'Save To File'
    end
    object mniLoadFromFile: TMenuItem
      Caption = 'Load From File'
    end
  end
  object con1: TFDConnection
    Params.Strings = (
      'Database=ths_erp_per'
      'User_Name=ths_admin'
      'Password=THS'
      'CharacterSet=UTF8'
      'Server=127.0.0.1'
      'DriverID=PG')
    LoginPrompt = False
    Left = 592
    Top = 104
  end
  object FDPhysPgDriverLink1: TFDPhysPgDriverLink
    Left = 664
    Top = 104
  end
  object dsTables: TDataSource
    Left = 112
    Top = 512
  end
  object ActionList1: TActionList
    Left = 352
    Top = 176
    object actConnect: TAction
      Caption = 'Connect'
      OnExecute = actConnectExecute
    end
  end
  object tblColumns: TFDMemTable
    Active = True
    FieldDefs = <
      item
        Name = 'field_name'
        DataType = ftString
        Size = 32
      end
      item
        Name = 'field_type'
        DataType = ftString
        Size = 32
      end
      item
        Name = 'column_caption'
        DataType = ftString
        Size = 32
      end
      item
        Name = 'input_caption'
        DataType = ftString
        Size = 32
      end
      item
        Name = 'is_gui'
        DataType = ftBoolean
      end
      item
        Name = 'input_type'
        DataType = ftString
        Size = 32
      end
      item
        Name = 'is_numeric'
        DataType = ftBoolean
      end>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 512
    Top = 48
    object tblColumnsfield_name: TStringField
      FieldName = 'field_name'
      Size = 32
    end
    object tblColumnsfield_type: TStringField
      FieldName = 'field_type'
      Size = 32
    end
    object tblColumnscolumn_caption: TStringField
      FieldName = 'column_caption'
      Size = 32
    end
    object tblColumnsinput_caption: TStringField
      FieldName = 'input_caption'
      Size = 32
    end
    object tblColumnsis_gui: TBooleanField
      FieldName = 'is_gui'
    end
    object tblColumnsinput_type: TStringField
      DisplayWidth = 32
      FieldName = 'input_type'
      Size = 32
    end
    object tblColumnsis_numeric: TBooleanField
      FieldName = 'is_numeric'
    end
  end
  object dsColumns: TDataSource
    DataSet = tblColumns
    Left = 568
    Top = 48
  end
end

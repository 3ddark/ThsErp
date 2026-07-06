object frmSysGridColumn: TfrmSysGridColumn
  Left = 0
  Top = 0
  Caption = 'System Grid Column'
  ClientHeight = 480
  ClientWidth = 743
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 743
    Height = 480
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 624
    object lblTableName: TLabel
      Left = 19
      Top = 16
      Width = 69
      Height = 13
      Alignment = taRightJustify
      Caption = 'Table Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblColumnName: TLabel
      Left = 10
      Top = 48
      Width = 78
      Height = 13
      Alignment = taRightJustify
      Caption = 'Column Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblColumnOrder: TLabel
      Left = 11
      Top = 80
      Width = 77
      Height = 13
      Alignment = taRightJustify
      Caption = 'Column Order'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblColumnWidth: TLabel
      Left = 229
      Top = 80
      Width = 79
      Height = 13
      Alignment = taRightJustify
      Caption = 'Column Width'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDataFormat: TLabel
      Left = 447
      Top = 80
      Width = 70
      Height = 13
      Alignment = taRightJustify
      Caption = 'Data Format'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMinValue: TLabel
      Left = 322
      Top = 112
      Width = 57
      Height = 13
      Alignment = taRightJustify
      Caption = 'Min Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMinValueColor: TLabel
      Left = 513
      Top = 112
      Width = 90
      Height = 13
      Alignment = taRightJustify
      Caption = 'Min Value Color'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMaxValue: TLabel
      Left = 28
      Top = 144
      Width = 60
      Height = 13
      Alignment = taRightJustify
      Caption = 'Max Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMaxValueColor: TLabel
      Left = 215
      Top = 144
      Width = 93
      Height = 13
      Alignment = taRightJustify
      Caption = 'Max Value Color'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMaxValuePercent: TLabel
      Left = 444
      Top = 144
      Width = 73
      Height = 13
      Alignment = taRightJustify
      Caption = 'Max % Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblBarColor: TLabel
      Left = 35
      Top = 176
      Width = 53
      Height = 13
      Alignment = taRightJustify
      Caption = 'Bar Color'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblBarBgColor: TLabel
      Left = 234
      Top = 176
      Width = 74
      Height = 13
      Alignment = taRightJustify
      Caption = 'Bar BG Color'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblBarTextColor: TLabel
      Left = 435
      Top = 176
      Width = 82
      Height = 13
      Alignment = taRightJustify
      Caption = 'Bar Text Color'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTableName: TEdit
      Left = 94
      Top = 12
      Width = 500
      Height = 23
      TabOrder = 0
    end
    object edtColumnName: TEdit
      Left = 94
      Top = 44
      Width = 500
      Height = 23
      TabOrder = 1
    end
    object edtColumnOrder: TEdit
      Left = 94
      Top = 76
      Width = 120
      Height = 23
      TabOrder = 2
    end
    object edtColumnWidth: TEdit
      Left = 314
      Top = 76
      Width = 120
      Height = 23
      TabOrder = 3
    end
    object edtDataFormat: TEdit
      Left = 523
      Top = 76
      Width = 80
      Height = 23
      TabOrder = 4
    end
    object chkIsShow: TCheckBox
      Left = 15
      Top = 112
      Width = 120
      Height = 17
      Caption = 'Is Show'
      TabOrder = 5
    end
    object chkIsShowHelper: TCheckBox
      Left = 150
      Top = 112
      Width = 150
      Height = 17
      Caption = 'Is Show Helper'
      TabOrder = 6
    end
    object edtMinValue: TEdit
      Left = 385
      Top = 108
      Width = 120
      Height = 23
      TabOrder = 7
    end
    object edtMinValueColor: TEdit
      Left = 609
      Top = 108
      Width = 80
      Height = 23
      TabOrder = 8
    end
    object edtMaxValue: TEdit
      Left = 94
      Top = 140
      Width = 120
      Height = 23
      TabOrder = 9
    end
    object edtMaxValueColor: TEdit
      Left = 314
      Top = 140
      Width = 120
      Height = 23
      TabOrder = 10
    end
    object edtMaxValuePercent: TEdit
      Left = 523
      Top = 140
      Width = 80
      Height = 23
      TabOrder = 11
    end
    object edtBarColor: TEdit
      Left = 94
      Top = 172
      Width = 120
      Height = 23
      TabOrder = 12
    end
    object edtBarBkColor: TEdit
      Left = 314
      Top = 172
      Width = 120
      Height = 23
      TabOrder = 13
    end
    object edtBarTextColor: TEdit
      Left = 523
      Top = 172
      Width = 80
      Height = 23
      TabOrder = 14
    end
  end
end

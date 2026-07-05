object frmSysGridColumn: TfrmSysGridColumn
  Left = 0
  Top = 0
  Caption = ''System Grid Column'
  ClientHeight = 480
  ClientWidth = 624
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
    Width = 624
    Height = 480
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 624
    ExplicitHeight = 480
    object lblTableName: TLabel
      Left = 15
      Top = 16
      Width = 73
      Height = 13
      Alignment = taRightJustify
      Caption = 'Table Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtTableName: TEdit
      Left = 94
      Top = 12
      Width = 500
      Height = 23
      TabOrder = 0
    end
    object lblColumnName: TLabel
      Left = 17
      Top = 48
      Width = 71
      Height = 13
      Alignment = taRightJustify
      Caption = 'Column Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtColumnName: TEdit
      Left = 94
      Top = 44
      Width = 500
      Height = 23
      TabOrder = 1
    end
    object lblColumnOrder: TLabel
      Left = 18
      Top = 80
      Width = 70
      Height = 13
      Alignment = taRightJustify
      Caption = 'Column Order'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtColumnOrder: TEdit
      Left = 94
      Top = 76
      Width = 120
      Height = 23
      TabOrder = 2
    end
    object lblColumnWidth: TLabel
      Left = 235
      Top = 80
      Width = 73
      Height = 13
      Alignment = taRightJustify
      Caption = 'Column Width'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtColumnWidth: TEdit
      Left = 314
      Top = 76
      Width = 120
      Height = 23
      TabOrder = 3
    end
    object lblDataFormat: TLabel
      Left = 450
      Top = 80
      Width = 67
      Height = 13
      Alignment = taRightJustify
      Caption = 'Data Format'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
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
    object lblMinValue: TLabel
      Left = 320
      Top = 112
      Width = 59
      Height = 13
      Alignment = taRightJustify
      Caption = 'Min Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtMinValue: TEdit
      Left = 385
      Top = 108
      Width = 120
      Height = 23
      TabOrder = 7
    end
    object lblMinValueColor: TLabel
      Left = 520
      Top = 112
      Width = 83
      Height = 13
      Alignment = taRightJustify
      Caption = 'Min Value Color'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtMinValueColor: TEdit
      Left = 609
      Top = 108
      Width = 8
      Height = 23
      TabOrder = 8
    end
    object lblMaxValue: TLabel
      Left = 15
      Top = 144
      Width = 73
      Height = 13
      Alignment = taRightJustify
      Caption = 'Max Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtMaxValue: TEdit
      Left = 94
      Top = 140
      Width = 120
      Height = 23
      TabOrder = 9
    end
    object lblMaxValueColor: TLabel
      Left = 235
      Top = 144
      Width = 73
      Height = 13
      Alignment = taRightJustify
      Caption = 'Max Value Color'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtMaxValueColor: TEdit
      Left = 314
      Top = 140
      Width = 120
      Height = 23
      TabOrder = 10
    end
    object lblMaxValuePercent: TLabel
      Left = 450
      Top = 144
      Width = 67
      Height = 13
      Alignment = taRightJustify
      Caption = 'Max % Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtMaxValuePercent: TEdit
      Left = 523
      Top = 140
      Width = 80
      Height = 23
      TabOrder = 11
    end
    object lblBarColor: TLabel
      Left = 15
      Top = 176
      Width = 73
      Height = 13
      Alignment = taRightJustify
      Caption = 'Bar Color'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtBarColor: TEdit
      Left = 94
      Top = 172
      Width = 120
      Height = 23
      TabOrder = 12
    end
    object lblBarBgColor: TLabel
      Left = 235
      Top = 176
      Width = 73
      Height = 13
      Alignment = taRightJustify
      Caption = 'Bar BG Color'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtBarBkColor: TEdit
      Left = 314
      Top = 172
      Width = 120
      Height = 23
      TabOrder = 13
    end
    object lblBarTextColor: TLabel
      Left = 450
      Top = 176
      Width = 67
      Height = 13
      Alignment = taRightJustify
      Caption = 'Bar Text Color'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
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

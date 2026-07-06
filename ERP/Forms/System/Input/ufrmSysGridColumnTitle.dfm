object frmSysGridColumnTitle: TfrmSysGridColumnTitle
  Left = 0
  Top = 0
  Caption = 'System Grid Column Title'
  ClientHeight = 180
  ClientWidth = 520
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
    Width = 520
    Height = 180
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 520
    ExplicitHeight = 180
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
      Width = 400
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
      Width = 400
      Height = 23
      TabOrder = 1
    end
    object lblLngCode: TLabel
      Left = 25
      Top = 80
      Width = 63
      Height = 13
      Alignment = taRightJustify
      Caption = 'Language'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtLngCode: TEdit
      Left = 94
      Top = 76
      Width = 80
      Height = 23
      TabOrder = 2
    end
    object lblColumnLabel: TLabel
      Left = 190
      Top = 80
      Width = 84
      Height = 13
      Alignment = taRightJustify
      Caption = 'Column Label'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtColumnLabel: TEdit
      Left = 280
      Top = 76
      Width = 214
      Height = 23
      TabOrder = 3
    end
  end
end

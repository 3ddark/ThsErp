object frmGridColumnTitle: TfrmGridColumnTitle
  Left = 0
  Top = 0
  Caption = 'Sutun Baslik Kayit'
  ClientHeight = 157
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 157
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 174
    object lblTableName: TLabel
      Left = 77
      Top = 6
      Width = 51
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Tablo Adi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblColumnName: TLabel
      Left = 87
      Top = 29
      Width = 41
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Kolon Adi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblLngCode: TLabel
      Left = 95
      Top = 52
      Width = 33
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Dil'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblColumnLabel: TLabel
      Left = 70
      Top = 75
      Width = 58
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Kolon Etiket'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtTableName: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 23
      TabOrder = 0
    end
    object edtColumnName: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 23
      TabOrder = 1
    end
    object edtLngCode: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 23
      TabOrder = 2
    end
    object edtColumnLabel: TEdit
      Left = 132
      Top = 71
      Width = 333
      Height = 23
      TabOrder = 3
    end
  end
end

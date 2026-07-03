object frmAccExchangeRate: TfrmAccExchangeRate
  Left = 0
  Top = 0
  Caption = 'frmAccExchangeRate'
  ClientHeight = 167
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
    Height = 167
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 165
    object lbltarih: TLabel
      Left = 62
      Top = 11
      Width = 66
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Date'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblpara_birimi: TLabel
      Left = 35
      Top = 38
      Width = 93
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Currency'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblkur: TLabel
      Left = 80
      Top = 65
      Width = 48
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Rate'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edttarih: TEdit
      Left = 132
      Top = 7
      Width = 120
      Height = 23
      TabOrder = 0
    end
    object edtpara_birimi: TEdit
      Left = 132
      Top = 34
      Width = 250
      Height = 23
      ReadOnly = True
      TabOrder = 1
    end
    object edtkur: TEdit
      Left = 132
      Top = 61
      Width = 120
      Height = 23
      TabOrder = 2
    end
    object btnpara_sec: TButton
      Left = 388
      Top = 30
      Width = 77
      Height = 25
      Caption = 'Select'
      TabOrder = 3
    end
  end
end

object frmAccBankBranch: TfrmAccBankBranch
  Left = 0
  Top = 0
  Caption = 'frmAccBankBranch'
  ClientHeight = 197
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
    Height = 197
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 195
    object lblsube_kodu: TLabel
      Left = 36
      Top = 11
      Width = 92
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = '#285;ube Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblsube_adi: TLabel
      Left = 45
      Top = 38
      Width = 83
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = '#285;ube Ad'#305'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblbanka: TLabel
      Left = 54
      Top = 65
      Width = 74
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Banka'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblsehir: TLabel
      Left = 52
      Top = 97
      Width = 76
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Sehir'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtsube_kodu: TEdit
      Left = 132
      Top = 7
      Width = 120
      Height = 23
      TabOrder = 0
    end
    object edtsube_adi: TEdit
      Left = 132
      Top = 34
      Width = 333
      Height = 23
      TabOrder = 1
    end
    object edtbanka_adi: TEdit
      Left = 132
      Top = 61
      Width = 250
      Height = 23
      ReadOnly = True
      TabOrder = 2
    end
    object edtsehir_adi: TEdit
      Left = 132
      Top = 93
      Width = 250
      Height = 23
      ReadOnly = True
      TabOrder = 3
    end
    object btnbanka_sec: TButton
      Left = 388
      Top = 57
      Width = 77
      Height = 25
      Caption = 'Se'#287...'
      TabOrder = 4
    end
    object btnsehir_sec: TButton
      Left = 388
      Top = 89
      Width = 77
      Height = 25
      Caption = 'Se'#287...'
      TabOrder = 5
    end
  end
end

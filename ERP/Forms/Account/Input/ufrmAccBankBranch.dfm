object frmAccBankBranch: TfrmAccBankBranch
  Left = 0
  Top = 0
  Caption = 'Banka '#197#158'ubesi'
  ClientHeight = 160
  ClientWidth = 500
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
    Width = 500
    Height = 160
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 158
    object lblsube_kodu: TLabel
      Left = 65
      Top = 11
      Width = 63
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = #197#158'ube Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblsube_adi: TLabel
      Left = 64
      Top = 38
      Width = 64
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = #197#158'ube Ad'#196#177
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblbanka: TLabel
      Left = 91
      Top = 65
      Width = 37
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
      Left = 98
      Top = 92
      Width = 30
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = #197#158'ehir'
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
      Width = 333
      Height = 23
      TabOrder = 2
    end
    object edtsehir_adi: TEdit
      Left = 132
      Top = 88
      Width = 333
      Height = 23
      TabOrder = 3
    end
  end
end

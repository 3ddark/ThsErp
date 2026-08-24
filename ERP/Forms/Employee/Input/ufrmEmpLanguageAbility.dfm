object frmEmpLanguageAbility: TfrmEmpLanguageAbility
  Left = 0
  Top = 0
  Caption = 'Personel Dil Yetkinliği'
  ClientHeight = 250
  ClientWidth = 450
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
    Width = 450
    Height = 250
    Align = alClient
    TabOrder = 0
    object lblPersonelId: TLabel
      Left = 20
      Top = 30
      Width = 90
      Height = 15
      Alignment = taRightJustify
      Caption = 'Personel'
    end
    object edtPersonelId: TEdit
      Left = 120
      Top = 27
      Width = 280
      Height = 23
      TabOrder = 0
    end
    object lblLisanId: TLabel
      Left = 20
      Top = 65
      Width = 90
      Height = 15
      Alignment = taRightJustify
      Caption = 'Yabancı Dil'
    end
    object edtLisanId: TEdit
      Left = 120
      Top = 62
      Width = 280
      Height = 23
      TabOrder = 1
    end
    object lblOkumaId: TLabel
      Left = 20
      Top = 100
      Width = 90
      Height = 15
      Alignment = taRightJustify
      Caption = 'Okuma'
    end
    object edtOkumaId: TEdit
      Left = 120
      Top = 97
      Width = 280
      Height = 23
      TabOrder = 2
    end
    object lblYazmaId: TLabel
      Left = 20
      Top = 135
      Width = 90
      Height = 15
      Alignment = taRightJustify
      Caption = 'Yazma'
    end
    object edtYazmaId: TEdit
      Left = 120
      Top = 132
      Width = 280
      Height = 23
      TabOrder = 3
    end
    object lblKonusmaId: TLabel
      Left = 20
      Top = 170
      Width = 90
      Height = 15
      Alignment = taRightJustify
      Caption = 'Konuşma'
    end
    object edtKonusmaId: TEdit
      Left = 120
      Top = 167
      Width = 280
      Height = 23
      TabOrder = 4
    end
  end
end

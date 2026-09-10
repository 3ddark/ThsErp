object frmSysCountry: TfrmSysCountry
  Left = 0
  Top = 0
  Caption = 'System Country'
  ClientHeight = 223
  ClientWidth = 477
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 14
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 477
    Height = 223
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 484
    ExplicitHeight = 213
    object lblCountryCode: TLabel
      Left = 72
      Top = 6
      Width = 56
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = #220'lke Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblISOYear: TLabel
      Left = 92
      Top = 100
      Width = 36
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'ISO Yil'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblISOCCTLD: TLabel
      Left = 70
      Top = 123
      Width = 58
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'ISO CCTLD'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblIsEuMember: TLabel
      Left = 79
      Top = 143
      Width = 49
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'AB '#220'yesi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtCountryCode: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      TabOrder = 0
    end
    object edtISOYear: TEdit
      Left = 132
      Top = 96
      Width = 333
      Height = 22
      TabOrder = 2
    end
    object edtISOCCTLD: TEdit
      Left = 132
      Top = 119
      Width = 333
      Height = 22
      TabOrder = 3
    end
    object chkIsEuMember: TCheckBox
      Left = 132
      Top = 142
      Width = 333
      Height = 17
      TabOrder = 4
    end
    object scrlbxTranslations: TScrollBox
      Left = 8
      Top = 24
      Width = 462
      Height = 72
      HorzScrollBar.Visible = False
      TabOrder = 1
    end
  end
end

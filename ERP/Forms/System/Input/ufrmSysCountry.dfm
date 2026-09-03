object frmSysCountry: TfrmSysCountry
  Left = 0
  Top = 0
  Caption = 'System Country'
  ClientHeight = 220
  ClientWidth = 500
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
    Width = 500
    Height = 220
    Align = alClient
    TabOrder = 0
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
    object lblCountryName_en_US: TLabel
      Left = 35
      Top = 29
      Width = 93
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = #220'lke Ad'#305' (en-US)'
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
      Top = 76
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
      Top = 99
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
      Top = 119
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
    object lblCountryName_tr_TR: TLabel
      Left = 39
      Top = 52
      Width = 89
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = #220'lke Ad'#305' (tr-TR)'
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
    object edtCountryName_en_US: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      TabOrder = 1
    end
    object edtISOYear: TEdit
      Left = 132
      Top = 72
      Width = 333
      Height = 22
      TabOrder = 3
    end
    object edtISOCCTLD: TEdit
      Left = 132
      Top = 95
      Width = 333
      Height = 22
      TabOrder = 4
    end
    object chkIsEuMember: TCheckBox
      Left = 132
      Top = 118
      Width = 333
      Height = 17
      TabOrder = 5
    end
    object edtCountryName_tr_TR: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      TabOrder = 2
    end
  end
end

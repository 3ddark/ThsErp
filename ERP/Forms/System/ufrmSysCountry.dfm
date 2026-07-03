object frmSysCountry: TfrmSysCountry
  Left = 0
  Top = 0
  Caption = 'Ulke Kayit'
  ClientHeight = 182
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
    Height = 182
    Align = alClient
    TabOrder = 0
    object lblCountryCode: TLabel
      Left = 51
      Top = 6
      Width = 77
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Ulke Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblCountryName: TLabel
      Left = 48
      Top = 29
      Width = 80
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Ulke Adi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblISOYear: TLabel
      Left = 76
      Top = 52
      Width = 52
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'ISO Yil'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblISOCCTLD: TLabel
      Left = 62
      Top = 75
      Width = 66
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'ISO CCTLD'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblIsEuMember: TLabel
      Left = 62
      Top = 95
      Width = 66
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'AB Üyesi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtCountryCode: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 23
      TabOrder = 0
    end
    object edtCountryName: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 23
      TabOrder = 1
    end
    object edtISOYear: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 23
      TabOrder = 2
    end
    object edtISOCCTLD: TEdit
      Left = 132
      Top = 71
      Width = 333
      Height = 23
      TabOrder = 3
    end
    object chkIsEuMember: TCheckBox
      Left = 132
      Top = 94
      Width = 333
      Height = 17
      TabOrder = 4
    end
  end
end

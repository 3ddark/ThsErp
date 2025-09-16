object frmSysCountry: TfrmSysCountry
  Left = 0
  Top = 0
  Caption = 'frmSysCountry'
  ClientHeight = 168
  ClientWidth = 467
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 467
    Height = 168
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 463
    ExplicitHeight = 104
    object lblcountry_code: TLabel
      Left = 27
      Top = 6
      Width = 77
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Country Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblcountry_name: TLabel
      Left = 24
      Top = 30
      Width = 80
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Country Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lbliso_year: TLabel
      Left = 52
      Top = 54
      Width = 52
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'ISO Year'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lbliso_cctld: TLabel
      Left = 38
      Top = 78
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
    object lblis_eu_member: TLabel
      Left = 38
      Top = 102
      Width = 66
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'EU Member'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtcountry_code: TEdit
      Left = 108
      Top = 2
      Width = 333
      Height = 23
      TabOrder = 0
    end
    object edtcountry_name: TEdit
      Left = 108
      Top = 26
      Width = 333
      Height = 23
      TabOrder = 1
    end
    object edtiso_year: TEdit
      Left = 108
      Top = 50
      Width = 333
      Height = 23
      TabOrder = 2
    end
    object edtiso_cctld: TEdit
      Left = 108
      Top = 74
      Width = 333
      Height = 23
      TabOrder = 3
    end
    object chkis_eu_member: TCheckBox
      Left = 108
      Top = 101
      Width = 333
      Height = 17
      TabOrder = 4
    end
  end
end

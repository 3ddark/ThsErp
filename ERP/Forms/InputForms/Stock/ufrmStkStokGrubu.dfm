inherited frmStkStokGrubu: TfrmStkStokGrubu
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Stok Grubu'
  ClientHeight = 276
  ClientWidth = 572
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 588
  ExplicitHeight = 315
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 572
    Height = 226
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 360
    ExplicitHeight = 242
    inherited pgcMain: TPageControl
      Width = 574
      Height = 230
      ExplicitWidth = 358
      ExplicitHeight = 240
      inherited tsMain: TTabSheet
        ExplicitWidth = 566
        ExplicitHeight = 202
        object lblstok_grubu: TLabel
          Left = 115
          Top = 5
          Width = 27
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grup'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkdv_orani: TLabel
          Left = 71
          Top = 27
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'KDV Oran'#305' %'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblalis_kodu: TLabel
          Left = 81
          Top = 49
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Al'#305#351' Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblalis_iade_kodu: TLabel
          Left = 52
          Top = 71
          Width = 90
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Al'#305#351' '#304'ade Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsatis_kodu: TLabel
          Left = 73
          Top = 93
          Width = 69
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305#351' Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsatis_iade_kodu: TLabel
          Left = 44
          Top = 115
          Width = 98
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305#351' '#304'ade Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblihracat_kodu: TLabel
          Left = 59
          Top = 137
          Width = 83
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304'hracat Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblhammadde_kodu: TLabel
          Left = 36
          Top = 159
          Width = 106
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Hammadde Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmamul_kodu: TLabel
          Left = 63
          Top = 181
          Width = 79
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mam'#252'l Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblalis_kodu_val: TLabel
          Left = 226
          Top = 49
          Width = 51
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'Al'#305#351' Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblalis_iade_kodu_val: TLabel
          Left = 226
          Top = 71
          Width = 76
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'Al'#305#351' '#304'ade Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsatis_kodu_val: TLabel
          Left = 226
          Top = 93
          Width = 58
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305#351' Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsatis_iade_kodu_val: TLabel
          Left = 226
          Top = 115
          Width = 83
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305#351' '#304'ade Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblihracat_kodu_val: TLabel
          Left = 226
          Top = 137
          Width = 70
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = #304'hracat Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblhammadde_kodu_val: TLabel
          Left = 226
          Top = 159
          Width = 88
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'Hammadde Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmamul_kodu_val: TLabel
          Left = 226
          Top = 181
          Width = 65
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'Mam'#252'l Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtstok_grubu: TEdit
          Left = 146
          Top = 2
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtkdv_orani: TEdit
          Left = 146
          Top = 24
          Width = 80
          Height = 21
          TabOrder = 1
        end
        object edtalis_kodu: TEdit
          Left = 146
          Top = 46
          Width = 80
          Height = 21
          TabOrder = 2
        end
        object edtalis_iade_kodu: TEdit
          Left = 146
          Top = 68
          Width = 80
          Height = 21
          TabOrder = 3
        end
        object edtsatis_kodu: TEdit
          Left = 146
          Top = 90
          Width = 80
          Height = 21
          TabOrder = 4
        end
        object edtsatis_iade_kodu: TEdit
          Left = 146
          Top = 112
          Width = 80
          Height = 21
          TabOrder = 5
        end
        object edtihracat_kodu: TEdit
          Left = 146
          Top = 134
          Width = 80
          Height = 21
          TabOrder = 6
        end
        object edthammadde_kodu: TEdit
          Left = 146
          Top = 156
          Width = 80
          Height = 21
          TabOrder = 7
        end
        object edtmamul_kodu: TEdit
          Left = 146
          Top = 178
          Width = 80
          Height = 21
          TabOrder = 8
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 228
    Width = 568
    ExplicitTop = 246
    ExplicitWidth = 360
    inherited btnAccept: TButton
      Left = 363
      ExplicitLeft = 151
    end
    inherited btnClose: TButton
      Left = 467
      ExplicitLeft = 255
    end
  end
  inherited stbBase: TStatusBar
    Top = 258
    Width = 572
    ExplicitTop = 276
    ExplicitWidth = 364
  end
end

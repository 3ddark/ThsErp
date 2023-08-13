inherited frmStkGrup: TfrmStkGrup
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Stok Grubu'
  ClientHeight = 367
  ClientWidth = 538
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 552
  ExplicitHeight = 402
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 538
    Height = 317
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 564
    ExplicitHeight = 266
    inherited pgcMain: TPageControl
      Width = 538
      Height = 317
      ExplicitWidth = 564
      ExplicitHeight = 266
      inherited tsMain: TTabSheet
        ExplicitWidth = 530
        ExplicitHeight = 289
        object lblgrup: TLabel
          Left = 155
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
          Left = 111
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
        object lblalis_iade_hesap_kodu: TLabel
          Left = 35
          Top = 203
          Width = 150
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Al'#305#351' '#304'ade Vergi Hesap Kodu'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblalis_hesap_kodu: TLabel
          Left = 64
          Top = 181
          Width = 121
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Al'#305#351' Vergi Hesap Kodu'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsatis_iade_hesap_kodu: TLabel
          Left = 27
          Top = 115
          Width = 158
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305#351' '#304'ade Vergi Hesap Kodu'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsatis_hesap_kodu: TLabel
          Left = 56
          Top = 93
          Width = 129
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305#351' Vergi Hesap Kodu'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblalis_hesap_adi: TLabel
          Left = 277
          Top = 181
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
        object lblalis_iade_hesap_adi: TLabel
          Left = 277
          Top = 203
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
        object lblsatis_hesap_adi: TLabel
          Left = 277
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
        object lblsatis_iade_hesap_adi: TLabel
          Left = 277
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
        object lblihracat_iade_hesap_kodu: TLabel
          Left = 13
          Top = 159
          Width = 172
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304'hracat '#304'ade Vergi Hesap Kodu'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblihracat_hesap_kodu: TLabel
          Left = 42
          Top = 137
          Width = 143
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304'hracat Vergi Hesap Kodu'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblihracat_hesap_adi: TLabel
          Left = 277
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
        object lblihracat_iade_hesap_adi: TLabel
          Left = 277
          Top = 159
          Width = 95
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = #304'hracat '#304'ade Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblithalat_iade_hesap_adi: TLabel
          Left = 277
          Top = 247
          Width = 92
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = #304'thalat '#304'ade Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblithalat_hesap_adi: TLabel
          Left = 277
          Top = 225
          Width = 67
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = #304'thalat Hesab'#305
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblithalat_hesap_kodu: TLabel
          Left = 45
          Top = 225
          Width = 140
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304'thalat Vergi Hesap Kodu'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblithalat_iade_hesap_kodu: TLabel
          Left = 16
          Top = 247
          Width = 169
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304'thalat '#304'ade Vergi Hesap Kodu'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmamul_hesap_adi: TLabel
          Left = 277
          Top = 71
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
        object lblhammadde_hesap_adi: TLabel
          Left = 277
          Top = 49
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
        object lblhammadde_hesap_kodu: TLabel
          Left = 51
          Top = 49
          Width = 134
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Hammadde Hesap Kodu'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmamul_hesap_kodu: TLabel
          Left = 78
          Top = 71
          Width = 107
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mam'#252'l Hesap Kodu'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtgrup: TEdit
          Left = 186
          Top = 2
          Width = 311
          Height = 21
          TabOrder = 0
        end
        object edtkdv_orani: TEdit
          Left = 186
          Top = 24
          Width = 90
          Height = 21
          TabOrder = 1
        end
        object edtsatis_hesap_kodu: TEdit
          Left = 186
          Top = 90
          Width = 90
          Height = 21
          TabOrder = 4
        end
        object edtsatis_iade_hesap_kodu: TEdit
          Left = 186
          Top = 112
          Width = 90
          Height = 21
          TabOrder = 5
        end
        object edtalis_hesap_kodu: TEdit
          Left = 186
          Top = 178
          Width = 90
          Height = 21
          TabOrder = 8
        end
        object edtalis_iade_hesap_kodu: TEdit
          Left = 186
          Top = 200
          Width = 90
          Height = 21
          TabOrder = 9
        end
        object edtihracat_hesap_kodu: TEdit
          Left = 186
          Top = 134
          Width = 90
          Height = 21
          TabOrder = 6
        end
        object edtihracat_iade_hesap_kodu: TEdit
          Left = 186
          Top = 156
          Width = 90
          Height = 21
          TabOrder = 7
        end
        object edtithalat_hesap_kodu: TEdit
          Left = 186
          Top = 222
          Width = 90
          Height = 21
          TabOrder = 10
        end
        object edtithalat_iade_hesap_kodu: TEdit
          Left = 186
          Top = 244
          Width = 90
          Height = 21
          TabOrder = 11
        end
        object edthammadde_hesap_kodu: TEdit
          Left = 186
          Top = 46
          Width = 90
          Height = 21
          TabOrder = 2
        end
        object edtmamul_hesap_kodu: TEdit
          Left = 186
          Top = 68
          Width = 90
          Height = 21
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 319
    Width = 534
    ExplicitTop = 268
    ExplicitWidth = 560
    inherited btnAccept: TButton
      Left = 328
      ExplicitLeft = 354
    end
    inherited btnClose: TButton
      Left = 432
      ExplicitLeft = 458
    end
  end
  inherited stbBase: TStatusBar
    Top = 349
    Width = 538
    ExplicitTop = 298
    ExplicitWidth = 564
  end
end

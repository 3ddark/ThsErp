inherited frmSetChVergiOrani: TfrmSetChVergiOrani
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ayar Cari Hesap Vergi Oran'#305
  ClientHeight = 207
  ClientWidth = 539
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 553
  ExplicitHeight = 243
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 539
    Height = 157
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 537
    ExplicitHeight = 235
    inherited pgcMain: TPageControl
      Width = 539
      Height = 157
      ExplicitWidth = 537
      ExplicitHeight = 235
      inherited tsMain: TTabSheet
        ExplicitWidth = 531
        ExplicitHeight = 129
        object lblalis_iade_hesap_kodu: TLabel
          Left = 35
          Top = 94
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
          Top = 72
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
          Top = 50
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
          Top = 28
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
        object lblvergi_orani: TLabel
          Left = 123
          Top = 6
          Width = 62
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Vergi Oran'#305
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
          Top = 72
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
          Top = 94
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
          Top = 28
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
          Top = 50
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
        object edtvergi_orani: TEdit
          Left = 186
          Top = 3
          Width = 90
          Height = 21
          TabOrder = 0
        end
        object edtsatis_hesap_kodu: TEdit
          Left = 186
          Top = 25
          Width = 90
          Height = 21
          TabOrder = 1
        end
        object edtsatis_iade_hesap_kodu: TEdit
          Left = 186
          Top = 47
          Width = 90
          Height = 21
          TabOrder = 2
        end
        object edtalis_hesap_kodu: TEdit
          Left = 186
          Top = 69
          Width = 90
          Height = 21
          TabOrder = 3
        end
        object edtalis_iade_hesap_kodu: TEdit
          Left = 186
          Top = 91
          Width = 90
          Height = 21
          TabOrder = 4
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 159
    Width = 535
    ExplicitTop = 237
    ExplicitWidth = 533
    inherited btnAccept: TButton
      Left = 329
      TabOrder = 2
      ExplicitLeft = 327
    end
    inherited btnClose: TButton
      Left = 433
      ExplicitLeft = 431
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 189
    Width = 539
    ExplicitTop = 267
    ExplicitWidth = 537
  end
end

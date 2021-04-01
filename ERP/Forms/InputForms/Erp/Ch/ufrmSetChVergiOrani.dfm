inherited frmSetChVergiOrani: TfrmSetChVergiOrani
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ayar Vergi Oran'#305
  ClientHeight = 201
  ClientWidth = 555
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 561
  ExplicitHeight = 230
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 551
    Height = 149
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 420
    ExplicitHeight = 166
    inherited pgcMain: TPageControl
      Width = 549
      Height = 147
      ExplicitWidth = 418
      ExplicitHeight = 164
      inherited tsMain: TTabSheet
        ExplicitWidth = 410
        ExplicitHeight = 136
        object lblalis_iade_kodu: TLabel
          Left = 27
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
        object lblalis_kodu: TLabel
          Left = 56
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
        object lblsatis_iade_kodu: TLabel
          Left = 19
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
        object lblsatis_kodu: TLabel
          Left = 48
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
          Left = 115
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
        object lblalis_hesabi_val: TLabel
          Left = 251
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
        object lblalis_iade_hesabi_val: TLabel
          Left = 251
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
        object lblsatis_hesabi_val: TLabel
          Left = 251
          Top = 29
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
        object lblsatis_iade_hesabi_val: TLabel
          Left = 251
          Top = 51
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
          Left = 178
          Top = 3
          Width = 72
          Height = 21
          TabOrder = 0
        end
        object edtsatis_kodu: TEdit
          Left = 178
          Top = 25
          Width = 72
          Height = 21
          TabOrder = 1
        end
        object edtsatis_iade_kodu: TEdit
          Left = 178
          Top = 47
          Width = 72
          Height = 21
          TabOrder = 2
        end
        object edtalis_kodu: TEdit
          Left = 178
          Top = 69
          Width = 72
          Height = 21
          TabOrder = 3
        end
        object edtalis_iade_kodu: TEdit
          Left = 178
          Top = 91
          Width = 72
          Height = 21
          TabOrder = 4
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 153
    Width = 551
    ExplicitTop = 170
    ExplicitWidth = 420
    inherited btnAccept: TButton
      Left = 342
      ExplicitLeft = 211
    end
    inherited btnClose: TButton
      Left = 446
      ExplicitLeft = 315
    end
  end
  inherited stbBase: TStatusBar
    Top = 183
    Width = 555
    ExplicitTop = 200
    ExplicitWidth = 424
  end
end

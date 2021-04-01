inherited frmSetChHesapTipi: TfrmSetChHesapTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ayar Hesap Tipi'
  ClientHeight = 190
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 219
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 138
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 87
    inherited pgcMain: TPageControl
      Width = 338
      Height = 136
      ExplicitWidth = 338
      ExplicitHeight = 85
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 57
        object lblDeger: TLabel
          Left = 56
          Top = 6
          Width = 34
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'De'#287'er'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_ana_hesap: TLabel
          Left = 30
          Top = 27
          Width = 60
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ana Hesap'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_ara_hesap: TLabel
          Left = 32
          Top = 47
          Width = 58
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ara Hesap'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_son_hesap: TLabel
          Left = 31
          Top = 67
          Width = 59
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Son Hesap'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtDeger: TEdit
          Left = 94
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object chkis_ana_hesap: TCheckBox
          Left = 94
          Top = 26
          Width = 200
          Height = 17
          TabOrder = 1
        end
        object chkis_ara_hesap: TCheckBox
          Left = 94
          Top = 46
          Width = 200
          Height = 17
          TabOrder = 2
        end
        object chkis_son_hesap: TCheckBox
          Left = 94
          Top = 66
          Width = 200
          Height = 17
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 142
    Width = 340
    ExplicitTop = 91
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      ExplicitLeft = 131
    end
    inherited btnClose: TButton
      Left = 235
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 172
    Width = 344
    ExplicitTop = 135
    ExplicitWidth = 344
  end
end

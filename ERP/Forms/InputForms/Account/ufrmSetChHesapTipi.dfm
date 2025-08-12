inherited frmSetChHesapTipi: TfrmSetChHesapTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ayar Hesap Tipi'
  ClientHeight = 111
  ClientWidth = 342
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 358
  ExplicitHeight = 150
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 342
    Height = 61
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 138
    inherited pgcMain: TPageControl
      Width = 342
      Height = 61
      ExplicitWidth = 338
      ExplicitHeight = 136
      inherited tsMain: TTabSheet
        ExplicitWidth = 334
        ExplicitHeight = 33
        object lblhesap_tipi: TLabel
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
        object edthesap_tipi: TEdit
          Left = 94
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 63
    Width = 338
    ExplicitTop = 142
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
    Top = 93
    Width = 342
    ExplicitTop = 172
    ExplicitWidth = 344
  end
end

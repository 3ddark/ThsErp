inherited frmAyarCekSenetTahsilOdemeTipi: TfrmAyarCekSenetTahsilOdemeTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = #199'ek Senet Tahsil '#214'deme Tipi'
  ClientHeight = 137
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 166
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 85
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 85
    inherited pgcMain: TPageControl
      Width = 338
      Height = 83
      ExplicitWidth = 338
      ExplicitHeight = 83
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 55
        object lblDeger: TLabel
          Left = 41
          Top = 6
          Width = 35
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'De'#287'er'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtDeger: TEdit
          Left = 80
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 89
    Width = 340
    ExplicitTop = 89
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
    Top = 119
    Width = 344
    ExplicitTop = 119
    ExplicitWidth = 344
  end
end

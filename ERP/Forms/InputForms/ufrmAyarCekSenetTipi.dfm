inherited frmAyarCekSenetTipi: TfrmAyarCekSenetTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = #199'ek Senet Tipi'
  ClientHeight = 121
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 150
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 69
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 69
    inherited pgcMain: TPageControl
      Width = 338
      Height = 67
      ExplicitWidth = 338
      ExplicitHeight = 67
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 39
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
    Top = 73
    Width = 340
    ExplicitTop = 73
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
    Top = 103
    Width = 344
    ExplicitTop = 103
    ExplicitWidth = 344
  end
end

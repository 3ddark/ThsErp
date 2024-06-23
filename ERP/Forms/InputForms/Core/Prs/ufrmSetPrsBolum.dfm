inherited frmSetPrsBolum: TfrmSetPrsBolum
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel B'#246'l'#252'm'
  ClientHeight = 114
  ClientWidth = 340
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 356
  ExplicitHeight = 153
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 340
    Height = 64
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 338
    ExplicitHeight = 61
    inherited pgcMain: TPageControl
      Width = 340
      Height = 64
      ExplicitWidth = 338
      ExplicitHeight = 61
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 332
        ExplicitHeight = 35
        object lblbolum: TLabel
          Left = 49
          Top = 6
          Width = 35
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'B'#246'l'#252'm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtbolum: TEdit
          Left = 88
          Top = 3
          Width = 239
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 66
    Width = 336
    ExplicitTop = 63
    ExplicitWidth = 334
    inherited btnAccept: TButton
      Left = 130
      ExplicitLeft = 128
    end
    inherited btnClose: TButton
      Left = 234
      ExplicitLeft = 232
    end
  end
  inherited stbBase: TStatusBar
    Top = 96
    Width = 340
    ExplicitTop = 93
    ExplicitWidth = 338
  end
end

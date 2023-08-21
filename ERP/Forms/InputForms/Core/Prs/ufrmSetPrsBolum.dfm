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
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 64
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 64
    inherited pgcMain: TPageControl
      Width = 342
      Height = 67
      ExplicitWidth = 340
      ExplicitHeight = 64
      inherited tsMain: TTabSheet
        ExplicitWidth = 334
        ExplicitHeight = 39
        object lblbolum: TLabel
          Left = 40
          Top = 6
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Section'
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
    ExplicitTop = 66
    ExplicitWidth = 336
    inherited btnAccept: TButton
      Left = 132
      ExplicitLeft = 130
    end
    inherited btnClose: TButton
      Left = 236
      ExplicitLeft = 234
    end
  end
  inherited stbBase: TStatusBar
    Top = 96
    Width = 340
    ExplicitTop = 96
    ExplicitWidth = 340
  end
end

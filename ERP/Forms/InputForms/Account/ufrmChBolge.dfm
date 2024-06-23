inherited frmChBolge: TfrmChBolge
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'B'#246'lge'
  ClientHeight = 113
  ClientWidth = 340
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 356
  ExplicitHeight = 152
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 340
    Height = 63
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 98
    inherited pgcMain: TPageControl
      Width = 340
      Height = 63
      ExplicitWidth = 338
      ExplicitHeight = 96
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 332
        ExplicitHeight = 34
        object lblbolge: TLabel
          Left = 66
          Top = 5
          Width = 31
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'B'#246'lge'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtbolge: TEdit
          Left = 101
          Top = 2
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 65
    Width = 336
    ExplicitTop = 102
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      ExplicitLeft = 131
      ExplicitHeight = 22
    end
    inherited btnClose: TButton
      Left = 235
      ExplicitLeft = 235
      ExplicitHeight = 22
    end
    inherited btnDelete: TButton
      ExplicitLeft = 20
      ExplicitHeight = 22
    end
  end
  inherited stbBase: TStatusBar
    Top = 95
    Width = 340
    ExplicitTop = 132
    ExplicitWidth = 344
  end
end

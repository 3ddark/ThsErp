inherited frmChBolge: TfrmChBolge
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'B'#246'lge'
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
    ExplicitHeight = 98
    inherited pgcMain: TPageControl
      Width = 338
      Height = 67
      ExplicitWidth = 338
      ExplicitHeight = 96
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 330
        ExplicitHeight = 68
        object lblbolge: TLabel
          Left = 64
          Top = 5
          Width = 33
          Height = 13
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
    Top = 73
    Width = 340
    ExplicitTop = 102
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      ExplicitLeft = 131
      ExplicitHeight = 22
    end
    inherited btnDelete: TButton
      ExplicitLeft = 20
      ExplicitHeight = 22
    end
    inherited btnClose: TButton
      Left = 235
      ExplicitLeft = 235
      ExplicitHeight = 22
    end
  end
  inherited stbBase: TStatusBar
    Top = 103
    Width = 344
    ExplicitTop = 132
    ExplicitWidth = 344
  end
end

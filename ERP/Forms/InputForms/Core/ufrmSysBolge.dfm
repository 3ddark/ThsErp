inherited frmSysBolge: TfrmSysBolge
  Caption = 'Sistem B'#246'lge'
  ClientHeight = 113
  ClientWidth = 340
  ExplicitWidth = 356
  ExplicitHeight = 152
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 63
    ExplicitWidth = 340
    ExplicitHeight = 63
    inherited pgcMain: TPageControl
      Width = 340
      Height = 63
      ExplicitWidth = 340
      ExplicitHeight = 63
      inherited tsMain: TTabSheet
        ExplicitWidth = 332
        ExplicitHeight = 35
        object lblbolge: TLabel
          Left = 73
          Top = 7
          Width = 31
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'B'#246'lge'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtbolge: TEdit
          Left = 110
          Top = 2
          Width = 195
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 65
    Width = 336
    ExplicitTop = 65
    ExplicitWidth = 336
    inherited btnAccept: TButton
      Left = 234
      TabOrder = 3
      ExplicitLeft = 234
    end
    inherited btnClose: TButton
      Left = 130
      TabOrder = 2
      ExplicitLeft = 130
    end
  end
  inherited stbBase: TStatusBar
    Top = 95
    Width = 340
    ExplicitTop = 95
    ExplicitWidth = 340
  end
end

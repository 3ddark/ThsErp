inherited frmSysBolge: TfrmSysBolge
  Caption = 'System Region'
  ClientHeight = 113
  ClientWidth = 340
  ExplicitWidth = 356
  ExplicitHeight = 152
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 63
    ExplicitWidth = 344
    ExplicitHeight = 71
    inherited pgcMain: TPageControl
      Width = 342
      Height = 67
      ExplicitWidth = 344
      ExplicitHeight = 71
      inherited tsMain: TTabSheet
        ExplicitWidth = 334
        ExplicitHeight = 39
        object lblregion: TLabel
          Left = 65
          Top = 7
          Width = 39
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Region'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtregion: TEdit
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
    ExplicitTop = 73
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 238
      TabOrder = 3
      ExplicitLeft = 238
    end
    inherited btnClose: TButton
      Left = 134
      TabOrder = 2
      ExplicitLeft = 134
    end
  end
  inherited stbBase: TStatusBar
    Top = 95
    Width = 340
    ExplicitTop = 103
    ExplicitWidth = 344
  end
end

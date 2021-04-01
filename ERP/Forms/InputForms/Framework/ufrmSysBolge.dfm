inherited frmSysBolge: TfrmSysBolge
  Caption = 'Sistem B'#246'lge'
  ClientHeight = 121
  ClientWidth = 344
  ExplicitWidth = 350
  ExplicitHeight = 150
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 69
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
        object lblbolge_adi: TLabel
          Left = 52
          Top = 7
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'B'#246'lge Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtbolge_adi: TEdit
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
    Top = 73
    Width = 340
    ExplicitTop = 73
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 235
      ExplicitLeft = 235
    end
    inherited btnClose: TButton
      Left = 131
      ExplicitLeft = 131
    end
  end
  inherited stbBase: TStatusBar
    Top = 103
    Width = 344
    ExplicitTop = 103
    ExplicitWidth = 344
  end
end

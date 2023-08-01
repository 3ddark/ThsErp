inherited frmSetEmpLeavingReason: TfrmSetEmpLeavingReason
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Ayr'#305'lma Nedeni'
  ClientHeight = 117
  ClientWidth = 342
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 358
  ExplicitHeight = 156
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 342
    Height = 67
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 55
    inherited pgcMain: TPageControl
      Width = 344
      Height = 71
      ExplicitWidth = 338
      ExplicitHeight = 53
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 43
        object lblayrilma_nedeni: TLabel
          Left = 47
          Top = 6
          Width = 85
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ayr'#305'lma Nedeni'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtayrilma_nedeni: TEdit
          Left = 130
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 69
    Width = 338
    ExplicitTop = 59
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
    Top = 99
    Width = 342
    ExplicitTop = 103
    ExplicitWidth = 344
  end
end

inherited frmSetStkUrunTipi: TfrmSetStkUrunTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = #220'r'#252'n Tipi'
  ClientHeight = 121
  ClientWidth = 356
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 362
  ExplicitHeight = 150
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 352
    Height = 69
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 352
    ExplicitHeight = 122
    inherited pgcMain: TPageControl
      Width = 350
      Height = 67
      ExplicitWidth = 350
      ExplicitHeight = 120
      inherited tsMain: TTabSheet
        ExplicitWidth = 342
        ExplicitHeight = 92
        object lblurun_tipi: TLabel
          Left = 83
          Top = 6
          Width = 53
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'r'#252'n Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edturun_tipi: TEdit
          Left = 140
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
    Width = 352
    ExplicitTop = 126
    ExplicitWidth = 352
    inherited btnAccept: TButton
      Left = 143
      ExplicitLeft = 143
    end
    inherited btnClose: TButton
      Left = 247
      ExplicitLeft = 247
    end
  end
  inherited stbBase: TStatusBar
    Top = 103
    Width = 356
    ExplicitTop = 156
    ExplicitWidth = 356
  end
end

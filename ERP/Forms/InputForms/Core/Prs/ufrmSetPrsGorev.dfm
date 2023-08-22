inherited frmSetPrsGorev: TfrmSetPrsGorev
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel G'#246'rev'
  ClientHeight = 121
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 150
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 344
    Height = 71
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 344
    ExplicitHeight = 71
    inherited pgcMain: TPageControl
      Width = 344
      Height = 71
      ExplicitWidth = 344
      ExplicitHeight = 71
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 43
        object lblgorev: TLabel
          Left = 41
          Top = 6
          Width = 35
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'G'#246'rev'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtgorev: TEdit
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
      Left = 134
      ExplicitLeft = 134
    end
    inherited btnClose: TButton
      Left = 238
      ExplicitLeft = 238
    end
  end
  inherited stbBase: TStatusBar
    Top = 103
    Width = 344
    ExplicitTop = 103
    ExplicitWidth = 344
  end
end

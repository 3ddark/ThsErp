inherited frmSetEinvFaturaTipi: TfrmSetEinvFaturaTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Fatura Tipi'
  ClientHeight = 121
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 360
  ExplicitHeight = 160
  TextHeight = 14
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
        ExplicitTop = 25
        ExplicitWidth = 336
        ExplicitHeight = 42
        object lblTip: TLabel
          Left = 43
          Top = 6
          Width = 17
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tip'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtTip: TEdit
          Left = 64
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

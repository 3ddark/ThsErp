inherited frmSetChFasonMarka: TfrmSetChFasonMarka
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Set Ch Fason Marka'
  ClientHeight = 121
  ClientWidth = 377
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 383
  ExplicitHeight = 150
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 373
    Height = 69
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 373
    ExplicitHeight = 101
    inherited pgcMain: TPageControl
      Width = 371
      Height = 67
      ExplicitWidth = 371
      ExplicitHeight = 99
      inherited tsMain: TTabSheet
        ExplicitWidth = 363
        ExplicitHeight = 71
        object lblfason_marka: TLabel
          Left = 42
          Top = 5
          Width = 74
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Fason Marka'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtfason_marka: TEdit
          Left = 122
          Top = 2
          Width = 240
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 73
    Width = 373
    ExplicitTop = 105
    ExplicitWidth = 373
    inherited btnAccept: TButton
      Left = 164
      ExplicitLeft = 164
    end
    inherited btnClose: TButton
      Left = 268
      ExplicitLeft = 268
    end
  end
  inherited stbBase: TStatusBar
    Top = 103
    Width = 377
    ExplicitTop = 149
    ExplicitWidth = 377
  end
end

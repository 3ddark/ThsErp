inherited frmSetChFirmaTuru: TfrmSetChFirmaTuru
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ayar Firma T'#252'r'#252
  ClientHeight = 121
  ClientWidth = 359
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 365
  ExplicitHeight = 150
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 355
    Height = 69
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 355
    ExplicitHeight = 55
    inherited pgcMain: TPageControl
      Width = 353
      Height = 67
      ExplicitWidth = 353
      ExplicitHeight = 53
      inherited tsMain: TTabSheet
        ExplicitWidth = 345
        ExplicitHeight = 25
        object lblfirma_turu: TLabel
          Left = 69
          Top = 7
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Firma T'#252'r'#252
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtfirma_turu: TEdit
          Left = 136
          Top = 4
          Width = 208
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 73
    Width = 355
    ExplicitTop = 59
    ExplicitWidth = 355
    inherited btnAccept: TButton
      Left = 146
      ExplicitLeft = 146
    end
    inherited btnClose: TButton
      Left = 250
      ExplicitLeft = 250
    end
  end
  inherited stbBase: TStatusBar
    Top = 103
    Width = 359
    ExplicitTop = 103
    ExplicitWidth = 359
  end
end

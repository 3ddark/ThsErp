inherited frmChTemsilciGrupTuru: TfrmChTemsilciGrupTuru
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Temilci Grup T'#252'r'#252
  ClientHeight = 131
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 350
  ExplicitHeight = 160
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 79
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 65
    inherited pgcMain: TPageControl
      Width = 338
      Height = 77
      ExplicitWidth = 338
      ExplicitHeight = 63
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 35
        object lbltemsilci_grup_turu: TLabel
          Left = 16
          Top = 6
          Width = 102
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Temilci Grup T'#252'r'#252
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edttemsilci_grup_turu: TEdit
          Left = 122
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 83
    Width = 340
    ExplicitTop = 69
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
    Top = 113
    Width = 344
    ExplicitTop = 113
    ExplicitWidth = 344
  end
end

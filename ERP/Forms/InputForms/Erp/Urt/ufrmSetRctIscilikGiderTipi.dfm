inherited frmSetRctIscilikGiderTipi: TfrmSetRctIscilikGiderTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Set '#304#351#231'ilik Gider Tipi'
  ClientHeight = 128
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 350
  ExplicitHeight = 157
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 76
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 62
    inherited pgcMain: TPageControl
      Width = 338
      Height = 74
      ExplicitWidth = 338
      ExplicitHeight = 60
      inherited tsMain: TTabSheet
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 330
        ExplicitHeight = 32
        object lblgider_tipi: TLabel
          Left = 14
          Top = 6
          Width = 56
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Gider Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtgider_tipi: TEdit
          Left = 74
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 80
    Width = 340
    ExplicitTop = 66
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
    Top = 110
    Width = 344
    ExplicitTop = 110
    ExplicitWidth = 344
  end
end

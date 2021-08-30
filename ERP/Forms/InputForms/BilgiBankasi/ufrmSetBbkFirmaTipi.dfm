inherited frmSetBbkFirmaTipi: TfrmSetBbkFirmaTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Bilgi Bankas'#305' Firma Tipi'
  ClientHeight = 121
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 150
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 69
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 92
    inherited pgcMain: TPageControl
      Width = 338
      Height = 67
      ExplicitWidth = 338
      ExplicitHeight = 90
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 62
        object lblfirma_tipi: TLabel
          Left = 81
          Top = 5
          Width = 56
          Height = 13
          Alignment = taRightJustify
          Caption = 'Firma Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtfirma_tipi: TEdit
          Left = 142
          Top = 2
          Width = 177
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 73
    Width = 340
    ExplicitTop = 96
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      Caption = 'KAYDET'
      ExplicitLeft = 131
    end
    inherited btnClose: TButton
      Left = 235
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 103
    Width = 344
    ExplicitTop = 126
    ExplicitWidth = 344
  end
  inherited AppEvntsBase: TApplicationEvents
    Left = 376
    Top = 40
  end
  inherited dlgPntBase: TPrintDialog
    Left = 464
    Top = 40
  end
  inherited pmLabels: TPopupMenu
    Left = 400
    Top = 88
  end
end

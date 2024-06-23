inherited frmSetBbkFirmaTipi: TfrmSetBbkFirmaTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Bilgi Bankas'#305' Firma Tipi'
  ClientHeight = 117
  ClientWidth = 342
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 358
  ExplicitHeight = 156
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 342
    Height = 67
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 92
    inherited pgcMain: TPageControl
      Width = 342
      Height = 67
      ExplicitWidth = 338
      ExplicitHeight = 90
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 334
        ExplicitHeight = 38
        object lblfirma_tipi: TLabel
          Left = 83
          Top = 5
          Width = 54
          Height = 14
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
    Top = 69
    Width = 338
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
    Top = 99
    Width = 342
    ExplicitTop = 126
    ExplicitWidth = 344
  end
  inherited pmLabels: TPopupMenu
    Left = 400
    Top = 88
  end
end

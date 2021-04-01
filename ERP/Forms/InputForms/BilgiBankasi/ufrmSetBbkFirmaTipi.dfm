inherited frmSetBbkFirmaTipi: TfrmSetBbkFirmaTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Bilgi Bankas'#305' Firma Tipi'
  ClientHeight = 144
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 173
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 78
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 78
    inherited pgcMain: TPageControl
      Width = 338
      Height = 76
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 338
      ExplicitHeight = 76
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 48
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
        object lblkayit_tipi_id: TLabel
          Left = 83
          Top = 27
          Width = 54
          Height = 13
          Alignment = taRightJustify
          Caption = 'Kay'#305't Tipi'
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
        object cbbkayit_tipi_id: TComboBox
          Left = 142
          Top = 24
          Width = 177
          Height = 21
          Style = csDropDownList
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 82
    Width = 340
    ExplicitTop = 82
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      Caption = 'KAYDET'
      ExplicitLeft = 131
    end
    inherited btnDelete: TButton
      Caption = 'S'#304'L'
    end
    inherited btnClose: TButton
      Left = 235
      Caption = 'KAPAT'
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 126
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

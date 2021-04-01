inherited frmSetChFirmaTipi: TfrmSetChFirmaTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ayar Firma Tipi'
  ClientHeight = 148
  ClientWidth = 359
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 365
  ExplicitHeight = 177
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 355
    Height = 96
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 355
    ExplicitHeight = 102
    inherited pgcMain: TPageControl
      Width = 353
      Height = 94
      ExplicitWidth = 353
      ExplicitHeight = 100
      inherited tsMain: TTabSheet
        ExplicitWidth = 345
        ExplicitHeight = 72
        object lblfirma_tipi: TLabel
          Left = 77
          Top = 29
          Width = 56
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Firma Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfirma_turu_id: TLabel
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
        object cbbfirma_turu_id: TComboBox
          Left = 137
          Top = 4
          Width = 208
          Height = 21
          Style = csDropDownList
          TabOrder = 0
        end
        object edtfirma_tipi: TEdit
          Left = 137
          Top = 26
          Width = 208
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 100
    Width = 355
    ExplicitTop = 106
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
    Top = 130
    Width = 359
    ExplicitTop = 150
    ExplicitWidth = 359
  end
end

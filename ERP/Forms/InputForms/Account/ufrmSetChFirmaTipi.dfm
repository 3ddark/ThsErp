inherited frmSetChFirmaTipi: TfrmSetChFirmaTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ayar Firma Tipi'
  ClientHeight = 144
  ClientWidth = 357
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 373
  ExplicitHeight = 183
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 357
    Height = 94
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 355
    ExplicitHeight = 102
    inherited pgcMain: TPageControl
      Width = 357
      Height = 94
      ExplicitWidth = 353
      ExplicitHeight = 100
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 349
        ExplicitHeight = 65
        object lblfirma_tipi: TLabel
          Left = 79
          Top = 29
          Width = 54
          Height = 14
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
          Left = 70
          Top = 7
          Width = 60
          Height = 14
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
    Top = 96
    Width = 353
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
    Top = 126
    Width = 357
    ExplicitTop = 150
    ExplicitWidth = 359
  end
end

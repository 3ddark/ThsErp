inherited frmSetTekTeklifTipi: TfrmSetTekTeklifTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Teklif Tipi'
  ClientHeight = 166
  ClientWidth = 359
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 375
  ExplicitHeight = 205
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 359
    Height = 116
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 146
    inherited pgcMain: TPageControl
      Width = 359
      Height = 116
      ExplicitWidth = 338
      ExplicitHeight = 144
      inherited tsMain: TTabSheet
        ExplicitWidth = 351
        ExplicitHeight = 88
        object lblteklif_tipi: TLabel
          Left = 78
          Top = 5
          Width = 58
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Teklif Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblaciklama: TLabel
          Left = 84
          Top = 27
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'A'#231#305'klama'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_aktif: TLabel
          Left = 102
          Top = 49
          Width = 34
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Aktif?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtteklif_tipi: TEdit
          Left = 140
          Top = 2
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtaciklama: TEdit
          Left = 140
          Top = 24
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object chkis_aktif: TCheckBox
          Left = 140
          Top = 48
          Width = 200
          Height = 17
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 118
    Width = 355
    ExplicitTop = 150
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 146
      ExplicitLeft = 131
    end
    inherited btnClose: TButton
      Left = 250
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 148
    Width = 359
    ExplicitTop = 194
    ExplicitWidth = 344
  end
end

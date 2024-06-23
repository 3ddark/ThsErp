inherited frmSetTekTeklifTipi: TfrmSetTekTeklifTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Teklif Tipi'
  ClientHeight = 162
  ClientWidth = 357
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 373
  ExplicitHeight = 201
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 357
    Height = 112
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 146
    inherited pgcMain: TPageControl
      Width = 357
      Height = 112
      ExplicitWidth = 338
      ExplicitHeight = 144
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 349
        ExplicitHeight = 83
        object lblteklif_tipi: TLabel
          Left = 83
          Top = 5
          Width = 53
          Height = 14
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
          Left = 86
          Top = 27
          Width = 50
          Height = 14
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
          Left = 103
          Top = 49
          Width = 33
          Height = 14
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
    Top = 114
    Width = 353
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
    Top = 144
    Width = 357
    ExplicitTop = 194
    ExplicitWidth = 344
  end
end

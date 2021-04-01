inherited frmSetSatTeklifDurum: TfrmSetSatTeklifDurum
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Teklif Durum'
  ClientHeight = 166
  ClientWidth = 360
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 366
  ExplicitHeight = 195
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 356
    Height = 100
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 111
    inherited pgcMain: TPageControl
      Width = 354
      Height = 98
      ExplicitWidth = 338
      ExplicitHeight = 109
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 81
        object lblteklif_durum: TLabel
          Left = 63
          Top = 5
          Width = 73
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Teklif Durum'
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
        object edtteklif_durum: TEdit
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
    Top = 104
    Width = 356
    ExplicitTop = 115
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 147
      ExplicitLeft = 131
    end
    inherited btnClose: TButton
      Left = 251
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 148
    Width = 360
    ExplicitTop = 159
    ExplicitWidth = 344
  end
end

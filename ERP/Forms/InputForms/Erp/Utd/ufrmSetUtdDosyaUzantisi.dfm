inherited frmSetUtdDosyaUzantisi: TfrmSetUtdDosyaUzantisi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'UTD Dosya Uzant'#305's'#305
  ClientHeight = 143
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 172
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 77
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 77
    inherited pgcMain: TPageControl
      Width = 338
      Height = 75
      ExplicitWidth = 338
      ExplicitHeight = 75
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 47
        object lbldosya_uzantisi: TLabel
          Left = 89
          Top = 27
          Width = 82
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ger'#231'ek Uzant'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfake_dosya_uzantisi: TLabel
          Left = 97
          Top = 5
          Width = 74
          Height = 13
          Alignment = taRightJustify
          Caption = 'Sahte Uzant'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtfake_dosya_uzantisi: TEdit
          Left = 176
          Top = 2
          Width = 145
          Height = 21
          TabOrder = 0
        end
        object cbbdosya_uzantisi: TComboBox
          Left = 176
          Top = 24
          Width = 145
          Height = 21
          Style = csDropDownList
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 81
    Width = 340
    ExplicitTop = 81
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
    Top = 125
    Width = 344
    ExplicitTop = 125
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
  object dlgDosyaSec: TOpenTextFileDialog
    Left = 471
    Top = 107
  end
end

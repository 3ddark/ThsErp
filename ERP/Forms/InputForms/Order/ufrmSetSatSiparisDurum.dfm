inherited frmSetSatSiparisDurum: TfrmSetSatSiparisDurum
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sipari'#351' Durum'
  ClientHeight = 173
  ClientWidth = 342
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 358
  ExplicitHeight = 212
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 342
    Height = 123
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 111
    inherited pgcMain: TPageControl
      Width = 344
      Height = 127
      ExplicitWidth = 338
      ExplicitHeight = 109
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 99
        object lblaciklama: TLabel
          Left = 36
          Top = 28
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
        object lblteklif_durum: TLabel
          Left = 9
          Top = 6
          Width = 79
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sipari'#351' Durum'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_active: TLabel
          Left = 54
          Top = 50
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
        object chkis_active: TCheckBox
          Left = 92
          Top = 49
          Width = 200
          Height = 17
          TabOrder = 0
        end
        object edtaciklama: TEdit
          Left = 92
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtteklif_durum: TEdit
          Left = 92
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 125
    Width = 338
    ExplicitTop = 115
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
    Top = 155
    Width = 342
    ExplicitTop = 159
    ExplicitWidth = 344
  end
end

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
    ExplicitWidth = 342
    ExplicitHeight = 123
    inherited pgcMain: TPageControl
      Width = 342
      Height = 123
      ExplicitWidth = 342
      ExplicitHeight = 123
      inherited tsMain: TTabSheet
        ExplicitWidth = 334
        ExplicitHeight = 95
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
        object edtaciklama: TEdit
          Left = 92
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtteklif_durum: TEdit
          Left = 92
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 125
    Width = 338
    ExplicitTop = 125
    ExplicitWidth = 338
    inherited btnAccept: TButton
      Left = 132
      ExplicitLeft = 132
    end
    inherited btnClose: TButton
      Left = 236
      ExplicitLeft = 236
    end
  end
  inherited stbBase: TStatusBar
    Top = 155
    Width = 342
    ExplicitTop = 155
    ExplicitWidth = 342
  end
end

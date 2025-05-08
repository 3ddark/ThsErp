inherited frmSetSatTeklifDurum: TfrmSetSatTeklifDurum
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Teklif Durum'
  ClientHeight = 162
  ClientWidth = 358
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 374
  ExplicitHeight = 201
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 358
    Height = 112
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 358
    ExplicitHeight = 112
    inherited pgcMain: TPageControl
      Width = 358
      Height = 112
      ExplicitWidth = 358
      ExplicitHeight = 112
      inherited tsMain: TTabSheet
        ExplicitWidth = 350
        ExplicitHeight = 84
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
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 114
    Width = 354
    ExplicitTop = 114
    ExplicitWidth = 354
    inherited btnAccept: TButton
      Left = 148
      ExplicitLeft = 148
    end
    inherited btnClose: TButton
      Left = 252
      ExplicitLeft = 252
    end
  end
  inherited stbBase: TStatusBar
    Top = 144
    Width = 358
    ExplicitTop = 144
    ExplicitWidth = 358
  end
end

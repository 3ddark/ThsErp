inherited frmHesapKartiAra: TfrmHesapKartiAra
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ara Hesap Kart'#305
  ClientHeight = 151
  ClientWidth = 702
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 708
  ExplicitHeight = 180
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 698
    Height = 99
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 698
    ExplicitHeight = 99
    inherited pgcMain: TPageControl
      Width = 696
      Height = 97
      ExplicitWidth = 696
      ExplicitHeight = 97
      inherited tsMain: TTabSheet
        ExplicitWidth = 688
        ExplicitHeight = 69
        object lblhesap_kodu: TLabel
          Left = 76
          Top = 25
          Width = 70
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Hesap Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblhesap_ismi: TLabel
          Left = 83
          Top = 47
          Width = 63
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Hesap '#304'smi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmuhasebe_kodu: TLabel
          Left = 54
          Top = 3
          Width = 92
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Muhasebe Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblspl1: TLabel
          Left = 194
          Top = -3
          Width = 8
          Height = 24
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = '-'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtkok_hesap_kodu: TEdit
          Left = 150
          Top = 0
          Width = 43
          Height = 21
          TabOrder = 0
          OnExit = edtkok_hesap_koduExit
        end
        object cbbara_hesap_kodu: TComboBox
          Left = 204
          Top = 0
          Width = 50
          Height = 21
          Style = csDropDownList
          TabOrder = 1
          OnExit = cbbara_hesap_koduExit
        end
        object edthesap_kodu: TEdit
          Left = 150
          Top = 22
          Width = 80
          Height = 21
          TabOrder = 2
        end
        object edthesap_ismi: TEdit
          Left = 150
          Top = 44
          Width = 522
          Height = 21
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 103
    Width = 698
    ExplicitTop = 103
    ExplicitWidth = 698
    inherited btnAccept: TButton
      Left = 489
      TabOrder = 3
      ExplicitLeft = 489
    end
    inherited btnClose: TButton
      Left = 593
      ExplicitLeft = 593
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 133
    Width = 702
    ExplicitTop = 133
    ExplicitWidth = 702
  end
end

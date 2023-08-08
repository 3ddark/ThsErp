inherited frmHesapKartiAra: TfrmHesapKartiAra
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ara Hesap Kart'#305
  ClientHeight = 144
  ClientWidth = 690
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 706
  ExplicitHeight = 183
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 690
    Height = 94
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 690
    ExplicitHeight = 94
    inherited pgcMain: TPageControl
      Width = 690
      Height = 94
      ExplicitWidth = 690
      ExplicitHeight = 94
      inherited tsMain: TTabSheet
        ExplicitWidth = 682
        ExplicitHeight = 66
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
    Top = 96
    Width = 686
    ExplicitTop = 96
    ExplicitWidth = 686
    inherited btnAccept: TButton
      Left = 480
      ExplicitLeft = 480
    end
    inherited btnClose: TButton
      Left = 584
      ExplicitLeft = 584
    end
  end
  inherited stbBase: TStatusBar
    Top = 126
    Width = 690
    ExplicitTop = 126
    ExplicitWidth = 690
  end
end

inherited frmSetChHesapPlani: TfrmSetChHesapPlani
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Hesap Plan'#305
  ClientHeight = 220
  ClientWidth = 372
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 378
  ExplicitHeight = 249
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 368
    Height = 168
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 368
    ExplicitHeight = 168
    inherited pgcMain: TPageControl
      Width = 366
      Height = 166
      ExplicitWidth = 366
      ExplicitHeight = 166
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 358
        ExplicitHeight = 138
        object lbltek_duzen_kodu: TLabel
          Left = 50
          Top = 6
          Width = 96
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tek D'#252'zen Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblaciklama: TLabel
          Left = 94
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
        object lblseviye_sayisi: TLabel
          Left = 70
          Top = 50
          Width = 76
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Seviye Say'#305's'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edttek_duzen_kodu: TEdit
          Left = 150
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtaciklama: TEdit
          Left = 150
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object cbbseviye_sayisi: TComboBox
          Left = 150
          Top = 47
          Width = 200
          Height = 21
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 2
          Text = '1'
          Items.Strings = (
            '1'
            '2'
            '3')
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 172
    Width = 368
    ExplicitTop = 172
    ExplicitWidth = 368
    inherited btnAccept: TButton
      Left = 159
      TabOrder = 2
      ExplicitLeft = 159
    end
    inherited btnClose: TButton
      Left = 263
      ExplicitLeft = 263
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 202
    Width = 372
    ExplicitTop = 202
    ExplicitWidth = 372
  end
end

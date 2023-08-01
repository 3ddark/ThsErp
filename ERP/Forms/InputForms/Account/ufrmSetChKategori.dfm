inherited frmSetChKategori: TfrmSetChKategori
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Set Ch Kategori'
  ClientHeight = 167
  ClientWidth = 377
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 383
  ExplicitHeight = 196
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 373
    Height = 115
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 373
    ExplicitHeight = 183
    inherited pgcMain: TPageControl
      Width = 371
      Height = 113
      ExplicitWidth = 371
      ExplicitHeight = 181
      inherited tsMain: TTabSheet
        ExplicitWidth = 363
        ExplicitHeight = 153
        object lblrenk: TLabel
          Left = 85
          Top = 51
          Width = 31
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Renk'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblaciklama: TLabel
          Left = 64
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
        object lblkategori: TLabel
          Left = 68
          Top = 5
          Width = 48
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kategori'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtkategori: TEdit
          Left = 122
          Top = 2
          Width = 240
          Height = 21
          TabOrder = 0
        end
        object edtaciklama: TEdit
          Left = 122
          Top = 25
          Width = 240
          Height = 21
          TabOrder = 1
        end
        object edtrenk: TEdit
          Left = 122
          Top = 48
          Width = 240
          Height = 21
          TabOrder = 2
          OnDblClick = edtrenkDblClick
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 119
    Width = 373
    ExplicitTop = 187
    ExplicitWidth = 373
    inherited btnAccept: TButton
      Left = 164
      ExplicitLeft = 164
    end
    inherited btnClose: TButton
      Left = 268
      ExplicitLeft = 268
    end
  end
  inherited stbBase: TStatusBar
    Top = 149
    Width = 377
    ExplicitTop = 231
    ExplicitWidth = 377
  end
end

inherited frmRctReceteIscilik: TfrmRctReceteIscilik
  Caption = 'Re'#231'ete '#304#351#231'ilik'
  ClientHeight = 193
  ClientWidth = 348
  ExplicitWidth = 354
  ExplicitHeight = 222
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 344
    Height = 141
    ExplicitWidth = 344
    ExplicitHeight = 141
    inherited pgcMain: TPageControl
      Width = 342
      Height = 139
      ExplicitWidth = 342
      ExplicitHeight = 139
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 334
        ExplicitHeight = 111
        object lblmiktar: TLabel
          Left = 86
          Top = 53
          Width = 37
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Miktar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgider_kodu: TLabel
          Left = 62
          Top = 7
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Gider Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmiktar_birim: TLabel
          Left = 279
          Top = 53
          Width = 29
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'ADET'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgider_adi: TLabel
          Left = 127
          Top = 31
          Width = 53
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'STOK ADI'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object Label1: TLabel
          Left = 95
          Top = 75
          Width = 28
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Fiyat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfiyat_brm: TLabel
          Left = 279
          Top = 75
          Width = 13
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'TL'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtgider_kodu: TEdit
          Left = 127
          Top = 4
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtmiktar: TEdit
          Left = 127
          Top = 50
          Width = 150
          Height = 21
          TabOrder = 1
        end
        object edtfiyat: TEdit
          Left = 127
          Top = 72
          Width = 150
          Height = 21
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 145
    Width = 344
    ExplicitTop = 145
    ExplicitWidth = 344
    inherited btnAccept: TButton
      Left = 135
      ExplicitLeft = 135
    end
    inherited btnClose: TButton
      Left = 239
      ExplicitLeft = 239
    end
  end
  inherited stbBase: TStatusBar
    Top = 175
    Width = 348
    ExplicitTop = 175
    ExplicitWidth = 348
  end
end

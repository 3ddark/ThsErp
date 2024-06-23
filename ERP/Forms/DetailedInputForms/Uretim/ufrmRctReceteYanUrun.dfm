inherited frmRctReceteYanUrun: TfrmRctReceteYanUrun
  Caption = 'Re'#231'ete Yan '#220'r'#252'n'
  ClientHeight = 165
  ClientWidth = 344
  ExplicitWidth = 360
  ExplicitHeight = 204
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 344
    Height = 115
    ExplicitWidth = 348
    ExplicitHeight = 123
    inherited pgcMain: TPageControl
      Width = 344
      Height = 115
      ExplicitWidth = 348
      ExplicitHeight = 123
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 87
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
        object lblstok_kodu: TLabel
          Left = 66
          Top = 7
          Width = 57
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Stok Kodu'
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
        object lblstok_aciklama: TLabel
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
        object edtstok_kodu: TEdit
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
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 117
    Width = 340
    ExplicitTop = 125
    ExplicitWidth = 344
    inherited btnAccept: TButton
      Left = 138
      ExplicitLeft = 138
    end
    inherited btnClose: TButton
      Left = 242
      ExplicitLeft = 242
    end
  end
  inherited stbBase: TStatusBar
    Top = 147
    Width = 344
    ExplicitTop = 155
    ExplicitWidth = 348
  end
end

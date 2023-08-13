inherited frmRctReceteHammadde: TfrmRctReceteHammadde
  Caption = 'Re'#231'ete Hammadde'
  ClientHeight = 239
  ClientWidth = 342
  ExplicitWidth = 358
  ExplicitHeight = 278
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 342
    Height = 189
    ExplicitWidth = 344
    ExplicitHeight = 199
    inherited pgcMain: TPageControl
      Width = 344
      Height = 193
      ExplicitWidth = 342
      ExplicitHeight = 197
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 165
        object lblfire_orani: TLabel
          Left = 69
          Top = 75
          Width = 54
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Fire Oran'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
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
        object lblrecete: TLabel
          Left = 83
          Top = 97
          Width = 40
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Re'#231'ete'
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
        object lblrecete_adi: TLabel
          Left = 127
          Top = 121
          Width = 64
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'RE'#199'ETE ADI'
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
        object edtfire_orani: TEdit
          Left = 127
          Top = 72
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object cbbrecete: TComboBox
          Left = 127
          Top = 94
          Width = 200
          Height = 21
          TabOrder = 3
          OnChange = cbbreceteChange
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 191
    Width = 338
    ExplicitTop = 203
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
    Top = 221
    Width = 342
    ExplicitTop = 233
    ExplicitWidth = 348
  end
end

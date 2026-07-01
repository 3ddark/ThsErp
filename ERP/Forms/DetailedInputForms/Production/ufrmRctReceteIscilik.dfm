inherited frmRctReceteIscilik: TfrmRctReceteIscilik
  Caption = 'Re'#231'ete '#304#351#231'ilik'
  ClientHeight = 181
  ClientWidth = 342
  ExplicitWidth = 358
  ExplicitHeight = 220
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 342
    Height = 131
    ExplicitWidth = 342
    ExplicitHeight = 131
    inherited pgcMain: TPageControl
      Width = 342
      Height = 131
      ExplicitWidth = 342
      ExplicitHeight = 131
      inherited tsMain: TTabSheet
        ExplicitWidth = 334
        ExplicitHeight = 103
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
    Top = 133
    Width = 338
    ExplicitTop = 133
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
    Top = 163
    Width = 342
    ExplicitTop = 163
    ExplicitWidth = 342
  end
end

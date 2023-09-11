inherited frmAlsTeklifDetay: TfrmAlsTeklifDetay
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sat'#305#351' Teklif Detay'
  ClientHeight = 387
  ClientWidth = 423
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 439
  ExplicitHeight = 426
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 423
    Height = 337
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 425
    ExplicitHeight = 340
    inherited pgcMain: TPageControl
      Width = 425
      Height = 340
      ExplicitWidth = 425
      ExplicitHeight = 340
      inherited tsMain: TTabSheet
        ExplicitWidth = 417
        ExplicitHeight = 312
        object lblstok_kodu: TLabel
          Left = 35
          Top = 6
          Width = 60
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Stok Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblstok_aciklama: TLabel
          Left = 13
          Top = 28
          Width = 82
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Stok A'#231#305'klama'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfiyat: TLabel
          Left = 67
          Top = 50
          Width = 28
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Fiyat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbliskonto_orani: TLabel
          Left = 52
          Top = 116
          Width = 43
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304'skonto'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkdv_orani: TLabel
          Left = 72
          Top = 138
          Width = 23
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kdv'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmiktar: TLabel
          Left = 59
          Top = 72
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Miktar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblolcu_birimi: TLabel
          Left = 34
          Top = 94
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgtip_no: TLabel
          Left = 51
          Top = 160
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Gtip No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object imgstok_resim: TImage
          Left = 278
          Top = 47
          Width = 131
          Height = 131
          Stretch = True
        end
        object lblkullanici_aciklama: TLabel
          Left = 43
          Top = 182
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
        object edtstok_kodu: TEdit
          Left = 97
          Top = 3
          Width = 150
          Height = 21
          TabOrder = 0
        end
        object edtstok_aciklama: TEdit
          Left = 97
          Top = 25
          Width = 312
          Height = 21
          TabOrder = 1
        end
        object edtfiyat: TEdit
          Left = 97
          Top = 47
          Width = 110
          Height = 21
          TabOrder = 2
          OnChange = edtfiyatChange
          OnExit = edtfiyatExit
        end
        object edtmiktar: TEdit
          Left = 97
          Top = 69
          Width = 110
          Height = 21
          TabOrder = 3
          OnChange = edtmiktarChange
          OnExit = edtmiktarExit
        end
        object edtiskonto_orani: TEdit
          Left = 97
          Top = 113
          Width = 110
          Height = 21
          TabOrder = 5
          OnChange = edtiskonto_oraniChange
          OnExit = edtiskonto_oraniExit
        end
        object edtgtip_no: TEdit
          Left = 97
          Top = 157
          Width = 150
          Height = 21
          TabOrder = 7
        end
        object PanelBilgilendirme: TPanel
          Left = 97
          Top = 200
          Width = 312
          Height = 106
          BevelInner = bvLowered
          ParentColor = True
          TabOrder = 9
          object lbltutar: TLabel
            Left = 93
            Top = 21
            Width = 31
            Height = 13
            Alignment = taRightJustify
            Caption = 'Tutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltutar_val: TLabel
            Left = 124
            Top = 21
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lbliskonto_tutar: TLabel
            Left = 44
            Top = 38
            Width = 80
            Height = 13
            Alignment = taRightJustify
            Caption = #304'skonto Tutar'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbliskonto_tutar_val: TLabel
            Left = 124
            Top = 38
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueIskontoTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lblkdv_tutar: TLabel
            Left = 61
            Top = 72
            Width = 63
            Height = 13
            Alignment = taRightJustify
            Caption = 'KDV Tutar'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblkdv_tutar_val: TLabel
            Left = 124
            Top = 72
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueKDVTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lbltoplam_tutar: TLabel
            Left = 48
            Top = 89
            Width = 76
            Height = 13
            Alignment = taRightJustify
            Caption = 'Toplam Tutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltoplam_tutar_val: TLabel
            Left = 124
            Top = 89
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueToplamTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lblnet_fiyat: TLabel
            Left = 72
            Top = 4
            Width = 52
            Height = 13
            Alignment = taRightJustify
            Caption = 'Net Fiyat'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblnet_fiyat_val: TLabel
            Left = 124
            Top = 4
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lblnet_tutar: TLabel
            Left = 69
            Top = 55
            Width = 55
            Height = 13
            Alignment = taRightJustify
            Caption = 'Net Tutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblnet_tutar_val: TLabel
            Left = 124
            Top = 55
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
        end
        object edtkdv_orani: TEdit
          Left = 97
          Top = 135
          Width = 110
          Height = 21
          TabOrder = 6
          OnChange = edtkdv_oraniChange
          OnExit = edtkdv_oraniExit
        end
        object edtolcu_birimi: TEdit
          Left = 97
          Top = 91
          Width = 110
          Height = 21
          TabOrder = 4
        end
        object edtkullanici_aciklama: TEdit
          Left = 97
          Top = 179
          Width = 312
          Height = 21
          TabOrder = 8
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 339
    Width = 419
    ExplicitTop = 342
    ExplicitWidth = 421
    inherited btnAccept: TButton
      Left = 215
      ExplicitLeft = 215
    end
    inherited btnClose: TButton
      Left = 319
      ExplicitLeft = 319
    end
  end
  inherited stbBase: TStatusBar
    Top = 369
    Width = 423
    ExplicitTop = 372
    ExplicitWidth = 425
  end
end

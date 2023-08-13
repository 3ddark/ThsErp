inherited frmSatSiparisDetay: TfrmSatSiparisDetay
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sat'#305#351' Siparis Detay'
  ClientHeight = 368
  ClientWidth = 589
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 605
  ExplicitHeight = 407
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 589
    Height = 318
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 603
    ExplicitHeight = 352
    inherited pgcMain: TPageControl
      Width = 591
      Height = 322
      ExplicitWidth = 601
      ExplicitHeight = 350
      inherited tsMain: TTabSheet
        ExplicitWidth = 583
        ExplicitHeight = 294
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
        object lblnet_agirlik_brm: TLabel
          Left = 550
          Top = 124
          Width = 28
          Height = 13
          Caption = 'gram'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblnet_agirlik: TLabel
          Left = 420
          Top = 124
          Width = 60
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Net A'#287#305'rl'#305'k'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblhacim_brm: TLabel
          Left = 550
          Top = 92
          Width = 17
          Height = 13
          Caption = 'm3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblyukseklik_brm: TLabel
          Left = 550
          Top = 72
          Width = 19
          Height = 13
          Caption = 'mm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblboy_brm: TLabel
          Left = 550
          Top = 50
          Width = 19
          Height = 13
          Caption = 'mm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblen_brm: TLabel
          Left = 550
          Top = 28
          Width = 19
          Height = 13
          Caption = 'mm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblhacim_val: TLabel
          Left = 518
          Top = 92
          Width = 26
          Height = 13
          Alignment = taRightJustify
          Caption = '0,00'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblhacim: TLabel
          Left = 444
          Top = 92
          Width = 36
          Height = 13
          Alignment = taRightJustify
          Caption = 'Hacim'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblen: TLabel
          Left = 466
          Top = 28
          Width = 16
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'En'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblboy: TLabel
          Left = 460
          Top = 50
          Width = 22
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Boy'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblyukseklik: TLabel
          Left = 426
          Top = 72
          Width = 56
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Y'#252'kseklik'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblbrut_agirlik_brm: TLabel
          Left = 550
          Top = 146
          Width = 28
          Height = 13
          Caption = 'gram'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblbrut_agirlik: TLabel
          Left = 417
          Top = 146
          Width = 63
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Br'#252't A'#287#305'rl'#305'k'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkab_brm: TLabel
          Left = 550
          Top = 178
          Width = 26
          Height = 13
          Caption = 'adet'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblkab: TLabel
          Left = 457
          Top = 178
          Width = 23
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kab'
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
        object edtkullanici_aciklama: TEdit
          Left = 97
          Top = 179
          Width = 312
          Height = 21
          TabOrder = 8
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
            Left = 96
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
          object lbltutar_brm: TLabel
            Left = 248
            Top = 21
            Width = 6
            Height = 13
            Caption = #8378
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lbliskonto_tutar: TLabel
            Left = 47
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
          object lbliskonto_tutar_brm: TLabel
            Left = 248
            Top = 38
            Width = 6
            Height = 13
            Caption = #8378
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lblkdv_tutar: TLabel
            Left = 64
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
          object lblkdv_tutar_brm: TLabel
            Left = 248
            Top = 72
            Width = 6
            Height = 13
            Caption = #8378
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lbltoplam_tutar: TLabel
            Left = 51
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
          object lbltoplam_tutar_brm: TLabel
            Left = 248
            Top = 89
            Width = 6
            Height = 13
            Caption = #8378
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lblnet_fiyat: TLabel
            Left = 75
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
          object lblnet_fiyat_brm: TLabel
            Left = 248
            Top = 4
            Width = 6
            Height = 13
            Caption = #8378
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lblnet_tutar: TLabel
            Left = 72
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
          object lblnet_tutar_brm: TLabel
            Left = 248
            Top = 55
            Width = 6
            Height = 13
            Caption = #8378
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
        end
        object edtolcu_birimi: TEdit
          Left = 97
          Top = 91
          Width = 110
          Height = 21
          TabOrder = 4
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
        object edten: TEdit
          Left = 486
          Top = 25
          Width = 60
          Height = 21
          TabOrder = 10
          OnChange = edtenChange
        end
        object edtboy: TEdit
          Left = 486
          Top = 47
          Width = 60
          Height = 21
          TabOrder = 11
          OnChange = edtboyChange
        end
        object edtyukseklik: TEdit
          Left = 486
          Top = 69
          Width = 60
          Height = 21
          TabOrder = 12
          OnChange = edtyukseklikChange
        end
        object edtnet_agirlik: TEdit
          Left = 486
          Top = 121
          Width = 60
          Height = 21
          TabOrder = 13
        end
        object edtbrut_agirlik: TEdit
          Left = 486
          Top = 143
          Width = 60
          Height = 21
          TabOrder = 14
        end
        object edtkab: TEdit
          Left = 486
          Top = 175
          Width = 60
          Height = 21
          TabOrder = 15
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 320
    Width = 585
    ExplicitTop = 356
    ExplicitWidth = 603
    inherited btnAccept: TButton
      Left = 394
      ExplicitLeft = 394
    end
    inherited btnClose: TButton
      Left = 498
      ExplicitLeft = 498
    end
  end
  inherited stbBase: TStatusBar
    Top = 350
    Width = 589
    ExplicitTop = 386
    ExplicitWidth = 607
  end
end

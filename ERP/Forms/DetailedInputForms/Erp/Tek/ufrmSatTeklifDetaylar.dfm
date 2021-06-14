inherited frmSatTeklifDetaylar: TfrmSatTeklifDetaylar
  Caption = 'Sat'#305#351' Teklif Detaylar'#305
  ClientHeight = 593
  ClientWidth = 904
  ExplicitWidth = 920
  ExplicitHeight = 632
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 900
    Height = 541
    ExplicitWidth = 900
    ExplicitHeight = 541
    inherited splLeft: TSplitter
      Top = 332
      Height = 208
      ExplicitTop = 381
      ExplicitHeight = 167
    end
    inherited splHeader: TSplitter
      Top = 329
      Width = 898
      ExplicitTop = 378
      ExplicitWidth = 898
    end
    inherited pgcMain: TPageControl
      Top = 332
      Width = 792
      Height = 208
      ExplicitTop = 332
      ExplicitWidth = 792
      ExplicitHeight = 208
      inherited tsMain: TTabSheet
        ExplicitWidth = 784
        ExplicitHeight = 180
      end
    end
    inherited pnlHeader: TPanel
      Width = 894
      Height = 325
      ExplicitWidth = 894
      ExplicitHeight = 325
      inherited pgcHeader: TPageControl
        Width = 892
        Height = 323
        ExplicitWidth = 892
        ExplicitHeight = 323
        inherited tsHeader: TTabSheet
          ExplicitWidth = 864
          ExplicitHeight = 315
          object lblteklif_no: TLabel
            Left = 632
            Top = 6
            Width = 53
            Height = 13
            Alignment = taRightJustify
            Caption = 'Teklif No'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblteklif_tarihi: TLabel
            Left = 620
            Top = 28
            Width = 65
            Height = 13
            Alignment = taRightJustify
            Caption = 'TeklifTarihi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblmusteri_kodu: TLabel
            Left = 39
            Top = 5
            Width = 75
            Height = 13
            Alignment = taRightJustify
            Caption = 'M'#252#351'teri Kodu'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblmusteri_adi: TLabel
            Left = 50
            Top = 27
            Width = 64
            Height = 13
            Alignment = taRightJustify
            Caption = 'M'#252#351'teri Ad'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblvergi_dairesi: TLabel
            Left = 41
            Top = 49
            Width = 73
            Height = 13
            Alignment = taRightJustify
            Caption = 'Vergi Dairesi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblvergi_no: TLabel
            Left = 64
            Top = 71
            Width = 50
            Height = 13
            Alignment = taRightJustify
            Caption = 'Vergi No'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblpara_birimi: TLabel
            Left = 624
            Top = 94
            Width = 61
            Height = 13
            Alignment = taRightJustify
            Caption = 'Para Birimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblkur_dolar: TLabel
            Left = 624
            Top = 116
            Width = 61
            Height = 13
            Alignment = taRightJustify
            Caption = 'Dolar Kuru'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblkur_euro: TLabel
            Left = 628
            Top = 138
            Width = 57
            Height = 13
            Alignment = taRightJustify
            Caption = 'Euro Kuru'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblmusteri_temsilcisi_id: TLabel
            Left = 306
            Top = 49
            Width = 101
            Height = 13
            Alignment = taRightJustify
            Caption = 'M'#252#351'teri Temsilcisi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblteslim_sekli_id: TLabel
            Left = 338
            Top = 181
            Width = 69
            Height = 13
            Alignment = taRightJustify
            Caption = 'Teslim '#350'ekli'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblodeme_sekli_id: TLabel
            Left = 335
            Top = 159
            Width = 72
            Height = 13
            Alignment = taRightJustify
            Caption = #214'deme '#350'ekli'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblreferans: TLabel
            Left = 355
            Top = 204
            Width = 52
            Height = 13
            Alignment = taRightJustify
            Caption = 'Referans'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object lblmuhattap_ad: TLabel
            Left = 334
            Top = 71
            Width = 73
            Height = 13
            Alignment = taRightJustify
            Caption = 'Muhattap Ad'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblgecerlilik_tarihi: TLabel
            Left = 595
            Top = 50
            Width = 90
            Height = 13
            Alignment = taRightJustify
            Caption = 'Ge'#231'erlilik Tarihi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblkapi_no: TLabel
            Left = 68
            Top = 247
            Width = 46
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'Kap'#305' No'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblposta_kodu: TLabel
            Left = 48
            Top = 269
            Width = 66
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'Posta Kodu'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblulke_id: TLabel
            Left = 87
            Top = 93
            Width = 27
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = #220'lke'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblsehir_id: TLabel
            Left = 84
            Top = 115
            Width = 30
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = #350'ehir'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblilce: TLabel
            Left = 92
            Top = 137
            Width = 22
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = #304'l'#231'e'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblmahalle: TLabel
            Left = 69
            Top = 159
            Width = 45
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'Mahalle'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblcadde: TLabel
            Left = 77
            Top = 181
            Width = 37
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'Cadde'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblsokak: TLabel
            Left = 77
            Top = 203
            Width = 37
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'Sokak'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblbina_adi: TLabel
            Left = 88
            Top = 225
            Width = 26
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'Bina'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblpaket_tipi_id: TLabel
            Left = 331
            Top = 115
            Width = 76
            Height = 13
            Alignment = taRightJustify
            Caption = 'Ambalaj Cinsi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltasima_ucreti_id: TLabel
            Left = 326
            Top = 137
            Width = 81
            Height = 13
            Alignment = taRightJustify
            Caption = 'Nakliye '#220'creti'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblaciklama: TLabel
            Left = 355
            Top = 225
            Width = 52
            Height = 13
            Alignment = taRightJustify
            Caption = 'A'#231#305'klama'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblproforma_no: TLabel
            Left = 336
            Top = 291
            Width = 71
            Height = 13
            Alignment = taRightJustify
            Caption = 'Proforma No'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object lblmuhattap_telefon: TLabel
            Left = 306
            Top = 93
            Width = 101
            Height = 13
            Alignment = taRightJustify
            Caption = 'Muhattap Telefon'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object edtmusteri_kodu: TEdit
            Left = 115
            Top = 2
            Width = 150
            Height = 21
            TabOrder = 0
          end
          object edtmusteri_adi: TEdit
            Left = 115
            Top = 24
            Width = 443
            Height = 21
            TabOrder = 2
          end
          object edtvergi_dairesi: TEdit
            Left = 115
            Top = 46
            Width = 150
            Height = 21
            TabOrder = 4
          end
          object edtvergi_no: TEdit
            Left = 115
            Top = 68
            Width = 150
            Height = 21
            TabOrder = 7
          end
          object edtulke_id: TEdit
            Left = 115
            Top = 90
            Width = 150
            Height = 21
            TabOrder = 9
          end
          object edtsehir_id: TEdit
            Left = 115
            Top = 112
            Width = 150
            Height = 21
            TabOrder = 12
          end
          object edtilce: TEdit
            Left = 115
            Top = 134
            Width = 150
            Height = 21
            TabOrder = 15
          end
          object edtmahalle: TEdit
            Left = 115
            Top = 156
            Width = 150
            Height = 21
            TabOrder = 18
          end
          object edtcadde: TEdit
            Left = 115
            Top = 178
            Width = 150
            Height = 21
            TabOrder = 20
          end
          object edtsokak: TEdit
            Left = 115
            Top = 200
            Width = 150
            Height = 21
            TabOrder = 22
          end
          object edtbina_adi: TEdit
            Left = 115
            Top = 222
            Width = 150
            Height = 21
            TabOrder = 24
          end
          object edtkapi_no: TEdit
            Left = 115
            Top = 244
            Width = 150
            Height = 21
            TabOrder = 26
          end
          object edtposta_kodu: TEdit
            Left = 115
            Top = 266
            Width = 150
            Height = 21
            TabOrder = 27
          end
          object edtteklif_no: TEdit
            Left = 686
            Top = 2
            Width = 90
            Height = 21
            TabOrder = 1
          end
          object edtteklif_tarihi: TEdit
            Left = 686
            Top = 24
            Width = 90
            Height = 21
            TabOrder = 3
          end
          object edtgecerlilik_tarihi: TEdit
            Left = 686
            Top = 46
            Width = 90
            Height = 21
            TabOrder = 6
          end
          object edtkur_dolar: TEdit
            Left = 686
            Top = 112
            Width = 90
            Height = 21
            TabOrder = 14
          end
          object edtkur_euro: TEdit
            Left = 686
            Top = 134
            Width = 90
            Height = 21
            TabOrder = 17
          end
          object edtmusteri_temsilcisi_id: TEdit
            Left = 408
            Top = 46
            Width = 150
            Height = 21
            TabOrder = 5
          end
          object edtmuhattap_ad: TEdit
            Left = 408
            Top = 68
            Width = 150
            Height = 21
            TabOrder = 8
          end
          object edtreferans: TEdit
            Left = 408
            Top = 200
            Width = 368
            Height = 21
            TabOrder = 23
          end
          object mmoaciklama: TMemo
            Left = 408
            Top = 222
            Width = 368
            Height = 65
            TabOrder = 25
          end
          object edtproforma_no: TEdit
            Left = 408
            Top = 288
            Width = 150
            Height = 21
            MaxLength = 10
            TabOrder = 28
          end
          object edtmuhattap_telefon: TEdit
            Left = 408
            Top = 90
            Width = 150
            Height = 21
            TabOrder = 10
          end
          object edtpaket_tipi_id: TEdit
            Left = 408
            Top = 112
            Width = 150
            Height = 21
            TabOrder = 13
          end
          object edttasima_ucreti_id: TEdit
            Left = 408
            Top = 134
            Width = 150
            Height = 21
            TabOrder = 16
          end
          object edtpara_birimi: TEdit
            Left = 686
            Top = 90
            Width = 90
            Height = 21
            TabOrder = 11
          end
          object edtodeme_sekli_id: TEdit
            Left = 408
            Top = 156
            Width = 368
            Height = 21
            TabOrder = 19
          end
          object edtteslim_sekli_id: TEdit
            Left = 408
            Top = 178
            Width = 368
            Height = 21
            TabOrder = 21
          end
        end
        inherited tsHeaderDiger: TTabSheet
          ExplicitWidth = 864
          ExplicitHeight = 315
          object lblProformaNo: TLabel
            Left = 71
            Top = 6
            Width = 75
            Height = 13
            Alignment = taRightJustify
            Caption = 'Proforma No:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object lblSonrakiAksiyonTarihi: TLabel
            Left = 37
            Top = 27
            Width = 109
            Height = 13
            Alignment = taRightJustify
            Caption = 'Sonraki Aksyn.Trh:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object lblSonrakiAksiyon: TLabel
            Left = 66
            Top = 48
            Width = 80
            Height = 13
            Alignment = taRightJustify
            Caption = 'Aksiyon Notu:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object lblArayanKisi: TLabel
            Left = 447
            Top = 28
            Width = 68
            Height = 13
            Alignment = taRightJustify
            Caption = 'Arayan Ki'#351'i:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object lblAramaTarihi: TLabel
            Left = 439
            Top = 50
            Width = 76
            Height = 13
            Alignment = taRightJustify
            Caption = 'Arama Tarihi:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object lblSonGecerlilikTarihi: TLabel
            Left = 421
            Top = 72
            Width = 94
            Height = 13
            Alignment = taRightJustify
            Caption = 'Son Ge'#231'rlik Trh:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object lblGenelIskontoYuzdesiTutari: TLabel
            Left = 427
            Top = 5
            Width = 88
            Height = 13
            Alignment = taRightJustify
            Caption = 'Fatura Alt'#305' '#304'sk.:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object lblGenelIskontoAyrac: TLabel
            Left = 568
            Top = 3
            Width = 6
            Height = 20
            Caption = '/'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblIhracKayitKodu: TLabel
            Left = 60
            Top = 118
            Width = 85
            Height = 13
            Alignment = taRightJustify
            Caption = #304'hra'#231' Kyt.Kodu'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblTevkifatKodu: TLabel
            Left = 64
            Top = 138
            Width = 81
            Height = 13
            Alignment = taRightJustify
            Caption = 'Tevkifat Kodu'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblTevkifatOrani: TLabel
            Left = 60
            Top = 160
            Width = 82
            Height = 13
            Alignment = taRightJustify
            Caption = 'Tevkifat Oran'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblTevkifatBolme: TLabel
            Left = 199
            Top = 159
            Width = 6
            Height = 20
            Caption = '/'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object edtProformaNo: TEdit
            Left = 147
            Top = 3
            Width = 110
            Height = 21
            MaxLength = 10
            TabOrder = 0
          end
          object edtSonrakiAksiyonTarihi: TEdit
            Left = 147
            Top = 25
            Width = 110
            Height = 21
            MaxLength = 24
            TabOrder = 3
          end
          object mmoSonrakiAksiyon: TMemo
            Left = 147
            Top = 47
            Width = 110
            Height = 21
            MaxLength = 160
            TabOrder = 5
          end
          object edtGenelIskontoYuzdesi: TEdit
            Left = 516
            Top = 3
            Width = 50
            Height = 21
            MaxLength = 10
            TabOrder = 1
          end
          object edtGenelIskontoTutar: TEdit
            Left = 576
            Top = 3
            Width = 50
            Height = 21
            MaxLength = 10
            TabOrder = 2
          end
          object cbbArayanKisi: TComboBox
            Left = 516
            Top = 25
            Width = 110
            Height = 21
            Style = csDropDownList
            TabOrder = 4
          end
          object edtAramaTarihi: TEdit
            Left = 516
            Top = 47
            Width = 110
            Height = 21
            MaxLength = 24
            TabOrder = 6
          end
          object edtSonGecerlilikTarihi: TEdit
            Left = 516
            Top = 69
            Width = 110
            Height = 21
            MaxLength = 24
            TabOrder = 7
          end
          object cbbIhracKayitKodu: TComboBox
            Left = 147
            Top = 114
            Width = 479
            Height = 21
            Style = csDropDownList
            MaxLength = 16
            Sorted = True
            TabOrder = 8
          end
          object cbbTevkifatKodu: TComboBox
            Left = 147
            Top = 136
            Width = 479
            Height = 21
            Style = csDropDownList
            MaxLength = 16
            Sorted = True
            TabOrder = 9
          end
          object cbbTevkifatPay: TComboBox
            Left = 147
            Top = 158
            Width = 46
            Height = 21
            Style = csDropDownList
            MaxLength = 16
            Sorted = True
            TabOrder = 10
          end
          object cbbTevkifatPayda: TComboBox
            Left = 211
            Top = 158
            Width = 46
            Height = 21
            Style = csDropDownList
            MaxLength = 16
            Sorted = True
            TabOrder = 11
          end
        end
      end
    end
    inherited pnlContent: TPanel
      Top = 332
      Width = 792
      Height = 208
      ExplicitTop = 332
      ExplicitWidth = 792
      ExplicitHeight = 208
      inherited pgcContent: TPageControl
        Width = 790
        Height = 204
        ExplicitWidth = 790
        ExplicitHeight = 204
        inherited ts1: TTabSheet
          ExplicitWidth = 782
          ExplicitHeight = 176
          inherited pnl1: TPanel
            Top = 92
            Width = 782
            ExplicitTop = 92
            ExplicitWidth = 782
            inherited grpGenelToplamKalan: TGroupBox
              Left = 312
              ExplicitLeft = 312
            end
            inherited grpGenelToplam: TGroupBox
              Left = 547
              ExplicitLeft = 547
            end
            inherited flwpnl1: TFlowPanel
              Width = 310
              ExplicitWidth = 310
            end
          end
          inherited strngrd1: TStringGrid
            Width = 782
            Height = 92
            ExplicitWidth = 782
            ExplicitHeight = 92
          end
        end
        inherited ts2: TTabSheet
          ExplicitWidth = 782
          ExplicitHeight = 144
          inherited pnl2: TPanel
            Top = 42
            Width = 782
            ExplicitTop = 10
            ExplicitWidth = 782
            inherited flwpnl2: TFlowPanel
              Width = 776
              ExplicitWidth = 776
            end
          end
          inherited strngrd2: TStringGrid
            Width = 782
            Height = 42
            ExplicitWidth = 782
            ExplicitHeight = 10
          end
        end
        inherited ts3: TTabSheet
          ExplicitWidth = 782
          ExplicitHeight = 176
          inherited strngrd3: TStringGrid
            Width = 782
            Height = 42
            ExplicitWidth = 782
            ExplicitHeight = 42
          end
          inherited pnl3: TPanel
            Top = 42
            Width = 782
            ExplicitTop = 42
            ExplicitWidth = 782
            inherited flwpnl3: TFlowPanel
              Width = 776
              ExplicitWidth = 776
            end
          end
        end
      end
      inherited btnHeaderShowHide: TButton
        Left = 701
        ExplicitLeft = 701
      end
    end
    inherited pnlLeft: TPanel
      Top = 333
      Height = 205
      ExplicitTop = 333
      ExplicitHeight = 205
    end
  end
  inherited pnlBottom: TPanel
    Top = 545
    Width = 900
    ExplicitTop = 545
    ExplicitWidth = 900
    inherited btnAccept: TButton
      Left = 691
      ExplicitLeft = 691
    end
    inherited btnClose: TButton
      Left = 795
      ExplicitLeft = 795
    end
  end
  inherited stbBase: TStatusBar
    Top = 575
    Width = 904
    ExplicitTop = 575
    ExplicitWidth = 904
  end
  inherited frxrprtBase: TfrxReport
    ScriptText.Strings = ()
  end
end

inherited frmStkStokKarti: TfrmStkStokKarti
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Stok Kart'#305
  ClientHeight = 548
  ClientWidth = 649
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 655
  ExplicitHeight = 577
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 645
    Height = 496
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 645
    ExplicitHeight = 496
    inherited pgcMain: TPageControl
      Width = 643
      Height = 494
      OnChange = pgcMainChange
      ExplicitWidth = 643
      ExplicitHeight = 494
      inherited tsMain: TTabSheet
        Caption = 'Genel'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 635
        ExplicitHeight = 466
        object lblortalama_maliyet_brm: TLabel
          Left = 302
          Top = 201
          Width = 16
          Height = 13
          Caption = 'TL'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblstok_kodu: TLabel
          Left = 86
          Top = 7
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
        object lblstok_adi: TLabel
          Left = 97
          Top = 29
          Width = 49
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Stok Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblstok_grubu_id: TLabel
          Left = 81
          Top = 61
          Width = 65
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Stok Grubu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblolcu_birimi_id: TLabel
          Left = 85
          Top = 83
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
        object lblen_az_stok_seviyesi: TLabel
          Left = 358
          Top = 335
          Width = 115
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'En Az Stok Seviyesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblalis_iskonto: TLabel
          Left = 352
          Top = 61
          Width = 67
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Al'#305#351' '#304'skonto'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsatis_iskonto: TLabel
          Left = 344
          Top = 83
          Width = 75
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305#351' '#304'skonto'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsatis_fiyat: TLabel
          Left = 86
          Top = 157
          Width = 60
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305#351' Fiyat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblihrac_fiyat: TLabel
          Left = 82
          Top = 179
          Width = 64
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304'hra'#231' Fiyat'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblortalama_maliyet: TLabel
          Left = 51
          Top = 201
          Width = 95
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ortalama Maliyet'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_satilabilir: TLabel
          Left = 363
          Top = 7
          Width = 60
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305'labilir?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblozel_kod: TLabel
          Left = 94
          Top = 253
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'zel Kod'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltanim: TLabel
          Left = 111
          Top = 379
          Width = 35
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tan'#305'm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblurun_tipi_id: TLabel
          Left = 93
          Top = 105
          Width = 53
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'r'#252'n Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblen: TLabel
          Left = 457
          Top = 247
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
          Left = 451
          Top = 269
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
          Left = 417
          Top = 291
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
        object lblhacim: TLabel
          Left = 548
          Top = 271
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
        object lblvalue_hacim: TLabel
          Left = 592
          Top = 271
          Width = 24
          Height = 13
          Caption = '0m3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblen_boy_yuseklik_brm: TLabel
          Left = 541
          Top = 247
          Width = 17
          Height = 13
          Caption = 'cm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblmarka: TLabel
          Left = 110
          Top = 275
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Marka'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblagirlik: TLabel
          Left = 437
          Top = 313
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'A'#287#305'rl'#305'k'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldiib_urun_tanimi: TLabel
          Left = 47
          Top = 357
          Width = 98
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D'#304#304'B '#220'r'#252'n Tan'#305'm'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmensei_id: TLabel
          Left = 104
          Top = 313
          Width = 41
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Men'#351'ei'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgtip_no: TLabel
          Left = 95
          Top = 335
          Width = 50
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'GTIP No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltemin_suresi: TLabel
          Left = 72
          Top = 231
          Width = 74
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Temin S'#252'resi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblalis_fiyat: TLabel
          Left = 94
          Top = 136
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Al'#305#351' Fiyat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblagirlik_birim: TLabel
          Left = 541
          Top = 313
          Width = 12
          Height = 13
          Caption = 'gr'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lbltemin_suresi_brm: TLabel
          Left = 217
          Top = 231
          Width = 22
          Height = 13
          Caption = 'g'#252'n'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtstok_kodu: TEdit
          Left = 150
          Top = 4
          Width = 150
          Height = 21
          TabOrder = 0
        end
        object edtstok_adi: TEdit
          Left = 150
          Top = 26
          Width = 477
          Height = 21
          TabOrder = 2
        end
        object edtstok_grubu_id: TEdit
          Left = 150
          Top = 58
          Width = 150
          Height = 21
          TabOrder = 3
        end
        object edtolcu_birimi_id: TEdit
          Left = 150
          Top = 80
          Width = 150
          Height = 21
          TabOrder = 6
        end
        object edtalis_iskonto: TEdit
          Left = 423
          Top = 58
          Width = 48
          Height = 21
          TabOrder = 4
        end
        object edtsatis_iskonto: TEdit
          Left = 423
          Top = 80
          Width = 48
          Height = 21
          TabOrder = 7
        end
        object edturun_tipi_id: TEdit
          Left = 150
          Top = 102
          Width = 150
          Height = 21
          TabOrder = 8
        end
        object edtalis_fiyat: TEdit
          Left = 150
          Top = 132
          Width = 104
          Height = 21
          Alignment = taRightJustify
          TabOrder = 9
        end
        object edtsatis_fiyat: TEdit
          Left = 150
          Top = 154
          Width = 104
          Height = 21
          Alignment = taRightJustify
          TabOrder = 11
        end
        object edtihrac_fiyat: TEdit
          Left = 150
          Top = 176
          Width = 104
          Height = 21
          Alignment = taRightJustify
          TabOrder = 13
        end
        object edtortalama_maliyet: TEdit
          Left = 150
          Top = 198
          Width = 149
          Height = 21
          TabOrder = 15
        end
        object edttemin_suresi: TEdit
          Left = 150
          Top = 228
          Width = 62
          Height = 21
          TabOrder = 17
        end
        object edtozel_kod: TEdit
          Left = 150
          Top = 250
          Width = 150
          Height = 21
          TabOrder = 19
        end
        object edtmarka: TEdit
          Left = 150
          Top = 272
          Width = 150
          Height = 21
          TabOrder = 21
        end
        object edtmensei_id: TEdit
          Left = 150
          Top = 310
          Width = 150
          Height = 21
          TabOrder = 23
        end
        object edtgtip_no: TEdit
          Left = 150
          Top = 332
          Width = 150
          Height = 21
          TabOrder = 25
        end
        object edten: TEdit
          Left = 477
          Top = 244
          Width = 60
          Height = 21
          TabOrder = 18
        end
        object edtboy: TEdit
          Left = 477
          Top = 266
          Width = 60
          Height = 21
          TabOrder = 20
        end
        object edtyukseklik: TEdit
          Left = 477
          Top = 288
          Width = 60
          Height = 21
          TabOrder = 22
        end
        object edtagirlik: TEdit
          Left = 477
          Top = 310
          Width = 60
          Height = 21
          TabOrder = 24
        end
        object edten_az_stok_seviyesi: TEdit
          Left = 477
          Top = 332
          Width = 104
          Height = 21
          TabOrder = 26
        end
        object edtdiib_urun_tanimi: TEdit
          Left = 150
          Top = 354
          Width = 477
          Height = 21
          TabOrder = 27
        end
        object mmotanim: TMemo
          Left = 150
          Top = 376
          Width = 477
          Height = 68
          TabOrder = 28
        end
        object chkis_satilabilir: TCheckBox
          Left = 427
          Top = 4
          Width = 48
          Height = 21
          TabStop = False
          TabOrder = 1
        end
        object btnstok_resim: TBitBtn
          Left = 477
          Top = 208
          Width = 150
          Height = 25
          TabOrder = 16
          TabStop = False
          OnClick = btnstok_resimClick
        end
        object pnlstok_resim: TPanel
          Left = 477
          Top = 58
          Width = 150
          Height = 150
          BevelInner = bvLowered
          TabOrder = 5
          object imgstok_resim: TImage
            Left = 2
            Top = 2
            Width = 146
            Height = 146
            Align = alClient
            Stretch = True
            ExplicitLeft = 0
            ExplicitTop = 0
            ExplicitWidth = 150
            ExplicitHeight = 150
          end
        end
        object edtalis_para: TEdit
          Left = 256
          Top = 132
          Width = 44
          Height = 21
          TabOrder = 10
        end
        object edtsatis_para: TEdit
          Left = 256
          Top = 154
          Width = 44
          Height = 21
          TabOrder = 12
        end
        object edtihrac_para: TEdit
          Left = 256
          Top = 176
          Width = 44
          Height = 21
          TabOrder = 14
        end
      end
      object tsCinsOzelligi: TTabSheet
        Caption = 'Cins '#214'zelli'#287'i'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object lbld3: TLabel
          Left = 132
          Top = 391
          Width = 17
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbld2: TLabel
          Left = 132
          Top = 369
          Width = 17
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbld1: TLabel
          Left = 132
          Top = 347
          Width = 17
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbli3: TLabel
          Left = 137
          Top = 303
          Width = 12
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'I3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbli2: TLabel
          Left = 137
          Top = 281
          Width = 12
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'I2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbli1: TLabel
          Left = 137
          Top = 259
          Width = 12
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'I1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls6: TLabel
          Left = 133
          Top = 193
          Width = 16
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S6'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls5: TLabel
          Left = 133
          Top = 171
          Width = 16
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S5'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls4: TLabel
          Left = 133
          Top = 149
          Width = 16
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S4'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls3: TLabel
          Left = 133
          Top = 127
          Width = 16
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls2: TLabel
          Left = 133
          Top = 105
          Width = 16
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls1: TLabel
          Left = 133
          Top = 83
          Width = 16
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcins_id: TLabel
          Left = 124
          Top = 61
          Width = 25
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Cins'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls8: TLabel
          Left = 133
          Top = 237
          Width = 16
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S8'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls7: TLabel
          Left = 133
          Top = 215
          Width = 16
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S7'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbli4: TLabel
          Left = 137
          Top = 325
          Width = 12
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'I4'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbld4: TLabel
          Left = 132
          Top = 413
          Width = 17
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D4'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtcins_id: TEdit
          Left = 153
          Top = 58
          Width = 160
          Height = 21
          TabOrder = 1
          OnChange = edtcins_idChange
        end
        object edts1: TEdit
          Left = 153
          Top = 80
          Width = 160
          Height = 21
          TabOrder = 2
        end
        object edts2: TEdit
          Left = 153
          Top = 102
          Width = 160
          Height = 21
          TabOrder = 3
        end
        object edts3: TEdit
          Left = 153
          Top = 124
          Width = 160
          Height = 21
          TabOrder = 4
        end
        object edts4: TEdit
          Left = 153
          Top = 146
          Width = 160
          Height = 21
          TabOrder = 5
        end
        object edts5: TEdit
          Left = 153
          Top = 168
          Width = 160
          Height = 21
          TabOrder = 6
        end
        object edts6: TEdit
          Left = 153
          Top = 190
          Width = 160
          Height = 21
          TabOrder = 7
        end
        object edti1: TEdit
          Left = 153
          Top = 256
          Width = 160
          Height = 21
          TabOrder = 10
        end
        object edti2: TEdit
          Left = 153
          Top = 278
          Width = 160
          Height = 21
          TabOrder = 11
        end
        object edti3: TEdit
          Left = 153
          Top = 300
          Width = 160
          Height = 21
          TabOrder = 12
        end
        object edtd1: TEdit
          Left = 153
          Top = 344
          Width = 160
          Height = 21
          TabOrder = 14
        end
        object edtd2: TEdit
          Left = 153
          Top = 366
          Width = 160
          Height = 21
          TabOrder = 15
        end
        object edtd3: TEdit
          Left = 153
          Top = 388
          Width = 160
          Height = 21
          TabOrder = 16
        end
        object edts7: TEdit
          Left = 153
          Top = 212
          Width = 160
          Height = 21
          TabOrder = 8
        end
        object edts8: TEdit
          Left = 153
          Top = 234
          Width = 160
          Height = 21
          TabOrder = 9
        end
        object edti4: TEdit
          Left = 153
          Top = 322
          Width = 160
          Height = 21
          TabOrder = 13
        end
        object edtd4: TEdit
          Left = 153
          Top = 410
          Width = 160
          Height = 21
          TabOrder = 17
        end
        object pnlCinsHeader: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 4
          Width = 629
          Height = 52
          Margins.Top = 4
          Margins.Bottom = 4
          Align = alTop
          Color = 14737632
          ParentBackground = False
          TabOrder = 0
        end
      end
      object tsOzetler: TTabSheet
        Caption = #214'zetler'
        ImageIndex = 3
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object pnlOzetHeader: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 4
          Width = 629
          Height = 52
          Margins.Top = 4
          Margins.Bottom = 4
          Align = alTop
          Color = 14737632
          ParentBackground = False
          TabOrder = 0
        end
        object pnlOzetTop: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 64
          Width = 629
          Height = 137
          Margins.Top = 4
          Margins.Bottom = 4
          Align = alTop
          Color = 14085611
          ParentBackground = False
          TabOrder = 1
          object lblserbest_stok_toplam_brm: TLabel
            Left = 257
            Top = 116
            Width = 28
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblserbest_stok_toplam: TLabel
            Left = 25
            Top = 116
            Width = 119
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Serbest Stok Toplam'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblblokaj_toplam_brm: TLabel
            Left = 257
            Top = 94
            Width = 28
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblblokaj_toplam: TLabel
            Left = 63
            Top = 94
            Width = 81
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Blokaj Toplam'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_miktar_brm: TLabel
            Left = 257
            Top = 6
            Width = 28
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblgiren_toplam_brm: TLabel
            Left = 257
            Top = 28
            Width = 28
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblcikan_toplam_brm: TLabel
            Left = 257
            Top = 50
            Width = 28
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblstok_miktari_brm: TLabel
            Left = 257
            Top = 72
            Width = 28
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblstok_miktari: TLabel
            Left = 75
            Top = 72
            Width = 69
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Stok Miktar'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblcikan_toplam: TLabel
            Left = 70
            Top = 50
            Width = 74
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = #199#305'kanToplam'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblgiren_toplam: TLabel
            Left = 68
            Top = 28
            Width = 76
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Giren Toplam'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_miktar: TLabel
            Left = 37
            Top = 6
            Width = 107
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'D'#246'nem Ba'#351#305' Miktar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object edtdonem_basi_miktar: TEdit
            Left = 150
            Top = 3
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 0
          end
          object edtgiren_toplam: TEdit
            Left = 150
            Top = 25
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 1
          end
          object edtcikan_toplam: TEdit
            Left = 150
            Top = 47
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 2
          end
          object edtstok_miktari: TEdit
            Left = 150
            Top = 69
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 3
          end
          object edtblokaj_toplam: TEdit
            Left = 150
            Top = 91
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 4
          end
          object edtserbest_stok_toplam: TEdit
            Left = 150
            Top = 113
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 5
          end
        end
        object pnlOzetMiddle: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 209
          Width = 629
          Height = 151
          Margins.Top = 4
          Margins.Bottom = 4
          Align = alClient
          Color = 15527135
          ParentBackground = False
          TabOrder = 2
          object lblstok_degeri_ort_brm: TLabel
            Left = 257
            Top = 50
            Width = 57
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblstok_degeri_son_brm: TLabel
            Left = 257
            Top = 72
            Width = 57
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_deger_brm: TLabel
            Left = 257
            Top = 28
            Width = 57
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblstok_degeri_son: TLabel
            Left = 15
            Top = 72
            Width = 129
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Stok De'#287'eri(Son Fiyat)'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblstok_degeri_ort: TLabel
            Left = 16
            Top = 50
            Width = 128
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Stok De'#287'eri(Ort. Fiyat)'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_deger: TLabel
            Left = 38
            Top = 28
            Width = 106
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'D'#246'nem Ba'#351#305' De'#287'er'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_fiyat_brm: TLabel
            Left = 257
            Top = 6
            Width = 57
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltoplam_alis_brm: TLabel
            Left = 257
            Top = 94
            Width = 57
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltoplam_satis_brm: TLabel
            Left = 257
            Top = 116
            Width = 57
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltoplam_satis: TLabel
            Left = 70
            Top = 116
            Width = 74
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Toplam Sat'#305#351
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltoplam_alis: TLabel
            Left = 78
            Top = 94
            Width = 66
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Toplam Al'#305#351
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_fiyat: TLabel
            Left = 45
            Top = 6
            Width = 99
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'D'#246'nem Ba'#351#305' Fiyat'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object edtdonem_basi_fiyat: TEdit
            Left = 150
            Top = 3
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 0
          end
          object edtdonem_basi_deger: TEdit
            Left = 150
            Top = 25
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 1
          end
          object edtstok_degeri_ort: TEdit
            Left = 150
            Top = 47
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 2
          end
          object edtstok_degeri_son: TEdit
            Left = 150
            Top = 69
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 3
          end
          object edttoplam_alis: TEdit
            Left = 150
            Top = 91
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 4
          end
          object edttoplam_satis: TEdit
            Left = 150
            Top = 113
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 5
          end
        end
        object pnlOzetBottom: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 368
          Width = 629
          Height = 94
          Margins.Top = 4
          Margins.Bottom = 4
          Align = alBottom
          Color = 14146536
          ParentBackground = False
          TabOrder = 3
          object lblozet_son_alis_brm: TLabel
            Left = 256
            Top = 73
            Width = 57
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_alis_brm: TLabel
            Left = 256
            Top = 29
            Width = 57
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_ortalama_maliyet_brm: TLabel
            Left = 256
            Top = 51
            Width = 57
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_satis_brm: TLabel
            Left = 256
            Top = 7
            Width = 57
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_son_alis: TLabel
            Left = 63
            Top = 73
            Width = 81
            Height = 13
            Alignment = taRightJustify
            Caption = 'Son Al'#305#351' Fiyat'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_ortalama_maliyet: TLabel
            Left = 49
            Top = 51
            Width = 95
            Height = 13
            Alignment = taRightJustify
            Caption = 'Ortalama Maliyet'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_alis: TLabel
            Left = 123
            Top = 29
            Width = 21
            Height = 13
            Alignment = taRightJustify
            Caption = 'Al'#305#351
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_satis: TLabel
            Left = 115
            Top = 7
            Width = 29
            Height = 13
            Alignment = taRightJustify
            Caption = 'Sat'#305#351
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object edtozet_satis: TEdit
            Left = 150
            Top = 4
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 0
          end
          object edtozet_alis: TEdit
            Left = 150
            Top = 26
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 1
          end
          object edtozet_ortalama_maliyet: TEdit
            Left = 150
            Top = 48
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 2
          end
          object edtozet_son_alis: TEdit
            Left = 150
            Top = 70
            Width = 100
            Height = 21
            MaxLength = 16
            TabOrder = 3
          end
        end
      end
      object tsGrupOzellikleri: TTabSheet
        Caption = 'Grup '#214'zellikleri'
        ImageIndex = 4
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object pnlGrupHeader: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 4
          Width = 629
          Height = 52
          Margins.Top = 4
          Margins.Bottom = 4
          Align = alTop
          Color = 14737632
          ParentBackground = False
          TabOrder = 0
        end
        object pnlGrupOzellikleri: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 63
          Width = 629
          Height = 158
          Align = alClient
          Color = 15268861
          ParentBackground = False
          TabOrder = 1
          object lblgrup_hammadde: TLabel
            Left = 71
            Top = 138
            Width = 106
            Height = 13
            Alignment = taRightJustify
            Caption = 'Hammadde Hesab'#305
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblgrup_mamul: TLabel
            Left = 98
            Top = 121
            Width = 79
            Height = 13
            Alignment = taRightJustify
            Caption = 'Mam'#252'l Hesab'#305
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblgrup_hammadde_val: TLabel
            Left = 182
            Top = 138
            Width = 110
            Height = 13
            Caption = 'lblgrup_hammadde_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblgrup_mamul_val: TLabel
            Left = 182
            Top = 121
            Width = 88
            Height = 13
            Caption = 'lblgrup_mamul_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblgrup_adi_val: TLabel
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 50
            Height = 13
            Align = alTop
            Alignment = taCenter
            Caption = 'Grup Ad'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblgrup_kdv_orani: TLabel
            Left = 122
            Top = 19
            Width = 55
            Height = 13
            Alignment = taRightJustify
            Caption = 'KDV Oran'#305
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblgrup_kdv_orani_val: TLabel
            Left = 182
            Top = 19
            Width = 105
            Height = 13
            Caption = 'lblgrup_kdv_orani_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblgrup_ihracat: TLabel
            Left = 94
            Top = 104
            Width = 83
            Height = 13
            Alignment = taRightJustify
            Caption = #304'hracat Hesab'#305
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblgrup_ihracat_val: TLabel
            Left = 182
            Top = 104
            Width = 110
            Height = 13
            Caption = 'lblgrup_hammadde_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblgrup_alis_iade_kodu: TLabel
            Left = 27
            Top = 87
            Width = 150
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'Al'#305#351' '#304'ade Vergi Hesap Kodu'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblgrup_alis_kodu: TLabel
            Left = 56
            Top = 70
            Width = 121
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'Al'#305#351' Vergi Hesap Kodu'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblgrup_satis_iade_kodu: TLabel
            Left = 19
            Top = 53
            Width = 158
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'Sat'#305#351' '#304'ade Vergi Hesap Kodu'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblgrup_satis_kodu: TLabel
            Left = 48
            Top = 36
            Width = 129
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'Sat'#305#351' Vergi Hesap Kodu'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblgrup_alis_kodu_val: TLabel
            Left = 182
            Top = 70
            Width = 110
            Height = 13
            Caption = 'lblgrup_hammadde_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblgrup_satis_iade_kodu_val: TLabel
            Left = 182
            Top = 53
            Width = 88
            Height = 13
            Caption = 'lblgrup_mamul_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblgrup_satis_kodu_val: TLabel
            Left = 182
            Top = 36
            Width = 110
            Height = 13
            Caption = 'lblgrup_hammadde_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblgrup_alis_iade_kodu_val: TLabel
            Left = 182
            Top = 87
            Width = 110
            Height = 13
            Caption = 'lblgrup_hammadde_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
        end
        object pnlAmbar: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 227
          Width = 629
          Height = 236
          Align = alBottom
          TabOrder = 2
          object lblAmbarlar: TLabel
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 127
            Height = 13
            Hint = 'Hide'
            Align = alTop
            Alignment = taCenter
            Caption = 'Ambar Stok Durumlar'#305' '
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object strngrdAmbar: TStringGrid
            AlignWithMargins = True
            Left = 4
            Top = 23
            Width = 621
            Height = 209
            Align = alClient
            ColCount = 7
            DefaultRowHeight = 20
            FixedColor = 8421440
            FixedCols = 0
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
            TabOrder = 0
            ColWidths = (
              126
              71
              73
              71
              71
              75
              90)
            RowHeights = (
              20
              20
              20
              20
              20)
          end
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 500
    Width = 645
    ExplicitTop = 500
    ExplicitWidth = 645
    inherited btnAccept: TButton
      Left = 436
      ExplicitLeft = 436
    end
    inherited btnClose: TButton
      Left = 540
      ExplicitLeft = 540
    end
  end
  inherited stbBase: TStatusBar
    Top = 530
    Width = 649
    ExplicitTop = 530
    ExplicitWidth = 649
  end
end

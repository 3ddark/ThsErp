inherited frmStkKart: TfrmStkKart
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Stok Kart'#305
  ClientHeight = 532
  ClientWidth = 642
  Font.Charset = TURKISH_CHARSET
  ExplicitWidth = 656
  ExplicitHeight = 568
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 642
    Height = 482
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 640
    ExplicitHeight = 479
    inherited pgcMain: TPageControl
      Width = 642
      Height = 482
      OnChange = pgcMainChange
      ExplicitWidth = 640
      ExplicitHeight = 479
      inherited tsMain: TTabSheet
        ExplicitWidth = 634
        ExplicitHeight = 454
        object lblstok_kodu: TLabel
          Left = 89
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
        object lblstok_adi: TLabel
          Left = 99
          Top = 29
          Width = 47
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Stok Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblstok_grubu_id: TLabel
          Left = 83
          Top = 59
          Width = 63
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Stok Grubu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblolcu_birimi_id: TLabel
          Left = 87
          Top = 81
          Width = 59
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblen_az_stok_seviyesi: TLabel
          Left = 37
          Top = 339
          Width = 109
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'En Az Stok Seviyesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_satilabilir: TLabel
          Left = 364
          Top = 7
          Width = 59
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305'labilir?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblozel_kod: TLabel
          Left = 98
          Top = 147
          Width = 48
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'zel Kod'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltanim: TLabel
          Left = 111
          Top = 383
          Width = 35
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tan'#305'm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblurun_tipi: TLabel
          Left = 96
          Top = 103
          Width = 50
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'r'#252'n Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblen: TLabel
          Left = 460
          Top = 251
          Width = 13
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'En'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblboy: TLabel
          Left = 452
          Top = 273
          Width = 21
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Boy'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblyukseklik: TLabel
          Left = 419
          Top = 295
          Width = 54
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Y'#252'kseklik'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblhacim: TLabel
          Left = 438
          Top = 316
          Width = 35
          Height = 13
          Alignment = taRightJustify
          Caption = 'Hacim'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblvalue_hacim: TLabel
          Left = 513
          Top = 316
          Width = 24
          Height = 13
          Alignment = taRightJustify
          Caption = '0,00'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblen_boy_yuseklik_brm: TLabel
          Left = 541
          Top = 251
          Width = 17
          Height = 13
          Caption = 'cm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblmarka: TLabel
          Left = 110
          Top = 169
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Marka'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblagirlik: TLabel
          Left = 437
          Top = 339
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'A'#287#305'rl'#305'k'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldiib_urun_tanimi: TLabel
          Left = 49
          Top = 361
          Width = 96
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D'#304#304'B '#220'r'#252'n Tan'#305'm'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmensei_id: TLabel
          Left = 105
          Top = 298
          Width = 40
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Men'#351'ei'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgtip_no: TLabel
          Left = 101
          Top = 317
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'GTIP No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltemin_suresi: TLabel
          Left = 73
          Top = 125
          Width = 73
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Temin S'#252'resi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblagirlik_birim: TLabel
          Left = 541
          Top = 339
          Width = 12
          Height = 13
          Caption = 'gr'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lbltemin_suresi_brm: TLabel
          Left = 217
          Top = 125
          Width = 21
          Height = 13
          Caption = 'g'#252'n'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label1: TLabel
          Left = 541
          Top = 273
          Width = 17
          Height = 13
          Caption = 'cm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label2: TLabel
          Left = 541
          Top = 295
          Width = 17
          Height = 13
          Caption = 'cm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label3: TLabel
          Left = 541
          Top = 316
          Width = 18
          Height = 13
          Caption = 'm3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
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
          Top = 56
          Width = 150
          Height = 21
          TabOrder = 3
        end
        object edtolcu_birimi_id: TEdit
          Left = 150
          Top = 78
          Width = 150
          Height = 21
          TabOrder = 5
        end
        object edttemin_suresi: TEdit
          Left = 150
          Top = 122
          Width = 62
          Height = 21
          TabOrder = 7
        end
        object edtozel_kod: TEdit
          Left = 150
          Top = 144
          Width = 150
          Height = 21
          TabOrder = 8
        end
        object edtmarka: TEdit
          Left = 150
          Top = 166
          Width = 150
          Height = 21
          TabOrder = 9
        end
        object edtmensei_id: TEdit
          Left = 150
          Top = 292
          Width = 150
          Height = 21
          TabOrder = 13
        end
        object edtgtip_no: TEdit
          Left = 150
          Top = 314
          Width = 150
          Height = 21
          TabOrder = 15
        end
        object edten: TEdit
          Left = 477
          Top = 248
          Width = 60
          Height = 21
          TabOrder = 11
          OnChange = edtenChange
        end
        object edtboy: TEdit
          Left = 477
          Top = 270
          Width = 60
          Height = 21
          TabOrder = 12
          OnChange = edtenChange
        end
        object edtyukseklik: TEdit
          Left = 477
          Top = 292
          Width = 60
          Height = 21
          TabOrder = 14
          OnChange = edtenChange
        end
        object edtagirlik: TEdit
          Left = 477
          Top = 336
          Width = 60
          Height = 21
          TabOrder = 17
        end
        object edten_az_stok_seviyesi: TEdit
          Left = 150
          Top = 336
          Width = 150
          Height = 21
          TabOrder = 16
        end
        object edtdiib_urun_tanimi: TEdit
          Left = 150
          Top = 358
          Width = 477
          Height = 21
          TabOrder = 18
        end
        object mmotanim: TMemo
          Left = 150
          Top = 380
          Width = 477
          Height = 68
          TabOrder = 19
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
          Top = 205
          Width = 150
          Height = 25
          TabOrder = 10
          TabStop = False
          OnClick = btnstok_resimClick
        end
        object pnlstok_resim: TPanel
          Left = 477
          Top = 56
          Width = 150
          Height = 150
          BevelInner = bvLowered
          TabOrder = 4
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
        object cbburun_tipi: TComboBox
          Left = 150
          Top = 100
          Width = 150
          Height = 21
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 6
          Text = 'Hammadde'
          Items.Strings = (
            'Hammadde'
            'Yar'#305' Mam'#252'l'
            'Mam'#252'l'
            'Hizmet')
        end
      end
      object tsParasal: TTabSheet
        Caption = 'Parasal Bilgi'
        ImageIndex = 4
        object lblortalama_maliyet_brm: TLabel
          Left = 302
          Top = 199
          Width = 13
          Height = 13
          Caption = 'TL'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblsatis_fiyat: TLabel
          Left = 87
          Top = 155
          Width = 59
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305#351' Fiyat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblihrac_fiyat: TLabel
          Left = 82
          Top = 177
          Width = 64
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304'hra'#231' Fiyat'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblortalama_maliyet: TLabel
          Left = 48
          Top = 199
          Width = 98
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ortalama Maliyet'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblalis_fiyat: TLabel
          Left = 95
          Top = 134
          Width = 51
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Al'#305#351' Fiyat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblalis_iskonto: TLabel
          Left = 352
          Top = 59
          Width = 67
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Al'#305#351' '#304'skonto'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsatis_iskonto: TLabel
          Left = 344
          Top = 81
          Width = 75
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sat'#305#351' '#304'skonto'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtalis_fiyat: TEdit
          Left = 150
          Top = 130
          Width = 104
          Height = 21
          Alignment = taRightJustify
          TabOrder = 3
        end
        object edtsatis_fiyat: TEdit
          Left = 150
          Top = 152
          Width = 104
          Height = 21
          Alignment = taRightJustify
          TabOrder = 5
        end
        object edtihrac_fiyat: TEdit
          Left = 150
          Top = 174
          Width = 104
          Height = 21
          Alignment = taRightJustify
          TabOrder = 7
        end
        object edtortalama_maliyet: TEdit
          Left = 150
          Top = 196
          Width = 150
          Height = 21
          TabOrder = 9
        end
        object edtalis_para: TEdit
          Left = 256
          Top = 130
          Width = 44
          Height = 21
          TabOrder = 4
        end
        object edtsatis_para: TEdit
          Left = 256
          Top = 152
          Width = 44
          Height = 21
          TabOrder = 6
        end
        object edtihrac_para: TEdit
          Left = 256
          Top = 174
          Width = 44
          Height = 21
          TabOrder = 8
        end
        object edtalis_iskonto: TEdit
          Left = 423
          Top = 56
          Width = 48
          Height = 21
          TabOrder = 1
        end
        object edtsatis_iskonto: TEdit
          Left = 423
          Top = 78
          Width = 48
          Height = 21
          TabOrder = 2
        end
        object pnlParasalHeader: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 4
          Width = 628
          Height = 52
          Margins.Top = 4
          Margins.Bottom = 4
          Align = alTop
          Color = 14737632
          ParentBackground = False
          TabOrder = 0
        end
      end
      object tsCinsOzelligi: TTabSheet
        Caption = 'Cins '#214'zelli'#287'i'
        ImageIndex = 1
        object lbld3: TLabel
          Left = 437
          Top = 235
          Width = 15
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbld2: TLabel
          Left = 437
          Top = 213
          Width = 15
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbld1: TLabel
          Left = 437
          Top = 191
          Width = 15
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbli3: TLabel
          Left = 440
          Top = 125
          Width = 12
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'I3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbli2: TLabel
          Left = 440
          Top = 103
          Width = 12
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'I2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbli1: TLabel
          Left = 440
          Top = 81
          Width = 12
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'I1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls6: TLabel
          Left = 127
          Top = 191
          Width = 14
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S6'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls5: TLabel
          Left = 127
          Top = 169
          Width = 14
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S5'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls4: TLabel
          Left = 127
          Top = 147
          Width = 14
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S4'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls3: TLabel
          Left = 127
          Top = 125
          Width = 14
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls2: TLabel
          Left = 127
          Top = 103
          Width = 14
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls1: TLabel
          Left = 127
          Top = 81
          Width = 14
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcins_id: TLabel
          Left = 118
          Top = 59
          Width = 23
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Cins'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls8: TLabel
          Left = 127
          Top = 235
          Width = 14
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S8'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls7: TLabel
          Left = 127
          Top = 213
          Width = 14
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S7'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbli4: TLabel
          Left = 440
          Top = 147
          Width = 12
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'I4'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbld4: TLabel
          Left = 437
          Top = 257
          Width = 15
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D4'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls9: TLabel
          Left = 127
          Top = 257
          Width = 14
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S9'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbls10: TLabel
          Left = 120
          Top = 279
          Width = 21
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S10'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbli5: TLabel
          Left = 440
          Top = 169
          Width = 12
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'I5'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbld5: TLabel
          Left = 437
          Top = 279
          Width = 15
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D5'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtcins_id: TEdit
          Left = 145
          Top = 56
          Width = 160
          Height = 21
          TabOrder = 1
          OnChange = edtcins_idChange
        end
        object edts1: TEdit
          Left = 145
          Top = 78
          Width = 160
          Height = 21
          TabOrder = 2
        end
        object edts2: TEdit
          Left = 145
          Top = 100
          Width = 160
          Height = 21
          TabOrder = 4
        end
        object edts3: TEdit
          Left = 145
          Top = 122
          Width = 160
          Height = 21
          TabOrder = 6
        end
        object edts4: TEdit
          Left = 145
          Top = 144
          Width = 160
          Height = 21
          TabOrder = 8
        end
        object edts5: TEdit
          Left = 145
          Top = 166
          Width = 160
          Height = 21
          TabOrder = 10
        end
        object edts6: TEdit
          Left = 145
          Top = 188
          Width = 160
          Height = 21
          TabOrder = 12
        end
        object edti1: TEdit
          Left = 456
          Top = 78
          Width = 160
          Height = 21
          TabOrder = 3
        end
        object edti2: TEdit
          Left = 456
          Top = 100
          Width = 160
          Height = 21
          TabOrder = 5
        end
        object edti3: TEdit
          Left = 456
          Top = 122
          Width = 160
          Height = 21
          TabOrder = 7
        end
        object edtd1: TEdit
          Left = 456
          Top = 188
          Width = 160
          Height = 21
          TabOrder = 13
        end
        object edtd2: TEdit
          Left = 456
          Top = 210
          Width = 160
          Height = 21
          TabOrder = 15
        end
        object edtd3: TEdit
          Left = 456
          Top = 232
          Width = 160
          Height = 21
          TabOrder = 17
        end
        object edts7: TEdit
          Left = 145
          Top = 210
          Width = 160
          Height = 21
          TabOrder = 14
        end
        object edts8: TEdit
          Left = 145
          Top = 232
          Width = 160
          Height = 21
          TabOrder = 16
        end
        object edti4: TEdit
          Left = 456
          Top = 144
          Width = 160
          Height = 21
          TabOrder = 9
        end
        object edtd4: TEdit
          Left = 456
          Top = 254
          Width = 160
          Height = 21
          TabOrder = 19
        end
        object pnlCinsHeader: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 4
          Width = 628
          Height = 52
          Margins.Top = 4
          Margins.Bottom = 4
          Align = alTop
          Color = 14737632
          ParentBackground = False
          TabOrder = 0
          ExplicitWidth = 626
        end
        object edts9: TEdit
          Left = 145
          Top = 254
          Width = 160
          Height = 21
          TabOrder = 18
        end
        object edts10: TEdit
          Left = 145
          Top = 276
          Width = 160
          Height = 21
          TabOrder = 20
        end
        object edti5: TEdit
          Left = 456
          Top = 166
          Width = 160
          Height = 21
          TabOrder = 11
        end
        object edtd5: TEdit
          Left = 456
          Top = 276
          Width = 160
          Height = 21
          TabOrder = 21
        end
      end
      object tsGrupOzellikleri: TTabSheet
        Caption = 'Grup '#214'zellikleri'
        ImageIndex = 4
        object pnlGrupHeader: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 4
          Width = 628
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
          Width = 628
          Height = 160
          Align = alClient
          Color = 15268861
          ParentBackground = False
          TabOrder = 1
          object lblhammadde_stok_hesap_kodu: TLabel
            Left = 50
            Top = 36
            Width = 135
            Height = 13
            Alignment = taRightJustify
            Caption = 'Hammadde Stok Hesab'#305
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblhammadde_kullanim_hesap_kodu: TLabel
            Left = 28
            Top = 53
            Width = 157
            Height = 13
            Alignment = taRightJustify
            Caption = 'Hammadde Kullan'#305'm Hesab'#305
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblhammadde_stok_hesap_kodu_val: TLabel
            Left = 188
            Top = 36
            Width = 172
            Height = 13
            Caption = 'lblhammadde_stok_hesap_kodu_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblhammadde_kullanim_hesap_kodu_val: TLabel
            Left = 188
            Top = 53
            Width = 189
            Height = 13
            Caption = 'lblhammadde_kullanim_hesap_kodu_val'
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
            Width = 620
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
            ExplicitWidth = 50
          end
          object lblgrup_kdv_orani: TLabel
            Left = 130
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
            Left = 188
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
          object lblalis_iade_hesap_kodu: TLabel
            Left = 35
            Top = 138
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
          object lblalis_hesap_kodu: TLabel
            Left = 64
            Top = 121
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
          object lblsatis_iade_hesap_kodu: TLabel
            Left = 27
            Top = 104
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
          object lblsatis_hesap_kodu: TLabel
            Left = 56
            Top = 87
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
          object lblalis_hesap_kodu_val: TLabel
            Left = 188
            Top = 121
            Width = 109
            Height = 13
            Caption = 'lblalis_hesap_kodu_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblsatis_iade_hesap_kodu_val: TLabel
            Left = 188
            Top = 104
            Width = 142
            Height = 13
            Caption = 'lblsatis_iade_hesap_kodu_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblsatis_hesap_kodu_val: TLabel
            Left = 188
            Top = 87
            Width = 116
            Height = 13
            Caption = 'lblsatis_hesap_kodu_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblalis_iade_hesap_kodu_val: TLabel
            Left = 188
            Top = 138
            Width = 135
            Height = 13
            Caption = 'lblalis_iade_hesap_kodu_val'
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblyari_mamul_hesap_kodu: TLabel
            Left = 81
            Top = 70
            Width = 104
            Height = 13
            Alignment = taRightJustify
            Caption = 'Yar'#305' Mam'#252'l Hesab'#305
            Font.Charset = TURKISH_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblyari_mamul_hesap_kodu_val: TLabel
            Left = 188
            Top = 70
            Width = 148
            Height = 13
            Caption = 'lblyari_mamul_hesap_kodu_val'
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
          Top = 229
          Width = 628
          Height = 222
          Align = alBottom
          TabOrder = 2
          Visible = False
          object lblAmbarlar: TLabel
            AlignWithMargins = True
            Left = 4
            Top = 4
            Width = 620
            Height = 13
            Hint = 'Hide'
            Align = alTop
            Alignment = taCenter
            Caption = 'Ambar Stok Durumlar'#305' '
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            ExplicitWidth = 129
          end
          object strngrdAmbar: TStringGrid
            AlignWithMargins = True
            Left = 4
            Top = 23
            Width = 620
            Height = 195
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
      object tsOzetler: TTabSheet
        Caption = #214'zetler'
        ImageIndex = 3
        object pnlOzetHeader: TPanel
          AlignWithMargins = True
          Left = 3
          Top = 4
          Width = 628
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
          Width = 628
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
            Width = 29
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblserbest_stok_toplam: TLabel
            Left = 26
            Top = 116
            Width = 118
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Serbest Stok Toplam'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblblokaj_toplam_brm: TLabel
            Left = 257
            Top = 94
            Width = 29
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblblokaj_toplam: TLabel
            Left = 64
            Top = 94
            Width = 80
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Blokaj Toplam'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_miktar_brm: TLabel
            Left = 257
            Top = 6
            Width = 29
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblgiren_toplam_brm: TLabel
            Left = 257
            Top = 28
            Width = 29
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblcikan_toplam_brm: TLabel
            Left = 257
            Top = 50
            Width = 29
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblstok_miktari_brm: TLabel
            Left = 257
            Top = 72
            Width = 29
            Height = 13
            Hint = 'Hide'
            Caption = 'Birim'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
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
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblcikan_toplam: TLabel
            Left = 71
            Top = 50
            Width = 73
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = #199#305'kanToplam'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblgiren_toplam: TLabel
            Left = 69
            Top = 28
            Width = 75
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Giren Toplam'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_miktar: TLabel
            Left = 38
            Top = 6
            Width = 106
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'D'#246'nem Ba'#351#305' Miktar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
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
          Width = 628
          Height = 139
          Margins.Top = 4
          Margins.Bottom = 4
          Align = alClient
          Color = 15527135
          ParentBackground = False
          TabOrder = 2
          object lblstok_degeri_ort_brm: TLabel
            Left = 257
            Top = 50
            Width = 58
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblstok_degeri_son_brm: TLabel
            Left = 257
            Top = 72
            Width = 58
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_deger_brm: TLabel
            Left = 257
            Top = 28
            Width = 58
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblstok_degeri_son: TLabel
            Left = 16
            Top = 72
            Width = 128
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Stok De'#287'eri(Son Fiyat)'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
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
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_deger: TLabel
            Left = 41
            Top = 28
            Width = 103
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'D'#246'nem Ba'#351#305' De'#287'er'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_fiyat_brm: TLabel
            Left = 257
            Top = 6
            Width = 58
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltoplam_alis_brm: TLabel
            Left = 257
            Top = 94
            Width = 58
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltoplam_satis_brm: TLabel
            Left = 257
            Top = 116
            Width = 58
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltoplam_satis: TLabel
            Left = 71
            Top = 116
            Width = 73
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Toplam Sat'#305#351
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltoplam_alis: TLabel
            Left = 79
            Top = 94
            Width = 65
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'Toplam Al'#305#351
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbldonem_basi_fiyat: TLabel
            Left = 47
            Top = 6
            Width = 97
            Height = 13
            Hint = 'Hide'
            Alignment = taRightJustify
            Caption = 'D'#246'nem Ba'#351#305' Fiyat'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
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
          Top = 356
          Width = 628
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
            Width = 58
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_alis_brm: TLabel
            Left = 256
            Top = 29
            Width = 58
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_ortalama_maliyet_brm: TLabel
            Left = 256
            Top = 51
            Width = 58
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_satis_brm: TLabel
            Left = 256
            Top = 7
            Width = 58
            Height = 13
            Hint = 'Hide'
            Caption = 'ParaBirimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_son_alis: TLabel
            Left = 66
            Top = 73
            Width = 78
            Height = 13
            Alignment = taRightJustify
            Caption = 'Son Al'#305#351' Fiyat'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_ortalama_maliyet: TLabel
            Left = 46
            Top = 51
            Width = 98
            Height = 13
            Alignment = taRightJustify
            Caption = 'Ortalama Maliyet'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_alis: TLabel
            Left = 124
            Top = 29
            Width = 20
            Height = 13
            Alignment = taRightJustify
            Caption = 'Al'#305#351
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblozet_satis: TLabel
            Left = 116
            Top = 7
            Width = 28
            Height = 13
            Alignment = taRightJustify
            Caption = 'Sat'#305#351
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
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
    end
  end
  inherited pnlBottom: TPanel
    Top = 484
    Width = 638
    ExplicitTop = 481
    ExplicitWidth = 636
    inherited btnAccept: TButton
      Left = 432
      TabOrder = 2
      ExplicitLeft = 430
    end
    inherited btnClose: TButton
      Left = 536
      ExplicitLeft = 534
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 514
    Width = 642
    ExplicitTop = 511
    ExplicitWidth = 640
  end
end

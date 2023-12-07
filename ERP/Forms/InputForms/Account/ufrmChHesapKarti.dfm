inherited frmHesapKarti: TfrmHesapKarti
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Hesap Kart'#305
  ClientHeight = 374
  ClientWidth = 687
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 703
  ExplicitHeight = 413
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 687
    Height = 324
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 687
    ExplicitHeight = 324
    inherited pgcMain: TPageControl
      Width = 687
      Height = 324
      OnChange = pgcMainChange
      ExplicitWidth = 687
      ExplicitHeight = 324
      inherited tsMain: TTabSheet
        ExplicitWidth = 679
        ExplicitHeight = 296
        object lblhesap_kodu: TLabel
          Left = 76
          Top = 25
          Width = 70
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Hesap Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblhesap_ismi: TLabel
          Left = 83
          Top = 47
          Width = 63
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Hesap '#304'smi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblhesap_grubu_id: TLabel
          Left = 71
          Top = 69
          Width = 75
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Hesap Grubu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmukellef_tipi: TLabel
          Left = 72
          Top = 121
          Width = 74
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'M'#252'kellef Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmukellef_adi: TLabel
          Left = 417
          Top = 143
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'M'#252'kellef Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmukellef_ikinci_adi: TLabel
          Left = 382
          Top = 165
          Width = 106
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'M'#252'kellef '#304'kinci Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmukellef_soyadi: TLabel
          Left = 397
          Top = 187
          Width = 91
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'M'#252'kellef Soyad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblvergi_dairesi: TLabel
          Left = 73
          Top = 143
          Width = 73
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Vergi Dairesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblvergi_no: TLabel
          Left = 96
          Top = 165
          Width = 50
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Vergi No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblnace_kodu: TLabel
          Left = 424
          Top = 231
          Width = 64
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Nace Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblbolge_id: TLabel
          Left = 455
          Top = 69
          Width = 33
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'B'#246'lge'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbliban: TLabel
          Left = 60
          Top = 209
          Width = 86
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'IBAN Numaras'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_efatura_hesabi: TLabel
          Left = 47
          Top = 231
          Width = 99
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'E-Fatura Hesab'#305'?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmuhasebe_kodu: TLabel
          Left = 54
          Top = 3
          Width = 92
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Muhasebe Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblefatura_pk_name: TLabel
          Left = 360
          Top = 253
          Width = 128
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'E-Fatura Posta Kutusu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblspl1: TLabel
          Left = 194
          Top = -3
          Width = 8
          Height = 24
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = '-'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblspl2: TLabel
          Left = 255
          Top = -3
          Width = 8
          Height = 24
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = '-'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -19
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_pasif: TLabel
          Left = 459
          Top = 25
          Width = 29
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Pasif'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblhesap_iskonto: TLabel
          Left = 63
          Top = 253
          Width = 83
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Hesap '#304'skonto'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtkok_hesap_kodu: TEdit
          Left = 150
          Top = 0
          Width = 43
          Height = 21
          TabOrder = 0
          OnExit = edtkok_hesap_koduExit
        end
        object cbbara_hesap_kodu: TComboBox
          Left = 204
          Top = 0
          Width = 50
          Height = 21
          Style = csDropDownList
          TabOrder = 1
          OnExit = cbbara_hesap_koduExit
        end
        object cbbson_hesap_kodu: TComboBox
          Left = 265
          Top = 0
          Width = 65
          Height = 21
          Style = csDropDownList
          TabOrder = 2
          OnExit = cbbson_hesap_koduExit
        end
        object edthesap_kodu: TEdit
          Left = 150
          Top = 22
          Width = 80
          Height = 21
          TabOrder = 3
        end
        object edthesap_ismi: TEdit
          Left = 150
          Top = 44
          Width = 522
          Height = 21
          TabOrder = 5
        end
        object edtvergi_dairesi: TEdit
          Left = 150
          Top = 140
          Width = 180
          Height = 21
          TabOrder = 9
        end
        object edtvergi_no: TEdit
          Left = 150
          Top = 162
          Width = 180
          Height = 21
          TabOrder = 11
        end
        object edtmukellef_adi: TEdit
          Left = 492
          Top = 140
          Width = 180
          Height = 21
          TabOrder = 10
        end
        object edtmukellef_ikinci_adi: TEdit
          Left = 492
          Top = 162
          Width = 180
          Height = 21
          TabOrder = 12
        end
        object edtmukellef_soyadi: TEdit
          Left = 492
          Top = 184
          Width = 180
          Height = 21
          TabOrder = 13
        end
        object edtiban: TEdit
          Left = 150
          Top = 206
          Width = 336
          Height = 21
          TabOrder = 14
        end
        object chkis_efatura_hesabi: TCheckBox
          Left = 150
          Top = 228
          Width = 180
          Height = 21
          TabOrder = 16
        end
        object edtnace_kodu: TEdit
          Left = 492
          Top = 228
          Width = 180
          Height = 21
          TabOrder = 17
        end
        object edtefatura_pk_name: TEdit
          Left = 492
          Top = 250
          Width = 180
          Height = 21
          TabOrder = 19
        end
        object chkis_pasif: TCheckBox
          Left = 492
          Top = 22
          Width = 180
          Height = 21
          TabOrder = 4
        end
        object edthesap_iskonto: TEdit
          Left = 150
          Top = 250
          Width = 180
          Height = 21
          TabOrder = 18
        end
        object edthesap_grubu_id: TEdit
          Left = 150
          Top = 66
          Width = 180
          Height = 21
          TabOrder = 6
        end
        object edtbolge_id: TEdit
          Left = 492
          Top = 66
          Width = 180
          Height = 21
          TabOrder = 7
        end
        object edtiban_para: TEdit
          Left = 492
          Top = 206
          Width = 180
          Height = 21
          TabOrder = 15
        end
        object cbbmukellef_tipi: TComboBox
          Left = 150
          Top = 118
          Width = 180
          Height = 21
          Style = csDropDownList
          TabOrder = 8
          OnExit = cbbson_hesap_koduExit
        end
      end
      object tsAdres: TTabSheet
        Caption = 'Adres'
        ImageIndex = 1
        object lblbina_adi: TLabel
          Left = 120
          Top = 230
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
        object lblsokak: TLabel
          Left = 109
          Top = 207
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
        object lblcadde: TLabel
          Left = 109
          Top = 184
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
        object lblmahalle: TLabel
          Left = 101
          Top = 138
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
        object lblilce: TLabel
          Left = 124
          Top = 115
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
        object lblsehir_id: TLabel
          Left = 116
          Top = 92
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
        object lblulke_id: TLabel
          Left = 119
          Top = 69
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
        object lblposta_kodu: TLabel
          Left = 422
          Top = 253
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
        object lblkapi_no: TLabel
          Left = 100
          Top = 253
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
        object lblsemt: TLabel
          Left = 117
          Top = 161
          Width = 29
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Semt'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblweb_site: TLabel
          Left = 426
          Top = 69
          Width = 62
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Web Sitesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemail: TLabel
          Left = 404
          Top = 92
          Width = 84
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'E-Posta Adresi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtilce: TEdit
          Left = 150
          Top = 112
          Width = 180
          Height = 21
          TabOrder = 4
        end
        object edtmahalle: TEdit
          Left = 150
          Top = 135
          Width = 180
          Height = 21
          TabOrder = 5
        end
        object edtcadde: TEdit
          Left = 150
          Top = 181
          Width = 180
          Height = 21
          TabOrder = 7
        end
        object edtsokak: TEdit
          Left = 150
          Top = 204
          Width = 180
          Height = 21
          TabOrder = 8
        end
        object edtbina_adi: TEdit
          Left = 150
          Top = 227
          Width = 180
          Height = 21
          TabOrder = 9
        end
        object edtkapi_no: TEdit
          Left = 150
          Top = 250
          Width = 180
          Height = 21
          TabOrder = 10
        end
        object edtposta_kodu: TEdit
          Left = 492
          Top = 250
          Width = 180
          Height = 21
          TabOrder = 11
        end
        object edtulke_id: TEdit
          Left = 150
          Top = 66
          Width = 180
          Height = 21
          TabOrder = 0
        end
        object edtsehir_id: TEdit
          Left = 150
          Top = 89
          Width = 180
          Height = 21
          TabOrder = 2
        end
        object edtsemt: TEdit
          Left = 150
          Top = 158
          Width = 180
          Height = 21
          TabOrder = 6
        end
        object edtweb_site: TEdit
          Left = 492
          Top = 66
          Width = 180
          Height = 21
          TabOrder = 1
        end
        object edtemail: TEdit
          Left = 492
          Top = 89
          Width = 180
          Height = 21
          TabOrder = 3
        end
      end
      object tsIletisim: TTabSheet
        Caption = #304'leti'#351'im'
        ImageIndex = 2
        object lblyetkili2: TLabel
          Left = 75
          Top = 91
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yetkili Kisi 2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblyetkili1: TLabel
          Left = 75
          Top = 69
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yetkili Ki'#351'i 1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfaks: TLabel
          Left = 118
          Top = 135
          Width = 28
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Faks'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmuhasebe_telefon: TLabel
          Left = 382
          Top = 157
          Width = 106
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Muhasebe Telefon'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmuhasebe_eposta: TLabel
          Left = 381
          Top = 179
          Width = 107
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Muhasebe E-Posta'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblyetkili2_tel: TLabel
          Left = 394
          Top = 91
          Width = 94
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yetkili 2 Telefon'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblyetkili1_tel: TLabel
          Left = 394
          Top = 69
          Width = 94
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yetkili 1 Telefon'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblozel_bilgi: TLabel
          Left = 92
          Top = 245
          Width = 54
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'zel Bilgi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmuhasebe_yetkili: TLabel
          Left = 390
          Top = 201
          Width = 98
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Muhasebe Yetkili'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblyetkili3: TLabel
          Left = 75
          Top = 113
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yetkili Kisi 3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblyetkili3_tel: TLabel
          Left = 394
          Top = 113
          Width = 94
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yetkili 2 Telefon'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtyetkili1: TEdit
          Left = 150
          Top = 66
          Width = 180
          Height = 21
          TabOrder = 0
        end
        object edtyetkili1_tel: TEdit
          Left = 492
          Top = 66
          Width = 180
          Height = 21
          TabOrder = 1
        end
        object edtyetkili2: TEdit
          Left = 150
          Top = 88
          Width = 180
          Height = 21
          TabOrder = 2
        end
        object edtyetkili2_tel: TEdit
          Left = 492
          Top = 88
          Width = 180
          Height = 21
          TabOrder = 3
        end
        object edtyetkili3: TEdit
          Left = 150
          Top = 110
          Width = 180
          Height = 21
          TabOrder = 4
        end
        object edtyetkili3_tel: TEdit
          Left = 492
          Top = 110
          Width = 180
          Height = 21
          TabOrder = 5
        end
        object edtfaks: TEdit
          Left = 150
          Top = 132
          Width = 180
          Height = 21
          TabOrder = 6
        end
        object edtmuhasebe_telefon: TEdit
          Left = 492
          Top = 154
          Width = 180
          Height = 21
          TabOrder = 7
        end
        object edtmuhasebe_eposta: TEdit
          Left = 492
          Top = 176
          Width = 180
          Height = 21
          TabOrder = 8
        end
        object edtmuhasebe_yetkili: TEdit
          Left = 492
          Top = 198
          Width = 180
          Height = 21
          TabOrder = 9
        end
        object mmoozel_bilgi: TMemo
          Left = 150
          Top = 242
          Width = 522
          Height = 21
          TabOrder = 10
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 326
    Width = 683
    ExplicitTop = 326
    ExplicitWidth = 683
    inherited btnAccept: TButton
      Left = 477
      ExplicitLeft = 477
    end
    inherited btnClose: TButton
      Left = 581
      ExplicitLeft = 581
    end
  end
  inherited stbBase: TStatusBar
    Top = 356
    Width = 687
    ExplicitTop = 356
    ExplicitWidth = 687
  end
end

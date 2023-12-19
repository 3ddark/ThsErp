inherited frmSysUygulamaAyari: TfrmSysUygulamaAyari
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem Uygulama Ayarlar'#305
  ClientHeight = 384
  ClientWidth = 694
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 710
  ExplicitHeight = 423
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 694
    Height = 334
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 694
    ExplicitHeight = 334
    inherited pgcMain: TPageControl
      Width = 694
      Height = 334
      ExplicitWidth = 694
      ExplicitHeight = 334
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 686
        ExplicitHeight = 304
        object lblunvan: TLabel
          Left = 99
          Top = 6
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'nvan'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltelefon: TLabel
          Left = 93
          Top = 29
          Width = 42
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Telefon'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfaks: TLabel
          Left = 109
          Top = 52
          Width = 26
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Faks'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtunvan: TEdit
          Left = 137
          Top = 2
          Width = 543
          Height = 23
          TabOrder = 0
        end
        object edttelefon: TEdit
          Left = 137
          Top = 25
          Width = 136
          Height = 23
          TabOrder = 1
        end
        object edtfaks: TEdit
          Left = 137
          Top = 48
          Width = 136
          Height = 23
          TabOrder = 3
        end
        object pnllogo: TPanel
          Left = 360
          Top = 25
          Width = 322
          Height = 242
          Caption = 'Logo 320x240'
          TabOrder = 2
          object imglogo: TImage
            Left = 1
            Top = 1
            Width = 320
            Height = 240
            Align = alClient
            OnDblClick = imglogoDblClick
            ExplicitLeft = 0
            ExplicitTop = 0
          end
        end
      end
      object tsadres: TTabSheet
        Caption = 'Adres'
        ImageIndex = 2
        object lblvergi_dairesi: TLabel
          Left = 400
          Top = 36
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Vergi Dairesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblvergi_numarasi: TLabel
          Left = 386
          Top = 13
          Width = 85
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Vergi Numaras'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblweb: TLabel
          Left = 412
          Top = 255
          Width = 59
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Web Sitesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemail: TLabel
          Left = 89
          Top = 255
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'e-Posta'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblulke_adi: TLabel
          Left = 108
          Top = 145
          Width = 25
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'lke'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsehir_id: TLabel
          Left = 442
          Top = 145
          Width = 29
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #350'ehir'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblilce: TLabel
          Left = 112
          Top = 167
          Width = 21
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304'l'#231'e'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmahalle: TLabel
          Left = 89
          Top = 189
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mahalle'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsokak: TLabel
          Left = 98
          Top = 211
          Width = 35
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sokak'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblbina_adi: TLabel
          Left = 426
          Top = 211
          Width = 45
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Bina Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkapi_no: TLabel
          Left = 92
          Top = 233
          Width = 41
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kap'#305' No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblposta_kodu: TLabel
          Left = 408
          Top = 233
          Width = 63
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Posta Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsemt: TLabel
          Left = 441
          Top = 167
          Width = 30
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Semt'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcadde: TLabel
          Left = 436
          Top = 189
          Width = 35
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Cadde'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmukellef_tipi: TLabel
          Left = 62
          Top = 13
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'M'#252'kellef Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmukellef_adi: TLabel
          Left = 64
          Top = 36
          Width = 69
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'M'#252'kellef Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmukellef_soyadi: TLabel
          Left = 44
          Top = 57
          Width = 89
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'M'#252'kellef Soyad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtvergi_dairesi: TEdit
          Left = 473
          Top = 32
          Width = 200
          Height = 23
          TabOrder = 3
        end
        object edtvergi_numarasi: TEdit
          Left = 473
          Top = 9
          Width = 120
          Height = 23
          TabOrder = 1
        end
        object edtweb: TEdit
          Left = 473
          Top = 251
          Width = 200
          Height = 23
          TabOrder = 16
        end
        object edtemail: TEdit
          Left = 135
          Top = 251
          Width = 200
          Height = 23
          TabOrder = 15
        end
        object edtsehir_id: TEdit
          Left = 473
          Top = 141
          Width = 200
          Height = 23
          TabOrder = 6
        end
        object edtilce: TEdit
          Left = 135
          Top = 163
          Width = 200
          Height = 23
          TabOrder = 7
        end
        object edtmahalle: TEdit
          Left = 135
          Top = 185
          Width = 200
          Height = 23
          TabOrder = 9
        end
        object edtsokak: TEdit
          Left = 135
          Top = 207
          Width = 200
          Height = 23
          TabOrder = 11
        end
        object edtbina_adi: TEdit
          Left = 473
          Top = 207
          Width = 200
          Height = 23
          TabOrder = 12
        end
        object edtkapi_no: TEdit
          Left = 135
          Top = 229
          Width = 200
          Height = 23
          TabOrder = 13
        end
        object edtposta_kodu: TEdit
          Left = 473
          Top = 229
          Width = 200
          Height = 23
          TabOrder = 14
        end
        object edtulke_adi: TEdit
          Left = 135
          Top = 141
          Width = 200
          Height = 23
          TabOrder = 5
        end
        object edtsemt: TEdit
          Left = 473
          Top = 163
          Width = 200
          Height = 23
          TabOrder = 8
        end
        object edtcadde: TEdit
          Left = 473
          Top = 185
          Width = 200
          Height = 23
          TabOrder = 10
        end
        object cbbmukellef_tipi: TComboBox
          Left = 137
          Top = 9
          Width = 178
          Height = 23
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbbmukellef_tipiChange
        end
        object edtmukellef_adi: TEdit
          Left = 135
          Top = 32
          Width = 180
          Height = 23
          TabOrder = 2
        end
        object edtmukellef_soyadi: TEdit
          Left = 135
          Top = 53
          Width = 180
          Height = 23
          TabOrder = 4
        end
      end
      object tsgorsel: TTabSheet
        Caption = 'G'#246'rsel'
        ImageIndex = 2
        object lblversiyon: TLabel
          Left = 33
          Top = 168
          Width = 102
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Uygulama Version'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldonem: TLabel
          Left = 95
          Top = 122
          Width = 40
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'D'#246'nem'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcrypt_key: TLabel
          Left = 29
          Top = 98
          Width = 106
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #350'ifreleme Anahtar'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgrid_renk_aktif: TLabel
          Left = 50
          Top = 75
          Width = 85
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grid Renk Aktif'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgrid_renk_2: TLabel
          Left = 70
          Top = 52
          Width = 65
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grid Renk 2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgrid_renk_1: TLabel
          Left = 70
          Top = 29
          Width = 65
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grid Renk 1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtcrypt_key: TEdit
          Left = 137
          Top = 94
          Width = 160
          Height = 23
          TabOrder = 3
        end
        object edtversiyon: TEdit
          Left = 137
          Top = 164
          Width = 160
          Height = 23
          TabOrder = 5
        end
        object edtdonem: TEdit
          Left = 137
          Top = 118
          Width = 160
          Height = 23
          TabOrder = 4
        end
        object edtgrid_renk_aktif: TEdit
          Left = 137
          Top = 71
          Width = 160
          Height = 23
          TabOrder = 2
          OnDblClick = edtgrid_renk_aktifDblClick
          OnExit = edtgrid_renk_aktifExit
        end
        object edtgrid_renk_2: TEdit
          Left = 137
          Top = 48
          Width = 160
          Height = 23
          TabOrder = 1
          OnDblClick = edtgrid_renk_2DblClick
          OnExit = edtgrid_renk_2Exit
        end
        object edtgrid_renk_1: TEdit
          Left = 137
          Top = 25
          Width = 160
          Height = 23
          TabOrder = 0
          OnDblClick = edtgrid_renk_1DblClick
          OnExit = edtgrid_renk_1Exit
        end
      end
      object tsservis_ayarlari: TTabSheet
        Caption = 'Servis Ayarlar'#305
        ImageIndex = 1
        object lblmail_sunucu: TLabel
          Left = 387
          Top = 7
          Width = 88
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Sunucu Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmail_kullanici: TLabel
          Left = 338
          Top = 30
          Width = 137
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Sunucu Kullan'#305'c'#305' Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmail_sifre: TLabel
          Left = 321
          Top = 53
          Width = 154
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Sunucu Kullan'#305'c'#305' '#350'ifresi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmail_smtp_port: TLabel
          Left = 325
          Top = 76
          Width = 150
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Sunucu Port Numaras'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsms_sunucu: TLabel
          Left = 360
          Top = 162
          Width = 115
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'SMS Servis Sa'#287'lay'#305'c'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsms_kullanici: TLabel
          Left = 381
          Top = 185
          Width = 94
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'SMS Kullan'#305'c'#305' Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsms_sifre: TLabel
          Left = 364
          Top = 208
          Width = 111
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'SMS Kullan'#305'c'#305' '#350'ifresi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsms_baslik: TLabel
          Left = 415
          Top = 231
          Width = 60
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'SMS Ba'#351'l'#305'k'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtmail_sunucu: TEdit
          Left = 477
          Top = 3
          Width = 200
          Height = 23
          TabOrder = 0
        end
        object edtmail_kullanici: TEdit
          Left = 477
          Top = 26
          Width = 200
          Height = 23
          TabOrder = 1
        end
        object edtmail_sifre: TEdit
          Left = 477
          Top = 49
          Width = 200
          Height = 23
          PasswordChar = '#'
          TabOrder = 2
        end
        object edtmail_smtp_port: TEdit
          Left = 477
          Top = 72
          Width = 200
          Height = 23
          TabOrder = 3
        end
        object edtsms_sunucu: TEdit
          Left = 477
          Top = 158
          Width = 200
          Height = 23
          TabOrder = 4
        end
        object edtsms_kullanici: TEdit
          Left = 477
          Top = 181
          Width = 200
          Height = 23
          TabOrder = 5
        end
        object edtsms_sifre: TEdit
          Left = 477
          Top = 204
          Width = 200
          Height = 23
          PasswordChar = '#'
          TabOrder = 6
        end
        object edtsms_baslik: TEdit
          Left = 477
          Top = 227
          Width = 200
          Height = 23
          TabOrder = 7
        end
      end
      object tsdiger: TTabSheet
        Caption = 'Di'#287'er Ayarlar'
        ImageIndex = 3
        object lblpath_stok_karti_resim: TLabel
          Left = 33
          Top = 5
          Width = 121
          Height = 13
          Alignment = taRightJustify
          Caption = 'Stok Kart'#305' Resim Yolu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblpath_guncelleme: TLabel
          Left = 23
          Top = 53
          Width = 131
          Height = 13
          Alignment = taRightJustify
          Caption = 'G'#252'ncelleme Dosya Yolu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblpath_personel_karti_resim: TLabel
          Left = 10
          Top = 29
          Width = 144
          Height = 13
          Alignment = taRightJustify
          Caption = 'Personel Kart'#305' Resim Yolu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtpath_stok_karti_resim: TEdit
          Left = 160
          Top = 2
          Width = 462
          Height = 23
          TabOrder = 0
        end
        object btnpath_stok_karti_resim: TButton
          Left = 624
          Top = 2
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 1
          OnClick = btnpath_stok_karti_resimClick
        end
        object edtpath_guncelleme: TEdit
          Left = 160
          Top = 50
          Width = 462
          Height = 23
          TabOrder = 4
        end
        object btnpath_guncelleme: TButton
          Left = 624
          Top = 50
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 5
          OnClick = btnpath_guncellemeClick
        end
        object edtpath_personel_karti_resim: TEdit
          Left = 160
          Top = 26
          Width = 462
          Height = 23
          TabOrder = 2
        end
        object btnpath_personel_karti_resim: TButton
          Left = 624
          Top = 26
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 3
          OnClick = btnpath_personel_karti_resimClick
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 336
    Width = 690
    ExplicitTop = 336
    ExplicitWidth = 690
    inherited btnAccept: TButton
      Left = 484
      ExplicitLeft = 484
    end
    inherited btnClose: TButton
      Left = 588
      ExplicitLeft = 588
    end
  end
  inherited stbBase: TStatusBar
    Top = 366
    Width = 694
    ExplicitTop = 366
    ExplicitWidth = 694
  end
  inherited AppEvntsBase: TApplicationEvents
    Left = 280
    Top = 24
  end
  inherited pmLabels: TPopupMenu
    Left = 352
    Top = 104
  end
end

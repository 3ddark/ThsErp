inherited frmSysUygulamaAyari: TfrmSysUygulamaAyari
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem Uygulama Ayarlar'#305
  ClientHeight = 387
  ClientWidth = 696
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 702
  ExplicitHeight = 416
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 696
    Height = 337
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 696
    ExplicitHeight = 337
    inherited pgcMain: TPageControl
      Width = 696
      Height = 337
      ActivePage = tsgorsel
      ExplicitWidth = 696
      ExplicitHeight = 337
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 688
        ExplicitHeight = 309
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
        object imglogo: TImage
          Left = 376
          Top = 25
          Width = 320
          Height = 240
          Anchors = [akTop, akRight]
          OnDblClick = imglogoDblClick
          ExplicitLeft = 360
        end
        object edtunvan: TEdit
          Left = 137
          Top = 2
          Width = 543
          Height = 21
          TabOrder = 0
        end
        object edttelefon: TEdit
          Left = 137
          Top = 25
          Width = 136
          Height = 21
          TabOrder = 1
        end
        object edtfaks: TEdit
          Left = 137
          Top = 48
          Width = 136
          Height = 21
          TabOrder = 2
        end
      end
      object tsadres: TTabSheet
        Caption = 'Adres'
        ImageIndex = 2
        object lblvergi_dairesi: TLabel
          Left = 64
          Top = 28
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
          Left = 50
          Top = 51
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
          Left = 76
          Top = 90
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
          Left = 431
          Top = 90
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
          Left = 110
          Top = 128
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
          Left = 446
          Top = 128
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
          Left = 114
          Top = 151
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
          Left = 431
          Top = 151
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
          Left = 440
          Top = 197
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
          Left = 90
          Top = 220
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
          Left = 434
          Top = 220
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
          Left = 412
          Top = 243
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
          Left = 105
          Top = 174
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
          Left = 100
          Top = 197
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
        object edtvergi_dairesi: TEdit
          Left = 137
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtvergi_numarasi: TEdit
          Left = 137
          Top = 48
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtweb: TEdit
          Left = 137
          Top = 87
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object edtemail: TEdit
          Left = 477
          Top = 87
          Width = 200
          Height = 21
          TabOrder = 3
        end
        object edtsehir_id: TEdit
          Left = 477
          Top = 125
          Width = 200
          Height = 21
          TabOrder = 5
        end
        object edtilce: TEdit
          Left = 137
          Top = 148
          Width = 200
          Height = 21
          TabOrder = 6
        end
        object edtmahalle: TEdit
          Left = 477
          Top = 148
          Width = 200
          Height = 21
          TabOrder = 7
        end
        object edtsokak: TEdit
          Left = 477
          Top = 194
          Width = 200
          Height = 21
          TabOrder = 10
        end
        object edtbina_adi: TEdit
          Left = 137
          Top = 217
          Width = 200
          Height = 21
          TabOrder = 11
        end
        object edtkapi_no: TEdit
          Left = 477
          Top = 217
          Width = 200
          Height = 21
          TabOrder = 12
        end
        object edtposta_kodu: TEdit
          Left = 477
          Top = 240
          Width = 200
          Height = 21
          TabOrder = 13
        end
        object edtulke_adi: TEdit
          Left = 137
          Top = 125
          Width = 200
          Height = 21
          TabOrder = 4
        end
        object edtsemt: TEdit
          Left = 137
          Top = 171
          Width = 200
          Height = 21
          TabOrder = 8
        end
        object edtcadde: TEdit
          Left = 137
          Top = 194
          Width = 200
          Height = 21
          TabOrder = 9
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
        object lbllisan: TLabel
          Left = 43
          Top = 145
          Width = 92
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Uygulama Lisan'#305
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
        object edtlisan: TEdit
          Left = 137
          Top = 141
          Width = 160
          Height = 21
          TabOrder = 5
        end
        object edtcrypt_key: TEdit
          Left = 137
          Top = 94
          Width = 160
          Height = 21
          TabOrder = 3
        end
        object edtversiyon: TEdit
          Left = 137
          Top = 164
          Width = 160
          Height = 21
          TabOrder = 6
        end
        object edtdonem: TEdit
          Left = 137
          Top = 118
          Width = 160
          Height = 21
          TabOrder = 4
        end
        object edtgrid_renk_aktif: TEdit
          Left = 137
          Top = 71
          Width = 160
          Height = 21
          TabOrder = 2
          OnDblClick = edtgrid_renk_aktifDblClick
          OnExit = edtgrid_renk_aktifExit
        end
        object edtgrid_renk_2: TEdit
          Left = 137
          Top = 48
          Width = 160
          Height = 21
          TabOrder = 1
          OnDblClick = edtgrid_renk_2DblClick
          OnExit = edtgrid_renk_2Exit
        end
        object edtgrid_renk_1: TEdit
          Left = 137
          Top = 25
          Width = 160
          Height = 21
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
          Height = 21
          TabOrder = 0
        end
        object edtmail_kullanici: TEdit
          Left = 477
          Top = 26
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtmail_sifre: TEdit
          Left = 477
          Top = 49
          Width = 200
          Height = 21
          PasswordChar = '#'
          TabOrder = 2
        end
        object edtmail_smtp_port: TEdit
          Left = 477
          Top = 72
          Width = 200
          Height = 21
          TabOrder = 3
        end
        object edtsms_sunucu: TEdit
          Left = 477
          Top = 158
          Width = 200
          Height = 21
          TabOrder = 4
        end
        object edtsms_kullanici: TEdit
          Left = 477
          Top = 181
          Width = 200
          Height = 21
          TabOrder = 5
        end
        object edtsms_sifre: TEdit
          Left = 477
          Top = 204
          Width = 200
          Height = 21
          PasswordChar = '#'
          TabOrder = 6
        end
        object edtsms_baslik: TEdit
          Left = 477
          Top = 227
          Width = 200
          Height = 21
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
          Top = 29
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
        object edtpath_stok_karti_resim: TEdit
          Left = 160
          Top = 2
          Width = 462
          Height = 21
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
          Top = 26
          Width = 462
          Height = 21
          TabOrder = 2
        end
        object btnpath_guncelleme: TButton
          Left = 624
          Top = 26
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 3
          OnClick = btnpath_guncellemeClick
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 339
    Width = 692
    ExplicitTop = 339
    ExplicitWidth = 692
    inherited btnAccept: TButton
      Left = 486
      ExplicitLeft = 486
    end
    inherited btnClose: TButton
      Left = 590
      ExplicitLeft = 590
    end
  end
  inherited stbBase: TStatusBar
    Top = 369
    Width = 696
    ExplicitTop = 369
    ExplicitWidth = 696
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

object frmSysApplicationSetting: TfrmSysApplicationSetting
  Left = 0
  Top = 0
  Caption = 'Sistem Uygulama Ayarlar'#305
  ClientHeight = 480
  ClientWidth = 720
  Color = clBtnFace
  ParentFont = True
  Position = poDesktopCenter
  TextHeight = 15
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 720
    Height = 430
    Color = clWindow
    TabOrder = 0
    object pgcMain: TPageControl
      Left = 0
      Top = 0
      Width = 720
      Height = 430
      ActivePage = tsGenel
      TabOrder = 0
      object tsGenel: TTabSheet
        Caption = 'Genel Ayarlar'
        ImageIndex = 0
        DesignSize = (
          712
          398)
        object lblCompanyTitle: TLabel
          Left = 58
          Top = 6
          Width = 78
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'rtn Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblPhone: TLabel
          Left = 82
          Top = 30
          Width = 54
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
        object lblFax: TLabel
          Left = 98
          Top = 54
          Width = 38
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
        object edtCompanyTitle: TEdit
          Left = 137
          Top = 2
          Width = 450
          Height = 23
          TabOrder = 0
        end
        object edtPhone: TEdit
          Left = 137
          Top = 26
          Width = 136
          Height = 23
          TabOrder = 1
        end
        object edtFax: TEdit
          Left = 137
          Top = 50
          Width = 136
          Height = 23
          TabOrder = 3
        end
        object pnlLogo: TPanel
          Left = 8
          Top = 78
          Width = 696
          Height = 40
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Logo'
          TabOrder = 2
        end
      end
      object tsAdres: TTabSheet
        Caption = 'Adres Bilgileri'
        ImageIndex = 2
        object lblMukellefTipi: TLabel
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
        object lblTaxpayerName: TLabel
          Left = 40
          Top = 36
          Width = 93
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
        object lblTaxpayerSurname: TLabel
          Left = 20
          Top = 57
          Width = 113
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
        object lblTaxNo: TLabel
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
        object lblTaxAuthority: TLabel
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
        object lblUlkeAdi: TLabel
          Left = 60
          Top = 80
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'lke Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblSehirId: TLabel
          Left = 408
          Top = 80
          Width = 37
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
        object lblIlce: TLabel
          Left = 60
          Top = 103
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304'l'#231'e
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblMahalle: TLabel
          Left = 60
          Top = 126
          Width = 71
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
        object lblSemt: TLabel
          Left = 408
          Top = 103
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
        object lblCadde: TLabel
          Left = 408
          Top = 126
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
        object lblSokak: TLabel
          Left = 60
          Top = 149
          Width = 71
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
        object lblBinaAdi: TLabel
          Left = 408
          Top = 149
          Width = 71
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
        object lblKapiNo: TLabel
          Left = 60
          Top = 172
          Width = 71
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
        object lblPostaKodu: TLabel
          Left = 408
          Top = 172
          Width = 71
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
        object lblEmail: TLabel
          Left = 60
          Top = 240
          Width = 71
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
        object lblWeb: TLabel
          Left = 408
          Top = 240
          Width = 71
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
        object cbbMukellefTipi: TComboBox
          Left = 137
          Top = 9
          Width = 200
          Height = 23
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbbMukellefTipiChange
        end
        object edtTaxpayerName: TEdit
          Left = 137
          Top = 32
          Width = 200
          Height = 23
          TabOrder = 1
        end
        object edtTaxpayerSurname: TEdit
          Left = 137
          Top = 53
          Width = 200
          Height = 23
          TabOrder = 2
        end
        object edtTaxNo: TEdit
          Left = 479
          Top = 9
          Width = 200
          Height = 23
          TabOrder = 3
        end
        object edtTaxAuthority: TEdit
          Left = 479
          Top = 32
          Width = 200
          Height = 23
          TabOrder = 4
        end
        object edtUlkeAdi: TEdit
          Left = 137
          Top = 76
          Width = 200
          Height = 23
          ReadOnly = True
          TabOrder = 5
        end
        object edtSehirId: TEdit
          Left = 479
          Top = 76
          Width = 200
          Height = 23
          TabOrder = 6
        end
        object edtIlce: TEdit
          Left = 137
          Top = 99
          Width = 200
          Height = 23
          TabOrder = 7
        end
        object edtMahalle: TEdit
          Left = 137
          Top = 122
          Width = 200
          Height = 23
          TabOrder = 8
        end
        object edtSemt: TEdit
          Left = 479
          Top = 99
          Width = 200
          Height = 23
          TabOrder = 9
        end
        object edtCadde: TEdit
          Left = 479
          Top = 122
          Width = 200
          Height = 23
          TabOrder = 10
        end
        object edtSokak: TEdit
          Left = 137
          Top = 145
          Width = 200
          Height = 23
          TabOrder = 11
        end
        object edtBinaAdi: TEdit
          Left = 479
          Top = 145
          Width = 200
          Height = 23
          TabOrder = 12
        end
        object edtKapiNo: TEdit
          Left = 137
          Top = 168
          Width = 200
          Height = 23
          TabOrder = 13
        end
        object edtPostaKodu: TEdit
          Left = 479
          Top = 168
          Width = 200
          Height = 23
          TabOrder = 14
        end
        object edtEmail: TEdit
          Left = 137
          Top = 236
          Width = 200
          Height = 23
          TabOrder = 15
        end
        object edtWeb: TEdit
          Left = 479
          Top = 236
          Width = 200
          Height = 23
          TabOrder = 16
        end
      end
      object tsServisAyarlari: TTabSheet
        Caption = 'Servis Ayarlar'#305
        ImageIndex = 1
        DesignSize = (
          712
          398)
        object lblMailHost: TLabel
          Left = 426
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
        object lblMailUser: TLabel
          Left = 377
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
        object lblMailPassword: TLabel
          Left = 360
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
        object lblMailSmtpPort: TLabel
          Left = 364
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
        object lblSmsHost: TLabel
          Left = 399
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
        object lblSmsUser: TLabel
          Left = 420
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
        object lblSmsPassword: TLabel
          Left = 403
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
        object lblSmsTitle: TLabel
          Left = 454
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
        object edtMailHost: TEdit
          Left = 477
          Top = 3
          Width = 200
          Height = 23
          TabOrder = 0
        end
        object edtMailUser: TEdit
          Left = 477
          Top = 26
          Width = 200
          Height = 23
          TabOrder = 1
        end
        object edtMailPassword: TEdit
          Left = 477
          Top = 49
          Width = 200
          Height = 23
          PasswordChar = '#'
          TabOrder = 2
        end
        object edtMailSmtpPort: TEdit
          Left = 477
          Top = 72
          Width = 200
          Height = 23
          TabOrder = 3
        end
        object edtSmsHost: TEdit
          Left = 477
          Top = 158
          Width = 200
          Height = 23
          TabOrder = 4
        end
        object edtSmsUser: TEdit
          Left = 477
          Top = 181
          Width = 200
          Height = 23
          TabOrder = 5
        end
        object edtSmsPassword: TEdit
          Left = 477
          Top = 204
          Width = 200
          Height = 23
          PasswordChar = '#'
          TabOrder = 6
        end
        object edtSmsTitle: TEdit
          Left = 477
          Top = 227
          Width = 200
          Height = 23
          TabOrder = 7
        end
      end
      object tsDigerAyarlar: TTabSheet
        Caption = 'Di'#287'er Ayarlar'
        ImageIndex = 3
        DesignSize = (
          712
          398)
        object lblPathStockCardImage: TLabel
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
        object lblPathPersonnelCardImage: TLabel
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
        object lblPathUpdate: TLabel
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
        object edtPathStockCardImage: TEdit
          Left = 160
          Top = 2
          Width = 462
          Height = 23
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
        object btnPathStockCardImage: TButton
          Left = 624
          Top = 2
          Width = 21
          Height = 21
          Caption = '...'
          Anchors = [akTop, akRight]
          TabOrder = 1
          OnClick = btnPathStockCardImageClick
        end
        object edtPathPersonnelCardImage: TEdit
          Left = 160
          Top = 26
          Width = 462
          Height = 23
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 2
        end
        object btnPathPersonnelCardImage: TButton
          Left = 624
          Top = 26
          Width = 21
          Height = 21
          Caption = '...'
          Anchors = [akTop, akRight]
          TabOrder = 3
          OnClick = btnPathPersonnelCardImageClick
        end
        object edtPathUpdate: TEdit
          Left = 160
          Top = 50
          Width = 462
          Height = 23
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 4
        end
        object btnPathUpdate: TButton
          Left = 624
          Top = 50
          Width = 21
          Height = 21
          Caption = '...'
          Anchors = [akTop, akRight]
          TabOrder = 5
          OnClick = btnPathUpdateClick
        end
      end
      object tsGorsel: TTabSheet
        Caption = 'G'#246'rsel Ayarlar'
        ImageIndex = 2
        DesignSize = (
          712
          398)
        object lblGridColor1: TLabel
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
        object lblGridColor2: TLabel
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
        object lblGridColorActive: TLabel
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
        object lblCryptKey: TLabel
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
        object lblPeriod: TLabel
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
        object lblAppVersion: TLabel
          Left = 33
          Top = 168
          Width = 102
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Uygulama Versiyon'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtGridColor1: TEdit
          Left = 137
          Top = 25
          Width = 160
          Height = 23
          Anchors = [akLeft, akTop]
          TabOrder = 0
          OnDblClick = edtGridColor1DblClick
          OnExit = edtGridColor1Exit
        end
        object edtGridColor2: TEdit
          Left = 137
          Top = 48
          Width = 160
          Height = 23
          Anchors = [akLeft, akTop]
          TabOrder = 1
          OnDblClick = edtGridColor2DblClick
          OnExit = edtGridColor2Exit
        end
        object edtGridColorActive: TEdit
          Left = 137
          Top = 71
          Width = 160
          Height = 23
          Anchors = [akLeft, akTop]
          TabOrder = 2
          OnDblClick = edtGridColorActiveDblClick
          OnExit = edtGridColorActiveExit
        end
        object edtCryptKey: TEdit
          Left = 137
          Top = 94
          Width = 160
          Height = 23
          Anchors = [akLeft, akTop]
          TabOrder = 3
        end
        object edtPeriod: TEdit
          Left = 137
          Top = 118
          Width = 160
          Height = 23
          Anchors = [akLeft, akTop]
          TabOrder = 4
        end
        object edtAppVersion: TEdit
          Left = 137
          Top = 164
          Width = 160
          Height = 23
          Anchors = [akLeft, akTop]
          TabOrder = 5
        end
      end
    end
  end
end

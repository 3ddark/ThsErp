inherited frmDashboard: TfrmDashboard
  ActiveControl = PageControl1
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Main'
  ClientHeight = 450
  ClientWidth = 915
  Constraints.MinHeight = 300
  Constraints.MinWidth = 400
  DefaultMonitor = dmDesktop
  ParentFont = True
  Menu = mm1
  Position = poDesktopCenter
  Scaled = False
  WindowMenu = VeritabanYedekAl1
  OnActivate = FormActivate
  ExplicitWidth = 931
  ExplicitHeight = 509
  TextHeight = 15
  object pnlToolbar: TPanel [0]
    Left = 0
    Top = 0
    Width = 915
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Color = 12477460
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 634
    object lblTitle: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 2
      Width = 201
      Height = 25
      Margins.Left = 8
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alLeft
      Caption = 'Ths Erp Application'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
  end
  inherited pnlBottom: TPanel [1]
    Top = 402
    Width = 911
    Color = clBtnFace
    ParentBackground = False
    TabOrder = 2
    ExplicitTop = 356
    ExplicitWidth = 630
    inherited btnAccept: TButton
      Left = 705
      ExplicitLeft = 424
    end
    inherited btnClose: TButton
      Left = 809
      ExplicitLeft = 528
    end
  end
  inherited stbBase: TStatusBar [2]
    Top = 432
    Width = 915
    ExplicitTop = 386
    ExplicitWidth = 634
  end
  inherited pnlMain: TPanel [3]
    Top = 40
    Width = 915
    Height = 360
    TabOrder = 1
    ExplicitTop = 40
    ExplicitWidth = 634
    ExplicitHeight = 314
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 915
      Height = 360
      ActivePage = tsstock
      Align = alClient
      MultiLine = True
      TabOrder = 0
      object tsgeneral: TTabSheet
        Caption = 'Genel'
        object btnbbk_kayit: TButton
          Left = 3
          Top = 229
          Width = 150
          Height = 36
          Caption = 'Bilgi Bankas'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 18
          Images = dm.il32
          ParentFont = False
          TabOrder = 0
          WordWrap = True
          OnClick = actbbk_kayitExecute
        end
      end
      object tssales: TTabSheet
        Caption = 'Sat'#305#351'lar'
        Font.Charset = TURKISH_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ImageIndex = 2
        ParentFont = False
        object btnsat_teklif: TButton
          Left = 2
          Top = 2
          Width = 150
          Height = 36
          Caption = 'Teklifler'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 88
          Images = dm.il32
          ParentFont = False
          TabOrder = 0
          WordWrap = True
          OnClick = actsat_teklifExecute
        end
        object btnsat_siparis: TButton
          Left = 158
          Top = 2
          Width = 150
          Height = 36
          Caption = 'Sipari'#351'ler'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 86
          Images = dm.il32
          ParentFont = False
          TabOrder = 1
          WordWrap = True
          OnClick = actsat_siparisExecute
        end
        object btnsat_teklif_rapor: TButton
          Left = 2
          Top = 44
          Width = 150
          Height = 36
          Caption = 'Teklif Rapor'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 9
          Images = dm.il32
          ParentFont = False
          TabOrder = 2
          WordWrap = True
        end
        object btnsat_siparis_rapor: TButton
          Left = 158
          Top = 44
          Width = 150
          Height = 36
          Caption = 'Sipari'#351' Rapor'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 9
          Images = dm.il32
          ParentFont = False
          TabOrder = 3
          WordWrap = True
          OnClick = actsat_siparis_raporExecute
        end
      end
      object tsstock: TTabSheet
        Caption = 'Stoklar'
        ImageIndex = 3
        object btnstk_stok_karti: TButton
          Left = 2
          Top = 2
          Width = 150
          Height = 36
          Action = actstk_stok_kartlari
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 0
          WordWrap = True
        end
        object btnstk_cins_ozelligi: TButton
          Left = 158
          Top = 2
          Width = 150
          Height = 36
          Action = actstk_cins_ozellikleri
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 1
          WordWrap = True
        end
        object btnstk_stok_ambar: TButton
          Left = 158
          Top = 44
          Width = 150
          Height = 36
          Action = actstk_ambarlar
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 3
          WordWrap = True
        end
        object btnstk_stok_grubu: TButton
          Left = 158
          Top = 86
          Width = 150
          Height = 36
          Action = actstk_gruplar
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 4
          WordWrap = True
        end
        object btnsys_olcu_birimleri: TButton
          Left = 470
          Top = 2
          Width = 150
          Height = 36
          Action = actsys_unit
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 2
          WordWrap = True
        end
      end
      object tsaccount: TTabSheet
        Caption = 'Hesaplar'
        ImageIndex = 4
        object btnch_hesap_karti: TButton
          Left = 2
          Top = 170
          Width = 150
          Height = 36
          Caption = 'Hesap Kart'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 14
          Images = dm.il32
          ParentFont = False
          TabOrder = 6
          OnClick = actch_hesap_kartiExecute
        end
        object btnch_hesap_karti_ara: TButton
          Left = 2
          Top = 128
          Width = 150
          Height = 36
          Caption = 'Hesap Kart'#305' Ara Hesap'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 14
          Images = dm.il32
          ParentFont = False
          TabOrder = 4
          WordWrap = True
          OnClick = actch_hesap_karti_araExecute
        end
        object btnch_banka: TButton
          Left = 2
          Top = 44
          Width = 150
          Height = 36
          Caption = 'Bankalar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 69
          Images = dm.il32
          ParentFont = False
          TabOrder = 1
          Visible = False
        end
        object btnch_banka_subesi: TButton
          Left = 2
          Top = 86
          Width = 150
          Height = 36
          Caption = 'Banka '#350'ubeleri'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 69
          Images = dm.il32
          ParentFont = False
          TabOrder = 2
          Visible = False
        end
        object btnset_ch_grup: TButton
          Left = 160
          Top = 86
          Width = 150
          Height = 36
          Caption = 'Hesap Gruplar'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 70
          Images = dm.il32
          ParentFont = False
          TabOrder = 3
          OnClick = actset_ch_grupExecute
        end
        object btnset_ch_hesap_plani: TButton
          Left = 160
          Top = 128
          Width = 150
          Height = 36
          Caption = 'Hesap Planlar'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 76
          Images = dm.il32
          ParentFont = False
          TabOrder = 5
          Visible = False
          OnClick = actset_ch_hesap_planiExecute
        end
        object btnset_ch_vergi_orani: TButton
          Left = 160
          Top = 212
          Width = 150
          Height = 36
          Caption = 'Vergi Oranlar'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 68
          Images = dm.il32
          ParentFont = False
          TabOrder = 7
          Visible = False
        end
        object btnch_bolge: TButton
          Left = 2
          Top = 2
          Width = 150
          Height = 36
          Caption = 'B'#246'lge'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 72
          Images = dm.il32
          ParentFont = False
          TabOrder = 0
          OnClick = actch_bolgeExecute
        end
      end
      object tsemployee: TTabSheet
        Caption = 'Personel'
        ImageIndex = 7
        object btnprs_personel: TButton
          Left = 2
          Top = 2
          Width = 150
          Height = 36
          Action = actprs_personeller
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 0
          WordWrap = True
        end
      end
      object tsbom: TTabSheet
        Caption = 'Re'#231'eteler'
        ImageIndex = 5
        object btnrct_recete: TButton
          Left = 2
          Top = 2
          Width = 150
          Height = 36
          Caption = 'Re'#231'eteler'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 66
          Images = dm.il32
          ParentFont = False
          TabOrder = 0
          WordWrap = True
          OnClick = actrct_receteExecute
        end
        object btnrct_iscilik_gideri: TButton
          Left = 158
          Top = 2
          Width = 150
          Height = 36
          Caption = #304#351#231'ilik Giderleri'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 76
          Images = dm.il32
          ParentFont = False
          TabOrder = 1
          WordWrap = True
          OnClick = actrct_iscilik_gideriExecute
        end
        object btnrct_paket_hammadde: TButton
          Left = 158
          Top = 44
          Width = 150
          Height = 36
          Caption = 'Paket Hammaddeler'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ImageIndex = 76
          Images = dm.il32
          ParentFont = False
          TabOrder = 2
          Visible = False
          WordWrap = True
          OnClick = actrct_paket_hammaddeExecute
        end
      end
      object tsaccounting: TTabSheet
        Caption = 'Muhasebe'
        ImageIndex = 6
        object btnmhs_doviz_kuru: TButton
          Left = 314
          Top = 2
          Width = 150
          Height = 36
          Action = actacc_exchange_rate
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 0
        end
        object btnsys_para_birimleri: TButton
          Left = 470
          Top = 2
          Width = 150
          Height = 36
          Action = actsys_currency
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 1
        end
      end
    end
  end
  inherited AppEvntsBase: TApplicationEvents
    Left = 504
    Top = 240
  end
  object actlstMain: TActionList
    Images = dm.il16
    OnExecute = actlstMainExecute
    Left = 344
    Top = 136
    object actset_prs_birimler: TAction
      Category = 'Personel'
      Caption = 'Birimler'
      ImageIndex = 70
      OnExecute = actset_prs_birimlerExecute
    end
    object actset_prs_gorevler: TAction
      Category = 'Personel'
      Caption = 'G'#246'revler'
      ImageIndex = 74
      OnExecute = actset_prs_gorevlerExecute
    end
    object actsys_month: TAction
      Category = 'Sistem'
      Caption = 'Aylar'
      ImageIndex = 8
      OnExecute = actsys_monthExecute
    end
    object actset_prs_lisanlar: TAction
      Category = 'Personel'
      Caption = 'Lisanlar'
      ImageIndex = 35
      OnExecute = actset_prs_lisanlarExecute
    end
    object actsys_region: TAction
      Category = 'Sistem'
      Caption = 'B'#246'lgeler'
      ImageIndex = 68
      OnExecute = actsys_regionExecute
    end
    object actacc_exchange_rate: TAction
      Category = 'Sistem'
      Caption = 'D'#246'viz Kurlar'#305
      ImageIndex = 68
      OnExecute = actacc_exchange_rateExecute
    end
    object actsys_access_right: TAction
      Category = 'Sistem'
      Caption = 'Kullan'#305'c'#305' Eri'#351'im Haklar'#305
      ImageIndex = 62
      OnExecute = actsys_access_rightExecute
    end
    object actsys_grid_filter_sort: TAction
      Category = 'Sistem'
      Caption = 'Grid Filtre ve S'#305'ralamalar'
      ImageIndex = 26
      OnExecute = actsys_grid_filter_sortExecute
    end
    object actsys_grid_column: TAction
      Category = 'Sistem'
      Caption = 'Grid Kolon Geni'#351'likleri && G'#246'r'#252'n'#252'rl'#252'kler'
      ImageIndex = 12
      OnExecute = actsys_grid_columnExecute
    end
    object actsys_day: TAction
      Category = 'Sistem'
      Caption = 'G'#252'nler'
      ImageIndex = 85
      OnExecute = actsys_dayExecute
    end
    object actsys_resource: TAction
      Category = 'Sistem'
      Caption = 'Kaynaklar'
      ImageIndex = 81
      OnExecute = actsys_resourceExecute
    end
    object actsys_resource_group: TAction
      Category = 'Sistem'
      Caption = 'Kaynak Gruplar'#305
      ImageIndex = 81
      OnExecute = actsys_resource_groupExecute
    end
    object actsys_user: TAction
      Category = 'Sistem'
      Caption = 'Kullan'#305'c'#305'lar'
      ImageIndex = 64
      OnExecute = actsys_userExecute
    end
    object actsys_lang_gui_content: TAction
      Category = 'Sistem'
      Caption = 'GUI '#304#231'erikleri'
      ImageIndex = 35
      OnExecute = actsys_lang_gui_contentExecute
    end
    object actsys_unit: TAction
      Category = 'Sistem'
      Caption = #214'l'#231#252' Birimleri'
      ImageIndex = 74
      OnExecute = actsys_unitExecute
    end
    object actsys_unit_type: TAction
      Category = 'Sistem'
      Caption = #214'l'#231#252' Birimi Tipleri'
      ImageIndex = 74
      OnExecute = actsys_unit_typeExecute
    end
    object actsys_currency: TAction
      Category = 'Sistem'
      Caption = 'Para Birimleri'
      ImageIndex = 68
      OnExecute = actsys_currencyExecute
    end
    object actsys_city: TAction
      Category = 'Sistem'
      Caption = #350'ehirler'
      ImageIndex = 71
      OnExecute = actsys_cityExecute
    end
    object actsys_update_password: TAction
      Category = 'Sistem'
      Caption = 'Update Password'
      ImageIndex = 62
      OnExecute = actsys_update_passwordExecute
    end
    object actsys_country: TAction
      Category = 'Sistem'
      Caption = #220'lkeler'
      ImageIndex = 72
      OnExecute = actsys_countryExecute
    end
    object actsys_application_setting: TAction
      Category = 'Sistem'
      Caption = 'Uygulama Ayarlar'#305
      ImageIndex = 76
      OnExecute = actsys_application_settingExecute
    end
    object actsys_application_setting_other: TAction
      Category = 'Sistem'
      Caption = 'Application Settings Other'
      ImageIndex = 76
    end
    object actsys_update: TAction
      Category = 'Sistem'
      Caption = 'Update'
      ImageIndex = 3
      OnExecute = actsys_updateExecute
    end
    object actsys_about: TAction
      Category = 'Sistem'
      Caption = 'About'
      ImageIndex = 34
      OnExecute = actsys_aboutExecute
    end
    object actsys_database_status: TAction
      Category = 'Sistem'
      Caption = 'Database Monitor'
      ImageIndex = 55
      OnExecute = actsys_database_statusExecute
    end
    object actsys_do_database_backup: TAction
      Category = 'Sistem'
      Caption = 'Database Backup'
      ImageIndex = 18
      OnExecute = actsys_do_database_backupExecute
    end
    object actstk_ambarlar: TAction
      Category = 'Stok'
      Caption = 'Ambarlar'
      ImageIndex = 73
      OnExecute = actstk_ambarlarExecute
    end
    object actstk_cins_ozellikleri: TAction
      Category = 'Stok'
      Caption = 'Cins '#214'zellikleri'
      ImageIndex = 84
      OnExecute = actstk_cins_ozellikleriExecute
    end
    object actstk_gruplar: TAction
      Category = 'Stok'
      Caption = 'Gruplar'
      ImageIndex = 14
      OnExecute = actstk_gruplarExecute
    end
    object actstk_hareketler: TAction
      Category = 'Stok'
      Caption = 'Stok Hareketleri'
      ImageIndex = 70
      OnExecute = actstk_hareketlerExecute
    end
    object actstk_stok_kartlari: TAction
      Category = 'Stok'
      Caption = 'Stok Kartlar'#305
      ImageIndex = 2
      OnExecute = actstk_stok_kartlariExecute
    end
    object actstk_stok_karti_ozetleri: TAction
      Category = 'Stok'
      Caption = 'Stok Kart'#305' '#214'zetleri'
      ImageIndex = 59
      OnExecute = actstk_stok_karti_ozetleriExecute
    end
    object actset_ch_vergi_orani: TAction
      Category = 'CariHesap'
      Caption = 'KDV Vergi Oranlar'#305
      ImageIndex = 38
      OnExecute = actset_ch_vergi_oraniExecute
    end
    object actset_prs_bolumler: TAction
      Category = 'Personel'
      Caption = 'B'#246'l'#252'mler'
      ImageIndex = 70
      OnExecute = actset_prs_bolumlerExecute
    end
    object actset_prs_ehliyetler: TAction
      Category = 'Personel'
      Caption = 'Ehliyetler'
      ImageIndex = 98
      OnExecute = actset_prs_ehliyetlerExecute
    end
    object actset_prs_lisan_seviyeleri: TAction
      Category = 'Personel'
      Caption = 'Lisan Seviyeleri'
      ImageIndex = 97
      OnExecute = actset_prs_lisan_seviyeleriExecute
    end
    object actset_prs_personel_tipleri: TAction
      Category = 'Personel'
      Caption = 'Personel Tipleri'
      ImageIndex = 64
      OnExecute = actset_prs_personel_tipleriExecute
    end
    object actprs_ehliyetler: TAction
      Category = 'Personel'
      Caption = 'Personel Ehliyetleri'
      ImageIndex = 98
      OnExecute = actprs_ehliyetlerExecute
    end
    object actprs_lisan_bilgileri: TAction
      Category = 'Personel'
      Caption = 'Personel Lisan Bilgileri'
      ImageIndex = 35
      OnExecute = actprs_lisan_bilgileriExecute
    end
    object actprs_personeller: TAction
      Category = 'Personel'
      Caption = 'Personel Bilgileri'
      ImageIndex = 64
      OnExecute = actprs_personellerExecute
    end
    object actals_teklifler: TAction
      Category = 'AlsTeklif'
      Caption = 'Sat'#305'n Alma Teklifler'
      ImageIndex = 93
      OnExecute = actals_tekliflerExecute
    end
    object actch_bankalar: TAction
      Category = 'CariHesap'
      Caption = 'Bankalar'
      ImageIndex = 69
      OnExecute = actch_bankalarExecute
    end
    object actch_banka_subeleri: TAction
      Category = 'CariHesap'
      Caption = 'Banka '#350'ubeleri'
      ImageIndex = 69
      OnExecute = actch_banka_subeleriExecute
    end
    object actset_prs_tasima_servisleri: TAction
      Category = 'Personel'
      Caption = 'Personel Ta'#351#305'ma Servisleri'
      ImageIndex = 98
      OnExecute = actset_prs_tasima_servisleriExecute
    end
  end
  object tmrcheck_is_update_required: TTimer
    Enabled = False
    Interval = 60000
    OnTimer = tmrcheck_is_update_requiredTimer
    Left = 368
    Top = 280
  end
  object mm1: TMainMenu
    Images = dm.il16
    Left = 168
    Top = 144
    object mnimenu_system: TMenuItem
      Caption = 'Sistem'
      object mnisys_user: TMenuItem
        Action = actsys_user
      end
      object mnisys_access_right: TMenuItem
        Action = actsys_access_right
      end
      object mniN8: TMenuItem
        Caption = '-'
      end
      object mnisys_application_setting: TMenuItem
        Action = actsys_application_setting
      end
      object mniN9: TMenuItem
        Caption = '-'
      end
      object mnisys_grid_column: TMenuItem
        Action = actsys_grid_column
      end
      object mnisys_grid_filter_sort: TMenuItem
        Action = actsys_grid_filter_sort
      end
      object mnisys_lang_gui_content: TMenuItem
        Action = actsys_lang_gui_content
      end
      object mniN10: TMenuItem
        Caption = '-'
      end
      object mnisys_resource_group: TMenuItem
        Action = actsys_resource_group
      end
      object mnisys_resource: TMenuItem
        Action = actsys_resource
      end
      object mniSystemSubSettings: TMenuItem
        Caption = 'Ayarlar'
        object mnisys_country: TMenuItem
          Action = actsys_country
        end
        object mnisys_city: TMenuItem
          Action = actsys_city
        end
        object mnisys_region: TMenuItem
          Action = actsys_region
        end
        object mniN7: TMenuItem
          Caption = '-'
        end
        object mnisys_unit_type: TMenuItem
          Action = actsys_unit_type
        end
        object mnisys_unit: TMenuItem
          Action = actsys_unit
        end
        object mnisys_currency: TMenuItem
          Action = actsys_currency
        end
        object mniN4: TMenuItem
          Caption = '-'
        end
        object mnisys_month: TMenuItem
          Action = actsys_month
        end
        object mnisys_day: TMenuItem
          Action = actsys_day
        end
      end
    end
    object mnimenu_alim: TMenuItem
      Caption = 'Al'#305'mlar'
      object mnialim_teklif: TMenuItem
        Action = actals_teklifler
      end
      object mnialim_siparis: TMenuItem
        Caption = 'Sipari'#351
      end
      object mnialim_irsaliye: TMenuItem
        Caption = #304'rsaliye'
      end
      object mnialim_fatura: TMenuItem
        Caption = 'Fatura'
      end
    end
    object mnimenu_satis: TMenuItem
      Caption = 'Sat'#305#351'lar'
    end
    object mnimenu_muhasebe: TMenuItem
      Caption = 'Muhasebe'
      object mnich_bankalar: TMenuItem
        Action = actch_bankalar
      end
      object mnich_banka_subeleri: TMenuItem
        Action = actch_banka_subeleri
      end
      object mnimuhasebe_ayarlar: TMenuItem
        Caption = 'Ayarlar'
        object mniset_ch_vergi_orani: TMenuItem
          Action = actset_ch_vergi_orani
        end
      end
    end
    object mnimenu_stok: TMenuItem
      Caption = 'Stoklar'
      object mnistk_ambarlar: TMenuItem
        Action = actstk_ambarlar
      end
      object mnistk_gruplar: TMenuItem
        Action = actstk_gruplar
      end
    end
    object mnimenu_personel: TMenuItem
      Caption = 'Personel'
      ImageIndex = 14
      object mniprs_personeller: TMenuItem
        Action = actprs_personeller
      end
      object mniprs_ehliyetler: TMenuItem
        Action = actprs_ehliyetler
      end
      object mniprs_lisan_bilgileri: TMenuItem
        Action = actprs_lisan_bilgileri
      end
      object mnipersonel_ayarlar: TMenuItem
        Caption = 'Ayarlar'
        ImageIndex = 76
        object mniset_prs_bolumler: TMenuItem
          Action = actset_prs_bolumler
        end
        object mniset_prs_birimller: TMenuItem
          Action = actset_prs_birimler
        end
        object mniset_prs_gorevler: TMenuItem
          Action = actset_prs_gorevler
        end
        object mniset_prs_ehliyetler: TMenuItem
          Action = actset_prs_ehliyetler
        end
        object mniset_prs_lisanlar: TMenuItem
          Action = actset_prs_lisanlar
        end
        object mniset_prs_lisan_seviyeleri: TMenuItem
          Action = actset_prs_lisan_seviyeleri
        end
        object mniset_prs_personel_tipleri: TMenuItem
          Action = actset_prs_personel_tipleri
        end
        object mniset_prs_tasima_servisleri: TMenuItem
          Action = actset_prs_tasima_servisleri
        end
      end
    end
    object mnimenu_hakkinda: TMenuItem
      Caption = 'Hakk'#305'nda'
      ImageIndex = 34
      object Hakknda2: TMenuItem
        Action = actsys_about
        Caption = 'Hakk'#305'nda'
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object ifreDeitir1: TMenuItem
        Action = actsys_update_password
        Caption = #350'ifre De'#287'i'#351'tir'
      end
      object DatabaseMonitor1: TMenuItem
        Action = actsys_database_status
        Caption = 'Veri Taban'#305' Monitor'
      end
      object VeritabanYedekAl1: TMenuItem
        Action = actsys_do_database_backup
        Caption = 'Veri Taban'#305' Yedek'
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Gncelle1: TMenuItem
        Action = actsys_update
        Caption = 'G'#252'ncelleme'
      end
    end
  end
end

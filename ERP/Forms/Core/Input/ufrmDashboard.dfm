inherited frmDashboard: TfrmDashboard
  BorderIcons = [biSystemMenu, biMinimize, biMaximize]
  Caption = 'Main'
  ClientHeight = 700
  ClientWidth = 1180
  Constraints.MinHeight = 480
  Constraints.MinWidth = 760
  DefaultMonitor = dmDesktop
  ParentFont = True
  Menu = mm1
  Position = poScreenCenter
  Scaled = False
  WindowMenu = mnisys_do_database_backup
  OnActivate = FormActivate
  OnClose = nil
  ExplicitWidth = 931
  ExplicitHeight = 531
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
    object lblTitle: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 2
      Width = 201
      Height = 36
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
      ExplicitHeight = 25
    end
  end
  inherited pnlBottom: TPanel [1]
    Top = 424
    Width = 911
    Color = clBtnFace
    ParentBackground = False
    TabOrder = 2
    ExplicitTop = 424
    ExplicitWidth = 911
    inherited btnAccept: TButton
      Left = 705
      ExplicitLeft = 705
    end
    inherited btnClose: TButton
      Left = 809
      ExplicitLeft = 809
    end
  end
  inherited stbBase: TStatusBar [2]
    Top = 454
    Width = 915
    ExplicitTop = 454
    ExplicitWidth = 915
  end
  inherited pnlMain: TPanel [3]
    Top = 40
    Width = 915
    Height = 382
    TabOrder = 1
    ExplicitTop = 40
    ExplicitWidth = 915
    ExplicitHeight = 382
  end
  object actlstMain: TActionList
    Images = dm.il16
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
    object actset_prs_lisanlar: TAction
      Category = 'Personel'
      Caption = 'Lisanlar'
      ImageIndex = 35
      OnExecute = actset_prs_lisanlarExecute
    end
    object actsys_region: TAction
      Category = 'System'
      Caption = 'B'#246'lgeler'
      ImageIndex = 68
      OnExecute = actsys_regionExecute
    end
    object actacc_exchange_rate: TAction
      Category = 'System'
      Caption = 'D'#246'viz Kurlar'#305
      ImageIndex = 68
      OnExecute = actacc_exchange_rateExecute
    end
    object actsys_access_right: TAction
      Category = 'System'
      Caption = 'Kullan'#305'c'#305' Eri'#351'im Haklar'#305
      ImageIndex = 62
      OnExecute = actsys_access_rightExecute
    end
    object actsys_grid_filter: TAction
      Category = 'System'
      Caption = 'Grid Filtreleri'
      ImageIndex = 26
      OnExecute = actsys_grid_filterExecute
    end
    object actsys_grid_sort: TAction
      Category = 'System'
      Caption = 'Grid S'#305'ralamalar'#305
      ImageIndex = 26
      OnExecute = actsys_grid_sortExecute
    end
    object actsys_grid_column: TAction
      Category = 'System'
      Caption = 'Grid Kolon Geni'#351'likleri && G'#246'r'#252'n'#252'rl'#252'kler'
      ImageIndex = 12
      OnExecute = actsys_grid_columnExecute
    end
    object actsys_permission: TAction
      Category = 'System'
      Caption = 'Kaynaklar'
      ImageIndex = 81
      OnExecute = actsys_permissionExecute
    end
    object actsys_permission_group: TAction
      Category = 'System'
      Caption = 'Kaynak Gruplar'#305
      ImageIndex = 81
      OnExecute = actsys_permission_groupExecute
    end
    object actsys_user: TAction
      Category = 'System'
      Caption = 'Kullan'#305'c'#305'lar'
      ImageIndex = 64
      OnExecute = actsys_userExecute
    end
    object actsys_unit: TAction
      Category = 'System'
      Caption = #214'l'#231#252' Birimleri'
      ImageIndex = 74
      OnExecute = actsys_unitExecute
    end
    object actsys_unit_type: TAction
      Category = 'System'
      Caption = #214'l'#231#252' Birimi Tipleri'
      ImageIndex = 74
      OnExecute = actsys_unit_typeExecute
    end
    object actsys_currency: TAction
      Category = 'System'
      Caption = 'Para Birimleri'
      ImageIndex = 68
      OnExecute = actsys_currencyExecute
    end
    object actsys_city: TAction
      Category = 'System'
      Caption = #350'ehirler'
      ImageIndex = 71
      OnExecute = actsys_cityExecute
    end
    object actsys_update_password: TAction
      Category = 'System'
      Caption = 'Update Password'
      ImageIndex = 62
      OnExecute = actsys_update_passwordExecute
    end
    object actsys_refresh_permissions: TAction
      Category = 'System'
      Caption = 'Refresh My Permissions'
      OnExecute = actsys_refresh_permissionsExecute
    end
    object actsys_country: TAction
      Category = 'System'
      Caption = #220'lkeler'
      ImageIndex = 72
      OnExecute = actsys_countryExecute
    end
    object actsys_application_setting: TAction
      Category = 'System'
      Caption = 'Uygulama Ayarlar'#305
      ImageIndex = 76
      OnExecute = actsys_application_settingExecute
    end
    object actsys_update: TAction
      Category = 'System'
      Caption = 'Update'
      Enabled = False
      ImageIndex = 3
      OnExecute = actsys_updateExecute
    end
    object actsys_about: TAction
      Category = 'System'
      Caption = 'About'
      ImageIndex = 34
      OnExecute = actsys_aboutExecute
    end
    object actsys_database_status: TAction
      Category = 'System'
      Caption = 'Database Monitor'
      ImageIndex = 55
    end
    object actsys_do_database_backup: TAction
      Category = 'System'
      Caption = 'Database Backup'
      ImageIndex = 18
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
    object actprd_bom: TAction
      Category = 'Uretim'
      Caption = 'Re'#231'eteler'
      ImageIndex = 66
      OnExecute = actprd_bomExecute
    end
    object actprd_labour: TAction
      Category = 'Uretim'
      Caption = #304#351#231'ilik / Giderler'
      ImageIndex = 76
      OnExecute = actprd_labourExecute
    end
    object actprd_packet_raw: TAction
      Category = 'Uretim'
      Caption = 'Hammadde Paketleri'
      ImageIndex = 76
      OnExecute = actprd_packet_rawExecute
    end
    object actprd_packet_labour: TAction
      Category = 'Uretim'
      Caption = #304#351#231'ilik Paketleri'
      ImageIndex = 76
      OnExecute = actprd_packet_labourExecute
    end
    object actacc_account_transactions: TAction
      Category = 'Muhasebe'
      Caption = 'Cari Hesap Hareketleri'
      ImageIndex = 14
      OnExecute = actacc_account_transactionsExecute
    end
    object actfin_company_bank_accounts: TAction
      Category = 'Finans'
      Caption = 'Firma Banka Hesaplar'#305
      ImageIndex = 69
      OnExecute = actfin_company_bank_accountsExecute
    end
    object actpur_requests: TAction
      Category = 'SatinAlma'
      Caption = 'Sat'#305'n Alma Talepleri'
      ImageIndex = 88
      OnExecute = actpur_requestsExecute
    end
    object actpur_request_lines: TAction
      Category = 'SatinAlma'
      Caption = 'Talep Kalemleri'
      ImageIndex = 88
      OnExecute = actpur_request_linesExecute
    end
    object actpur_orders: TAction
      Category = 'SatinAlma'
      Caption = 'Sat'#305'n Alma Sipari'#351'leri'
      ImageIndex = 88
      OnExecute = actpur_ordersExecute
    end
    object actpur_order_lines: TAction
      Category = 'SatinAlma'
      Caption = 'Sipari'#351' Kalemleri'
      ImageIndex = 88
      OnExecute = actpur_order_linesExecute
    end
    object actpur_receipts: TAction
      Category = 'SatinAlma'
      Caption = 'Mal Kabuller'
      ImageIndex = 88
      OnExecute = actpur_receiptsExecute
    end
    object actpur_receipt_lines: TAction
      Category = 'SatinAlma'
      Caption = 'Mal Kabul Kalemleri'
      ImageIndex = 88
      OnExecute = actpur_receipt_linesExecute
    end
    object actpur_invoices: TAction
      Category = 'SatinAlma'
      Caption = 'Al'#305#351' Faturalar'#305
      ImageIndex = 88
      OnExecute = actpur_invoicesExecute
    end
    object actpur_invoice_lines: TAction
      Category = 'SatinAlma'
      Caption = 'Fatura Kalemleri'
      ImageIndex = 88
      OnExecute = actpur_invoice_linesExecute
    end
    object actsls_offers: TAction
      Category = 'Satis'
      Caption = 'Sat'#305#351' Teklifleri'
      ImageIndex = 93
      OnExecute = actsls_offersExecute
    end
    object actsls_orders: TAction
      Category = 'Satis'
      Caption = 'Sat'#305#351' Sipari'#351'leri'
      ImageIndex = 93
      OnExecute = actsls_ordersExecute
    end
    object actsls_dispatches: TAction
      Category = 'Satis'
      Caption = 'Sevk '#304'rsaliyeleri'
      ImageIndex = 93
      OnExecute = actsls_dispatchesExecute
    end
    object actsls_invoices: TAction
      Category = 'Satis'
      Caption = 'Sat'#305#351' Faturalar'#305
      ImageIndex = 93
      OnExecute = actsls_invoicesExecute
    end
    object actsls_diibs: TAction
      Category = 'Satis'
      Caption = 'D'#304#304'B Belgeleri'
      ImageIndex = 93
      OnExecute = actsls_diibsExecute
    end
    object actsls_diib_lines: TAction
      Category = 'Satis'
      Caption = 'D'#304#304'B Sat'#305'rlar'#305
      ImageIndex = 93
      OnExecute = actsls_diib_linesExecute
    end
    object actsls_einv_profiles: TAction
      Category = 'Satis'
      Caption = 'e-Belge Senaryolar'#305
      ImageIndex = 93
      OnExecute = actsls_einv_profilesExecute
    end
    object actsls_einv_invoice_types: TAction
      Category = 'Satis'
      Caption = 'e-Fatura Tipleri'
      ImageIndex = 93
      OnExecute = actsls_einv_invoice_typesExecute
    end
    object actsls_einv_tax_exemptions: TAction
      Category = 'Satis'
      Caption = 'Vergi '#304'stisna Kodlar'#305
      ImageIndex = 93
      OnExecute = actsls_einv_tax_exemptionsExecute
    end
    object actsls_einv_tax_types: TAction
      Category = 'Satis'
      Caption = 'Vergi T'#252'r'#252' Kodlar'#305
      ImageIndex = 93
      OnExecute = actsls_einv_tax_typesExecute
    end
    object actsls_einv_withholdings: TAction
      Category = 'Satis'
      Caption = 'Tevkifat Kodlar'#305
      ImageIndex = 93
      OnExecute = actsls_einv_withholdingsExecute
    end
    object actsls_einv_delivery_terms: TAction
      Category = 'Satis'
      Caption = 'Teslim '#350'artlar'#305
      ImageIndex = 93
      OnExecute = actsls_einv_delivery_termsExecute
    end
    object actsls_einv_transport_modes: TAction
      Category = 'Satis'
      Caption = 'Ta'#351#305'ma '#350'ekilleri'
      ImageIndex = 93
      OnExecute = actsls_einv_transport_modesExecute
    end
    object actsls_einv_packaging_types: TAction
      Category = 'Satis'
      Caption = 'Paket / Kap Cinsleri'
      ImageIndex = 93
      OnExecute = actsls_einv_packaging_typesExecute
    end
    object actsls_einv_payment_means: TAction
      Category = 'Satis'
      Caption = #214'deme '#350'ekilleri'
      ImageIndex = 93
      OnExecute = actsls_einv_payment_meansExecute
    end
    object actsls_einv_series: TAction
      Category = 'Satis'
      Caption = 'e-Belge Serileri'
      ImageIndex = 93
      OnExecute = actsls_einv_seriesExecute
    end
    object actstk_gtips: TAction
      Category = 'Stok'
      Caption = 'GT'#304'P Kodlar'#305
      ImageIndex = 83
      OnExecute = actstk_gtipsExecute
    end
    object actfin_money_accounts: TAction
      Category = 'Finans'
      Caption = 'Kasa / Banka Hesaplar'#305
      ImageIndex = 69
      OnExecute = actfin_money_accountsExecute
    end
    object actfin_money_transactions: TAction
      Category = 'Finans'
      Caption = 'Tahsilat / '#214'deme / Virman'
      ImageIndex = 68
      OnExecute = actfin_money_transactionsExecute
    end
    object actfin_money_ledger: TAction
      Category = 'Finans'
      Caption = 'Kasa / Banka Ekstresi'
      ImageIndex = 68
      OnExecute = actfin_money_ledgerExecute
    end
    object actfin_customer_cheques: TAction
      Category = 'Finans'
      Caption = 'M'#252#351'teri '#199'ekleri'
      ImageIndex = 68
      OnExecute = actfin_customer_chequesExecute
    end
    object actfin_own_cheques: TAction
      Category = 'Finans'
      Caption = 'Kendi '#199'eklerimiz'
      ImageIndex = 68
      OnExecute = actfin_own_chequesExecute
    end
    object actfin_customer_notes: TAction
      Category = 'Finans'
      Caption = 'M'#252#351'teri Senetleri'
      ImageIndex = 68
      OnExecute = actfin_customer_notesExecute
    end
    object actfin_debit_notes: TAction
      Category = 'Finans'
      Caption = 'Bor'#231' Senetlerimiz'
      ImageIndex = 68
      OnExecute = actfin_debit_notesExecute
    end
    object actfin_cheque_notes: TAction
      Category = 'Finans'
      Caption = 'T'#252'm '#199'ek / Senetler'
      ImageIndex = 68
      OnExecute = actfin_cheque_notesExecute
    end
    object actfin_cheque_note_transactions: TAction
      Category = 'Finans'
      Caption = #199'ek / Senet Hareketleri'
      ImageIndex = 68
      OnExecute = actfin_cheque_note_transactionsExecute
    end
    object actfin_credit_cards: TAction
      Category = 'Finans'
      Caption = 'Firma Kredi Kartlar'#305
      ImageIndex = 69
      OnExecute = actfin_credit_cardsExecute
    end
    object actfin_credit_card_transactions: TAction
      Category = 'Finans'
      Caption = 'Kredi Kart'#305' Hareketleri'
      ImageIndex = 69
      OnExecute = actfin_credit_card_transactionsExecute
    end
    object actfin_pos_terminals: TAction
      Category = 'Finans'
      Caption = 'POS Tan'#305'mlar'#305
      ImageIndex = 69
      OnExecute = actfin_pos_terminalsExecute
    end
    object actfin_pos_transactions: TAction
      Category = 'Finans'
      Caption = 'POS Tahsilatlar'#305
      ImageIndex = 69
      OnExecute = actfin_pos_transactionsExecute
    end
    object actstk_product_types: TAction
      Category = 'Stok'
      Caption = #220'r'#252'n Tipleri'
      ImageIndex = 70
      OnExecute = actstk_product_typesExecute
    end
    object actstk_kind_families: TAction
      Category = 'Stok'
      Caption = 'Cins Aileleri'
      ImageIndex = 84
      OnExecute = actstk_kind_familiesExecute
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
    object actch_hesap_karti: TAction
      Category = 'CariHesap'
      Caption = 'Hesap Kartlar'#305
      ImageIndex = 14
      OnExecute = actch_hesap_kartiExecute
    end
    object actch_hesap_karti_ara: TAction
      Category = 'CariHesap'
      Caption = 'Ara Hesaplar'
      ImageIndex = 14
      OnExecute = actch_hesap_karti_araExecute
    end
    object actch_bolge: TAction
      Category = 'CariHesap'
      Caption = 'Hesap B'#246'lgeleri'
      ImageIndex = 72
      OnExecute = actch_bolgeExecute
    end
    object actset_ch_grup: TAction
      Category = 'CariHesap'
      Caption = 'Hesap Gruplar'#305
      ImageIndex = 70
      OnExecute = actset_ch_grupExecute
    end
    object actset_ch_hesap_plani: TAction
      Category = 'CariHesap'
      Caption = 'Hesap Planlar'#305
      ImageIndex = 76
      OnExecute = actset_ch_hesap_planiExecute
    end
    object actset_ch_hesap_tipi: TAction
      Category = 'CariHesap'
      Caption = 'Hesap Tipleri'
      ImageIndex = 70
      OnExecute = actset_ch_hesap_tipiExecute
    end
    object actset_ch_firma_turu: TAction
      Category = 'CariHesap'
      Caption = 'M'#252'lkiyet Tipleri'
      ImageIndex = 70
      OnExecute = actset_ch_firma_turuExecute
    end
    object actset_ch_firma_tipi: TAction
      Category = 'CariHesap'
      Caption = #350'irket Tipleri'
      ImageIndex = 70
      OnExecute = actset_ch_firma_tipiExecute
    end
    object actacc_transfer_code: TAction
      Category = 'CariHesap'
      Caption = 'Transfer Kodlar'#305
      ImageIndex = 76
      OnExecute = actacc_transfer_codeExecute
    end
    object actset_prs_tasima_servisleri: TAction
      Category = 'Personel'
      Caption = 'Personel Ta'#351#305'ma Servisleri'
      ImageIndex = 98
      OnExecute = actset_prs_tasima_servisleriExecute
    end
    object actsys_language: TAction
      Category = 'System'
      Caption = 'Language'
      ImageIndex = 72
      OnExecute = actsys_languageExecute
    end
    object actsys_decimal_place: TAction
      Category = 'System'
      Caption = 'Decimal Place'
      ImageIndex = 96
      OnExecute = actsys_decimal_placeExecute
    end
    object actsys_permission_template: TAction
      Category = 'System'
      Caption = 'Permission Templates'
      ImageIndex = 81
      OnExecute = actsys_permission_templateExecute
    end
    object actsys_permission_template_right: TAction
      Category = 'System'
      Caption = 'Template Rights'
      ImageIndex = 81
      OnExecute = actsys_permission_template_rightExecute
    end
    object actsys_user_permission_template: TAction
      Category = 'System'
      Caption = 'User Permission Templates'
      ImageIndex = 64
      OnExecute = actsys_user_permission_templateExecute
    end
    object actsys_menu: TAction
      Category = 'System'
      Caption = 'Menu Screens'
      ImageIndex = 64
      OnExecute = actsys_menuExecute
    end
    object actsys_audit_log: TAction
      Category = 'System'
      Caption = 'Audit Log'
      ImageIndex = 64
      OnExecute = actsys_audit_logExecute
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
      ImageIndex = 76
      object mnisys_refresh_permissions: TMenuItem
        Action = actsys_refresh_permissions
      end
      object mnisys_refresh_permissions_sep: TMenuItem
        Caption = '-'
      end
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
      object mnisys_grid_filter: TMenuItem
        Action = actsys_grid_filter
      end
      object mnisys_grid_sort: TMenuItem
        Action = actsys_grid_sort
      end
      object mniN10: TMenuItem
        Caption = '-'
      end
      object mnisys_resource_group: TMenuItem
        Action = actsys_permission_group
      end
      object mnisys_resource: TMenuItem
        Action = actsys_permission
      end
      object mnisys_permission_template: TMenuItem
        Action = actsys_permission_template
      end
      object mnisys_permission_template_right: TMenuItem
        Action = actsys_permission_template_right
      end
      object mnisys_user_permission_template: TMenuItem
        Action = actsys_user_permission_template
      end
      object mnisys_audit_log: TMenuItem
        Action = actsys_audit_log
      end
      object mniSystemSubSettings: TMenuItem
        Caption = 'Ayarlar'
        object mnisys_region: TMenuItem
          Action = actsys_region
        end
        object mnisys_country: TMenuItem
          Action = actsys_country
        end
        object mnisys_city: TMenuItem
          Action = actsys_city
        end
        object mniN2: TMenuItem
          Caption = '-'
        end
        object mnisys_decimal_place: TMenuItem
          Action = actsys_decimal_place
        end
        object mniN7: TMenuItem
          Caption = '-'
        end
        object mnisys_uom_type: TMenuItem
          Action = actsys_unit_type
        end
        object mnisys_uom: TMenuItem
          Action = actsys_unit
        end
        object mnisys_currency: TMenuItem
          Action = actsys_currency
        end
        object mniN1: TMenuItem
          Caption = '-'
        end
        object mnisys_language: TMenuItem
          Action = actsys_language
        end
        object mnisys_menu: TMenuItem
          Action = actsys_menu
        end
      end
    end
    object mnimenu_purchase: TMenuItem
      Caption = 'Al'#305'mlar'
      ImageIndex = 88
      object mnipur_requests: TMenuItem
        Action = actpur_requests
      end
      object mnipur_request_lines: TMenuItem
        Action = actpur_request_lines
      end
      object mnipur_sep1: TMenuItem
        Caption = '-'
      end
      object mnipur_orders: TMenuItem
        Action = actpur_orders
      end
      object mnipur_order_lines: TMenuItem
        Action = actpur_order_lines
      end
      object mnipur_sep2: TMenuItem
        Caption = '-'
      end
      object mnipur_receipts: TMenuItem
        Action = actpur_receipts
      end
      object mnipur_receipt_lines: TMenuItem
        Action = actpur_receipt_lines
      end
      object mnipur_sep3: TMenuItem
        Caption = '-'
      end
      object mnipur_invoices: TMenuItem
        Action = actpur_invoices
      end
      object mnipur_invoice_lines: TMenuItem
        Action = actpur_invoice_lines
      end
    end
    object mnimenu_sales: TMenuItem
      Caption = 'Sat'#305#351'lar'
      ImageIndex = 93
      object mnisls_offers: TMenuItem
        Action = actsls_offers
      end
      object mnisls_sep1: TMenuItem
        Caption = '-'
      end
      object mnisls_orders: TMenuItem
        Action = actsls_orders
      end
      object mnisls_sep2: TMenuItem
        Caption = '-'
      end
      object mnisls_dispatches: TMenuItem
        Action = actsls_dispatches
      end
      object mnisls_sep3: TMenuItem
        Caption = '-'
      end
      object mnisls_invoices: TMenuItem
        Action = actsls_invoices
      end
      object mnisls_sep4: TMenuItem
        Caption = '-'
      end
      object mnisls_diibs: TMenuItem
        Action = actsls_diibs
      end
      object mnisls_diib_lines: TMenuItem
        Action = actsls_diib_lines
      end
      object mnisls_einv_settings: TMenuItem
        Caption = 'e-Belge Ayarlar'#305
        object mnisls_einv_profiles: TMenuItem
          Action = actsls_einv_profiles
        end
        object mnisls_einv_invoice_types: TMenuItem
          Action = actsls_einv_invoice_types
        end
        object mnisls_einv_tax_exemptions: TMenuItem
          Action = actsls_einv_tax_exemptions
        end
        object mnisls_einv_tax_types: TMenuItem
          Action = actsls_einv_tax_types
        end
        object mnisls_einv_withholdings: TMenuItem
          Action = actsls_einv_withholdings
        end
        object mnisls_einv_delivery_terms: TMenuItem
          Action = actsls_einv_delivery_terms
        end
        object mnisls_einv_transport_modes: TMenuItem
          Action = actsls_einv_transport_modes
        end
        object mnisls_einv_packaging_types: TMenuItem
          Action = actsls_einv_packaging_types
        end
        object mnisls_einv_payment_means: TMenuItem
          Action = actsls_einv_payment_means
        end
        object mnisls_einv_series: TMenuItem
          Action = actsls_einv_series
        end
      end
    end
    object mnimenu_accounting: TMenuItem
      Caption = 'Muhasebe'
      ImageIndex = 69
      object mniacc_account: TMenuItem
        Action = actch_hesap_karti
      end
      object mniacc_account_intermediate: TMenuItem
        Action = actch_hesap_karti_ara
      end
      object mniacc_account_transactions: TMenuItem
        Action = actacc_account_transactions
      end
      object mniacc_bank: TMenuItem
        Action = actch_bankalar
      end
      object mniacc_bank_branch: TMenuItem
        Action = actch_banka_subeleri
      end
      object mniacc_exchange_rate: TMenuItem
        Action = actacc_exchange_rate
      end
      object mniAccountingSubSettings: TMenuItem
        Caption = 'Ayarlar'
        object mniset_acc_vat_rate: TMenuItem
          Action = actset_ch_vergi_orani
        end
        object mniacc_account_plan: TMenuItem
          Action = actset_ch_hesap_plani
        end
        object mniacc_group: TMenuItem
          Action = actset_ch_grup
        end
        object mniacc_region: TMenuItem
          Action = actch_bolge
        end
        object mniacc_account_type: TMenuItem
          Action = actset_ch_hesap_tipi
        end
        object mniacc_ownership_type: TMenuItem
          Action = actset_ch_firma_turu
        end
        object mniacc_company_legal_form: TMenuItem
          Action = actset_ch_firma_tipi
        end
        object mniacc_transfer_code: TMenuItem
          Action = actacc_transfer_code
        end
      end
    end
    object mnimenu_stock: TMenuItem
      Caption = 'Stoklar'
      ImageIndex = 83
      object mnistk_inventory: TMenuItem
        Action = actstk_stok_kartlari
      end
      object mnistk_transaction: TMenuItem
        Action = actstk_hareketler
      end
      object mnistk_inventory_summary: TMenuItem
        Action = actstk_stok_karti_ozetleri
      end
      object mniStockSubSettings: TMenuItem
        Caption = 'Ayarlar'
        object mnistk_warehouse: TMenuItem
          Action = actstk_ambarlar
        end
        object mnistk_group: TMenuItem
          Action = actstk_gruplar
        end
        object mnistk_product_type: TMenuItem
          Action = actstk_product_types
        end
        object mnistk_kind_family: TMenuItem
          Action = actstk_kind_families
        end
        object mnistk_kind_property: TMenuItem
          Action = actstk_cins_ozellikleri
        end
        object mnistk_gtips: TMenuItem
          Action = actstk_gtips
        end
      end
    end
    object mnimenu_production: TMenuItem
      Caption = #220'retim'
      ImageIndex = 66
      object mniprd_bom: TMenuItem
        Action = actprd_bom
      end
      object mniprd_labour: TMenuItem
        Action = actprd_labour
      end
      object mniprd_packet_raw: TMenuItem
        Action = actprd_packet_raw
      end
      object mniprd_packet_labour: TMenuItem
        Action = actprd_packet_labour
      end
    end
    object mnimenu_finance: TMenuItem
      Caption = 'Finans'
      ImageIndex = 68
      object mnifin_customer_cheques: TMenuItem
        Action = actfin_customer_cheques
      end
      object mnifin_own_cheques: TMenuItem
        Action = actfin_own_cheques
      end
      object mnifin_customer_notes: TMenuItem
        Action = actfin_customer_notes
      end
      object mnifin_debit_notes: TMenuItem
        Action = actfin_debit_notes
      end
      object mnifin_cheque_notes: TMenuItem
        Action = actfin_cheque_notes
      end
      object mnifin_cheque_note_transactions: TMenuItem
        Action = actfin_cheque_note_transactions
      end
      object mnifin_sep1: TMenuItem
        Caption = '-'
      end
      object mnifin_credit_cards: TMenuItem
        Action = actfin_credit_cards
      end
      object mnifin_credit_card_transactions: TMenuItem
        Action = actfin_credit_card_transactions
      end
      object mnifin_sep2: TMenuItem
        Caption = '-'
      end
      object mnifin_pos_terminals: TMenuItem
        Action = actfin_pos_terminals
      end
      object mnifin_pos_transactions: TMenuItem
        Action = actfin_pos_transactions
      end
      object mnifin_sep3: TMenuItem
        Caption = '-'
      end
      object mnifin_money_accounts: TMenuItem
        Action = actfin_money_accounts
      end
      object mnifin_money_transactions: TMenuItem
        Action = actfin_money_transactions
      end
      object mnifin_money_ledger: TMenuItem
        Action = actfin_money_ledger
      end
      object mnifin_sep5: TMenuItem
        Caption = '-'
      end
      object mnifin_company_bank_accounts: TMenuItem
        Action = actfin_company_bank_accounts
      end
    end
    object mnimenu_employee: TMenuItem
      Caption = 'Personel'
      ImageIndex = 14
      object mniprs_persons: TMenuItem
        Action = actprs_personeller
      end
      object mniprs_driver_licences: TMenuItem
        Action = actprs_ehliyetler
      end
      object mniprs_languages: TMenuItem
        Action = actprs_lisan_bilgileri
      end
      object mniEmployeeSubSettings: TMenuItem
        Caption = 'Ayarlar'
        ImageIndex = 76
        object mniset_prs_departments: TMenuItem
          Action = actset_prs_bolumler
        end
        object mniset_prs_units: TMenuItem
          Action = actset_prs_birimler
        end
        object mniset_prs_tasks: TMenuItem
          Action = actset_prs_gorevler
        end
        object mniset_prs_driver_licences: TMenuItem
          Action = actset_prs_ehliyetler
        end
        object mniset_prs_languages: TMenuItem
          Action = actset_prs_lisanlar
        end
        object mniset_prs_person_types: TMenuItem
          Action = actset_prs_personel_tipleri
        end
        object mniset_prs_shuttle_services: TMenuItem
          Action = actset_prs_tasima_servisleri
        end
      end
    end
    object mnimenu_language: TMenuItem
      Caption = 'Lisan / Language'
      ImageIndex = 35
    end
    object mnimenu_about: TMenuItem
      Caption = 'Hakk'#305'nda'
      ImageIndex = 34
      object mnisys_about: TMenuItem
        Action = actsys_about
        Caption = 'Hakk'#305'nda'
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mnisys_update_password: TMenuItem
        Action = actsys_update_password
        Caption = #350'ifre De'#287'i'#351'tir'
      end
      object mnisys_database_status: TMenuItem
        Action = actsys_database_status
        Caption = 'Veri Taban'#305' Monitor'
      end
      object mnisys_do_database_backup: TMenuItem
        Action = actsys_do_database_backup
        Caption = 'Veri Taban'#305' Yedek'
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnisys_update: TMenuItem
        Action = actsys_update
        Caption = 'G'#252'ncelleme'
      end
    end
  end
end

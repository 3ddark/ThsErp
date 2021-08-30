inherited frmMain: TfrmMain
  ActiveControl = PageControl1
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Main'
  ClientHeight = 496
  ClientWidth = 741
  Constraints.MinHeight = 300
  Constraints.MinWidth = 400
  DefaultMonitor = dmDesktop
  ParentFont = True
  Position = poScreenCenter
  Scaled = False
  OnActivate = FormActivate
  ExplicitWidth = 747
  ExplicitHeight = 525
  PixelsPerInch = 96
  TextHeight = 13
  object SV: TSplitView [0]
    Left = 0
    Top = 40
    Width = 250
    Height = 406
    Color = clBlack
    DisplayMode = svmOverlay
    OpenedWidth = 250
    Placement = svpLeft
    TabOrder = 1
    object catMenuItems: TCategoryButtons
      Left = 0
      Top = 0
      Width = 250
      Height = 406
      Align = alClient
      BackgroundGradientColor = 16776176
      BorderStyle = bsNone
      ButtonFlow = cbfVertical
      ButtonHeight = 32
      ButtonWidth = 200
      ButtonOptions = [boFullSize, boShowCaptions, boBoldCaptions, boUsePlusMinus, boCaptionOnlyBorder]
      Categories = <
        item
          Caption = 'Sistem Ayarlar'#305' [1, 2]'
          Color = 16771818
          Collapsed = True
          GradientColor = 16776176
          Items = <
            item
              Action = actsys_uygulama_ayari
            end
            item
              Action = actsys_uygulama_ayari_diger
            end
            item
              Action = actsys_kullanici
            end
            item
              Action = actsys_erisim_hakki
            end
            item
              Action = actsys_kaynak_grubu
            end
            item
              Action = actsys_kaynak
            end
            item
              Action = actsys_kalite_form_tipi
            end
            item
              Action = actsys_lisan
            end
            item
              Action = actsys_lisan_gui_icerik
            end
            item
              Action = actsys_lisan_data_icerik
            end
            item
              Action = actsys_grid_kolon
            end
            item
              Action = actsys_grid_filtre_siralama
            end
            item
              Caption = 'DBGrid S'#252'tun Alt '#214'zetleri'
              ImageIndex = 59
            end
            item
              Caption = 'Kullan'#305'c'#305' IP Adres '#304'stisnalar'#305
              ImageIndex = 83
            end
            item
              Action = actsys_database_durum
            end
            item
              Action = actmhs_doviz_kuru
            end
            item
              Action = actsys_kaynak_grubu
            end
            item
              Action = actsys_kaynak
            end
            item
              Action = actsys_mukellef_tipi
            end
            item
              Action = actsys_kalite_form_tipi
            end
            item
              Action = actsys_ay
            end
            item
              Action = actsys_guın
            end
            item
              Caption = 'Grid Kolon Say'#305'sal Renkleri'
              ImageIndex = 33
            end
            item
              Caption = 'Grid Kolon Y'#252'zdelik Renkleri'
              ImageIndex = 33
            end
            item
              Caption = '===================='
            end
            item
              Action = actsys_mahalle
            end
            item
              Action = actsys_semt
            end
            item
              Action = actsys_ilce
            end
            item
              Action = actsys_sehir
            end
            item
              Action = actsys_bolge
            end
            item
              Action = actsys_ulke
            end
            item
              Caption = 'Ondal'#305'k Haneler'
              ImageIndex = 66
            end
            item
              Action = actsys_para_birimleri
            end
            item
              Action = actsys_olcu_birimi_tipleri
            end
            item
              Action = actsys_olcu_birimleri
            end>
        end
        item
          Caption = 'Personel Bilgisi [1020, 1021]'
          Color = 15400959
          Collapsed = True
          Items = <
            item
              Action = actset_prs_askerlik_durumu
            end
            item
              Action = actset_prs_ayrilma_nedeni
            end
            item
              Action = actset_prs_ayrilma_tipi
            end
            item
              Action = actset_prs_birim
            end
            item
              Action = actset_prs_bolum
            end
            item
              Action = actset_prs_cinsiyet
            end
            item
              Action = actset_prs_egitim_seviyesi
            end
            item
              Action = actset_prs_ehliyet
            end
            item
              Action = actset_prs_gecis_sistemi_karti
            end
            item
              Action = actset_prs_gorev
            end
            item
              Action = actset_prs_lisan
            end
            item
              Action = actset_prs_lisan_seviyesi
            end
            item
              Action = actset_prs_medeni_durum
            end
            item
              Action = actset_prs_mektup_tipi
            end
            item
              Action = actset_prs_personel_tipi
            end
            item
              Action = actset_prs_rapor_tipi
            end
            item
              Action = actset_prs_servis_araci
            end
            item
              Action = actset_prs_src_tipi
            end
            item
              Action = actset_prs_tatil_tipi
            end
            item
              Action = actset_prs_yeterlilik_belgesi
            end
            item
              Caption = '==============='
            end
            item
              Action = actprs_personel
            end>
        end
        item
          Caption = 'Stok Kart'#305' [1040, 1041]'
          Color = 16771839
          Collapsed = True
          Items = <
            item
              Action = actset_stk_urun_tipi
            end
            item
              Caption = '============================'
            end
            item
              Action = actstk_stok_grubu
            end
            item
              Action = actstk_cins_ozelligi
            end
            item
              Action = actstk_stok_ambar
            end>
        end
        item
          Caption = 'Hesap Kart'#305' [1030, 1031]'
          Color = 16771839
          Collapsed = True
          Items = <
            item
              Action = actset_ch_firma_tipi
            end
            item
              Action = actset_ch_firma_turu
            end
            item
              Action = actset_ch_grup
            end
            item
              Action = actset_ch_hesap_plani
            end
            item
              Action = actset_ch_hesap_tipi
            end
            item
              Action = actset_ch_vergi_orani
            end
            item
              Caption = '==============='
            end
            item
              Action = actch_banka
            end
            item
              Action = actch_banka_subesi
            end
            item
              Action = actch_bolge
            end
            item
              Action = actch_hesap_karti
            end
            item
              Action = actch_hesap_karti_ara
            end>
        end
        item
          Caption = 'Bilgi Bankas'#305' [6520, 6521]'
          Color = 15400959
          Collapsed = True
          Items = <
            item
              Action = actset_bbk_calisma_durumu
            end
            item
              Action = actset_bbk_finans_durumu
            end
            item
              Action = actset_bbk_firma_tipi
            end
            item
              Caption = '==============='
            end
            item
              Action = actbbk_kayit
            end>
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      HotButtonColor = 12477460
      Images = dm.il16
      RegularButtonColor = clNone
      SelectedButtonColor = clNone
      TabOrder = 0
    end
  end
  object pnlToolbar: TPanel [1]
    Left = 0
    Top = 0
    Width = 741
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Color = 12477460
    ParentBackground = False
    TabOrder = 0
    object imgMenu: TImage
      AlignWithMargins = True
      Left = 9
      Top = 4
      Width = 32
      Height = 32
      Cursor = crHandPoint
      Margins.Left = 9
      Margins.Top = 4
      Margins.Right = 9
      Margins.Bottom = 4
      Align = alLeft
      Picture.Data = {
        0954506E67496D61676589504E470D0A1A0A0000000D49484452000000200000
        00200806000000737A7AF40000002B744558744372656174696F6E2054696D65
        0053756E20322041756720323031352031373A30353A3430202D30363030AB9D
        78EE0000000774494D4507DF0802160936B3167602000000097048597300002E
        2300002E230178A53F760000000467414D410000B18F0BFC61050000003B4944
        415478DAEDD3310100200C0341EA5F3454020BA1C3BD81DC925A9F2B00809180
        DD3D19EB00AE00C9000066BE00201900C0CC1700240300003859BE2421B37CDF
        370000000049454E44AE426082}
      Stretch = True
      OnClick = imgMenuClick
      ExplicitLeft = 10
      ExplicitTop = 10
    end
    object lblTitle: TLabel
      AlignWithMargins = True
      Left = 58
      Top = 2
      Width = 207
      Height = 36
      Margins.Left = 8
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alLeft
      Caption = 'Ths Erp Uygulamas'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      ExplicitHeight = 25
    end
    object tlbMain: TToolBar
      Left = 655
      Top = 0
      Width = 86
      Height = 40
      Align = alRight
      AutoSize = True
      ButtonHeight = 38
      ButtonWidth = 86
      Caption = 'tlbMain'
      Images = dm.il32
      List = True
      ShowCaptions = True
      TabOrder = 0
      object btnabout: TToolButton
        Left = 0
        Top = 0
        Caption = 'Hakk'#305'nda'
        DropdownMenu = pmAbout
        EnableDropdown = True
        ImageIndex = 34
        Indeterminate = True
      end
    end
  end
  inherited pnlBottom: TPanel [2]
    Top = 448
    Width = 737
    Color = clBtnFace
    ParentBackground = False
    TabOrder = 4
    ExplicitTop = 448
    ExplicitWidth = 737
    inherited btnAccept: TButton
      Left = 528
      TabOrder = 2
      ExplicitLeft = 528
    end
    inherited btnClose: TButton
      Left = 632
      TabOrder = 3
      ExplicitLeft = 632
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar [3]
    Top = 478
    Width = 741
    ExplicitTop = 478
    ExplicitWidth = 741
  end
  inherited pnlMain: TPanel [4]
    Top = 42
    Width = 737
    Height = 404
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitTop = 42
    ExplicitWidth = 737
    ExplicitHeight = 404
    object pb1: TProgressBar
      Left = 0
      Top = 378
      Width = 737
      Height = 26
      Align = alBottom
      DoubleBuffered = True
      ParentDoubleBuffered = False
      Smooth = True
      TabOrder = 1
    end
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 737
      Height = 378
      ActivePage = tsGenel
      Align = alClient
      MultiLine = True
      OwnerDraw = True
      TabOrder = 0
      object tsGenel: TTabSheet
        Caption = 'Genel'
        object btnbbk_kayit: TButton
          Left = 2
          Top = 228
          Width = 150
          Height = 36
          Action = actbbk_kayit
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
        object btnutd_dokuman: TButton
          Left = 2
          Top = 186
          Width = 150
          Height = 36
          Action = actutd_dokuman
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
      end
      object tssatis: TTabSheet
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
          Action = actsat_teklif
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
        object btnsat_siparis: TButton
          Left = 158
          Top = 2
          Width = 150
          Height = 36
          Action = actsat_siparis
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
        object btnsat_teklif_rapor: TButton
          Left = 2
          Top = 44
          Width = 150
          Height = 36
          Action = actsat_teklif_rapor
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
        object btnsat_siparis_rapor: TButton
          Left = 158
          Top = 44
          Width = 150
          Height = 36
          Action = actsat_siparis_rapor
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
      end
      object tsstok: TTabSheet
        Caption = 'Stoklar'
        ImageIndex = 3
        object btnstk_stok_karti: TButton
          Left = 2
          Top = 2
          Width = 150
          Height = 36
          Action = actstk_stok_karti
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
          Action = actstk_cins_ozelligi
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
          Action = actstk_stok_ambar
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 3
          Visible = False
          WordWrap = True
        end
        object btnstk_stok_grubu: TButton
          Left = 158
          Top = 86
          Width = 150
          Height = 36
          Action = actstk_stok_grubu
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
        object btnstk_stok_hareketi: TButton
          Left = 158
          Top = 128
          Width = 150
          Height = 36
          Action = actstk_stok_hareketi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 5
          Visible = False
          WordWrap = True
        end
        object btnset_stk_urun_tipi: TButton
          Left = 318
          Top = 2
          Width = 150
          Height = 36
          Action = actset_stk_urun_tipi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 2
          Visible = False
          WordWrap = True
        end
      end
      object tsch: TTabSheet
        Caption = 'Hesaplar'
        ImageIndex = 4
        object btnch_hesap_karti: TButton
          Left = 2
          Top = 170
          Width = 150
          Height = 36
          Action = actch_hesap_karti
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 6
        end
        object btnch_hesap_karti_ara: TButton
          Left = 2
          Top = 128
          Width = 150
          Height = 36
          Action = actch_hesap_karti_ara
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
        object btnch_banka: TButton
          Left = 2
          Top = 44
          Width = 150
          Height = 36
          Action = actch_banka
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
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
          Action = actch_banka_subesi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
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
          Action = actset_ch_grup
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 3
        end
        object btnset_ch_hesap_plani: TButton
          Left = 160
          Top = 128
          Width = 150
          Height = 36
          Action = actset_ch_hesap_plani
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 5
          Visible = False
        end
        object btnset_ch_vergi_orani: TButton
          Left = 160
          Top = 212
          Width = 150
          Height = 36
          Action = actset_ch_vergi_orani
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
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
          Action = actch_bolge
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 0
        end
      end
      object tspersonel: TTabSheet
        Caption = 'Personel'
        ImageIndex = 7
        object btnprs_personel: TButton
          Left = 2
          Top = 2
          Width = 150
          Height = 36
          Action = actprs_personel
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
        object btnset_prs_bolum: TButton
          Left = 160
          Top = 2
          Width = 150
          Height = 36
          Action = actset_prs_bolum
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
        object btnset_prs_birim: TButton
          Left = 160
          Top = 44
          Width = 150
          Height = 36
          Action = actset_prs_birim
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
        object btnset_prs_gorev: TButton
          Left = 160
          Top = 86
          Width = 150
          Height = 36
          Action = actset_prs_gorev
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 7
          WordWrap = True
        end
        object btnset_prs_personel_tipi: TButton
          Left = 160
          Top = 128
          Width = 150
          Height = 36
          Action = actset_prs_personel_tipi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 9
          Visible = False
          WordWrap = True
        end
        object btnset_prs_cinsiyet: TButton
          Left = 160
          Top = 170
          Width = 150
          Height = 36
          Action = actset_prs_cinsiyet
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 10
          Visible = False
          WordWrap = True
        end
        object btnset_prs_medeni_durum: TButton
          Left = 160
          Top = 212
          Width = 150
          Height = 36
          Action = actset_prs_medeni_durum
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 13
          Visible = False
          WordWrap = True
        end
        object btnset_prs_askerlik_durumu: TButton
          Left = 160
          Top = 254
          Width = 150
          Height = 36
          Action = actset_prs_askerlik_durumu
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 15
          Visible = False
          WordWrap = True
        end
        object btnset_prs_servis_araci: TButton
          Left = 160
          Top = 296
          Width = 150
          Height = 36
          Action = actset_prs_servis_araci
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 18
          WordWrap = True
        end
        object btnset_prs_lisan: TButton
          Left = 318
          Top = 2
          Width = 150
          Height = 36
          Action = actset_prs_lisan
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
        object btnset_prs_lisan_seviyesi: TButton
          Left = 318
          Top = 44
          Width = 150
          Height = 36
          Action = actset_prs_lisan_seviyesi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 5
          Visible = False
          WordWrap = True
        end
        object btnset_prs_yeterlilik_belgesi: TButton
          Left = 318
          Top = 170
          Width = 150
          Height = 36
          Action = actset_prs_yeterlilik_belgesi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 11
          WordWrap = True
        end
        object btnset_prs_mektup_tipi: TButton
          Left = 318
          Top = 212
          Width = 150
          Height = 36
          Action = actset_prs_mektup_tipi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 14
          WordWrap = True
        end
        object btnset_prs_egitim_seviyesi: TButton
          Left = 318
          Top = 254
          Width = 150
          Height = 36
          Action = actset_prs_egitim_seviyesi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 16
          Visible = False
          WordWrap = True
        end
        object btnset_prs_ehliyet: TButton
          Left = 318
          Top = 296
          Width = 150
          Height = 36
          Action = actset_prs_ehliyet
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 19
          WordWrap = True
        end
        object btnset_prs_ayrilma_nedeni: TButton
          Left = 476
          Top = 2
          Width = 150
          Height = 36
          Action = actset_prs_ayrilma_nedeni
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
        object btnset_prs_ayrilma_tipi: TButton
          Left = 476
          Top = 44
          Width = 150
          Height = 36
          Action = actset_prs_ayrilma_tipi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 6
          WordWrap = True
        end
        object btnset_prs_gecis_sistemi_karti: TButton
          Left = 476
          Top = 86
          Width = 150
          Height = 36
          Action = actset_prs_gecis_sistemi_karti
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 8
          WordWrap = True
        end
        object btnset_prs_rapor_tipi: TButton
          Left = 476
          Top = 170
          Width = 150
          Height = 36
          Action = actset_prs_rapor_tipi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 12
          WordWrap = True
        end
        object btnset_prs_src_tipi: TButton
          Left = 476
          Top = 254
          Width = 150
          Height = 36
          Action = actset_prs_src_tipi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 17
          WordWrap = True
        end
        object btnset_prs_tatil_tipi: TButton
          Left = 476
          Top = 296
          Width = 150
          Height = 36
          Action = actset_prs_tatil_tipi
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 20
          WordWrap = True
        end
      end
      object tsrecete: TTabSheet
        Caption = 'Re'#231'eteler'
        ImageIndex = 5
        object btnrct_recete: TButton
          Left = 2
          Top = 2
          Width = 150
          Height = 36
          Action = actrct_recete
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
        object btnrct_iscilik_gideri: TButton
          Left = 158
          Top = 2
          Width = 150
          Height = 36
          Action = actrct_iscilik_gideri
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
        object btnrct_paket_hammadde: TButton
          Left = 158
          Top = 44
          Width = 150
          Height = 36
          Action = actrct_paket_hammadde
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
      object tsmhs: TTabSheet
        Caption = 'Muhasebe'
        ImageIndex = 6
        object btnmhs_doviz_kuru: TButton
          Left = 326
          Top = 10
          Width = 150
          Height = 36
          Action = actmhs_doviz_kuru
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          Images = dm.il32
          ParentFont = False
          TabOrder = 0
        end
      end
    end
  end
  inherited AppEvntsBase: TApplicationEvents
    Left = 504
    Top = 240
  end
  object pmButtons: TPopupMenu
    Left = 520
    Top = 336
    object mniAddLanguageContent: TMenuItem
      Caption = 'Add Language Data'
      OnClick = mniAddLanguageContentClick
    end
  end
  object ActionListMain: TActionList
    Images = dm.il16
    OnExecute = ActionListMainExecute
    Left = 368
    Top = 344
    object actsys_ay: TAction
      Caption = 'Ay '#304'simleri'
      ImageIndex = 8
      OnExecute = actsys_ayExecute
    end
    object actsys_bolge: TAction
      Caption = 'B'#246'lgeler'
      ImageIndex = 68
      OnExecute = actsys_bolgeExecute
    end
    object actmhs_doviz_kuru: TAction
      Caption = 'D'#246'viz Kurlar'#305
      ImageIndex = 68
      OnExecute = actmhs_doviz_kuruExecute
    end
    object actsys_erisim_hakki: TAction
      Caption = 'Kullan'#305'c'#305' Eri'#351'im Haklar'#305
      ImageIndex = 62
      OnExecute = actsys_erisim_hakkiExecute
    end
    object actsys_grid_filtre_siralama: TAction
      Caption = 'DBGrid Varsay'#305'lan Filtre ve S'#305'ralama'
      ImageIndex = 26
      OnExecute = actsys_grid_filtre_siralamaExecute
    end
    object actsys_grid_kolon: TAction
      Caption = 'DBGrid S'#252'tun Geni'#351'lik ve S'#252'tun S'#305'ralar'#305
      ImageIndex = 12
      OnExecute = actsys_grid_kolonExecute
    end
    object actsys_guın: TAction
      Caption = 'G'#252'n '#304'simleri'
      ImageIndex = 85
      OnExecute = actsys_guınExecute
    end
    object actsys_kalite_form_no: TAction
      Caption = 'Kalite Form Numaralar'#305
      ImageIndex = 67
      OnExecute = actsys_kalite_form_noExecute
    end
    object actsys_kalite_form_tipi: TAction
      Caption = 'Kalite Form Tipleri'
      ImageIndex = 67
      OnExecute = actsys_kalite_form_tipiExecute
    end
    object actsys_kaynak: TAction
      Caption = 'Eri'#351'im Kaynaklar'#305
      ImageIndex = 81
      OnExecute = actsys_kaynakExecute
    end
    object actsys_kaynak_grubu: TAction
      Caption = 'Eri'#351'im Kaynak Gruplar'#305
      ImageIndex = 81
      OnExecute = actsys_kaynak_grubuExecute
    end
    object actsys_kullanici: TAction
      Caption = 'Kullan'#305'c'#305'lar'
      ImageIndex = 64
      OnExecute = actsys_kullaniciExecute
    end
    object actsys_lisan: TAction
      Caption = 'Uygulama Lisanlar'#305
      ImageIndex = 35
      OnExecute = actsys_lisanExecute
    end
    object actsys_lisan_data_icerik: TAction
      Caption = 'Lisana G'#246're Data '#304#231'erikleri'
      ImageIndex = 35
      OnExecute = actsys_lisan_data_icerikExecute
    end
    object actsys_lisan_gui_icerik: TAction
      Caption = 'Lisana G'#246're GUI '#304#231'erikleri'
      ImageIndex = 35
      OnExecute = actsys_lisan_gui_icerikExecute
    end
    object actsys_mukellef_tipi: TAction
      Caption = 'M'#252'kelle Tipleri'
      ImageIndex = 47
      OnExecute = actsys_mukellef_tipiExecute
    end
    object actsys_olcu_birimleri: TAction
      Caption = #214'l'#231#252' Birimleri'
      ImageIndex = 74
      OnExecute = actsys_olcu_birimleriExecute
    end
    object actsys_olcu_birimi_tipleri: TAction
      Caption = #214'l'#231#252' Birimi Tipleri'
      ImageIndex = 74
      OnExecute = actsys_olcu_birimi_tipleriExecute
    end
    object actsys_para_birimleri: TAction
      Caption = 'Para Birimleri'
      ImageIndex = 68
      OnExecute = actsys_para_birimleriExecute
    end
    object actsys_mahalle: TAction
      Caption = 'Mahalleler'
      ImageIndex = 71
      OnExecute = actsys_mahalleExecute
    end
    object actsys_semt: TAction
      Caption = 'Semtler'
      ImageIndex = 71
      OnExecute = actsys_semtExecute
    end
    object actsys_ilce: TAction
      Caption = #304'l'#231'eler'
      ImageIndex = 71
      OnExecute = actsys_ilceExecute
    end
    object actsys_sehir: TAction
      Caption = #350'ehirler'
      ImageIndex = 71
      OnExecute = actsys_sehirExecute
    end
    object actsys_sifre_guncelle: TAction
      Caption = #350'ifre De'#287'i'#351'tir'
      ImageIndex = 62
      OnExecute = actsys_sifre_guncelleExecute
    end
    object actsys_ulke: TAction
      Caption = #220'lkeler'
      ImageIndex = 72
      OnExecute = actsys_ulkeExecute
    end
    object actsys_uygulama_ayari: TAction
      Caption = 'Sistem Ayarlar'
      ImageIndex = 76
      OnExecute = actsys_uygulama_ayariExecute
    end
    object actsys_uygulama_ayari_diger: TAction
      Caption = 'Di'#287'er Sistem Ayarlar'#305
      ImageIndex = 76
      OnExecute = actsys_uygulama_ayari_digerExecute
    end
    object actsys_uygulama_guncelle: TAction
      Caption = 'G'#252'ncelle'
      ImageIndex = 3
      OnExecute = actsys_uygulama_guncelleExecute
    end
    object actsys_hakkinda: TAction
      Caption = 'Hakk'#305'nda'
      ImageIndex = 34
      OnExecute = actsys_hakkindaExecute
    end
    object actsys_database_durum: TAction
      Caption = 'Database Monitor'
      ImageIndex = 55
      OnExecute = actsys_database_durumExecute
    end
    object actx1: TAction
      Caption = 'actx1'
    end
    object actprs_personel: TAction
      Caption = 'Personel Bilgisi'
      ImageIndex = 64
      OnExecute = actprs_personelExecute
    end
    object actset_prs_askerlik_durumu: TAction
      Caption = 'Askerlik Durumlar'#305
      ImageIndex = 95
      OnExecute = actset_prs_askerlik_durumuExecute
    end
    object actset_prs_ayrilma_nedeni: TAction
      Caption = 'Ayr'#305'lma Nedenleri'
      ImageIndex = 70
      OnExecute = actset_prs_ayrilma_nedeniExecute
    end
    object actset_prs_ayrilma_tipi: TAction
      Caption = 'Ayr'#305'lma Tipleri'
      ImageIndex = 76
      OnExecute = actset_prs_ayrilma_nedeniExecute
    end
    object actset_prs_birim: TAction
      Caption = 'Birimler'
      ImageIndex = 76
      OnExecute = actset_prs_birimExecute
    end
    object actset_prs_bolum: TAction
      Caption = 'B'#246'l'#252'mler'
      ImageIndex = 76
      OnExecute = actset_prs_bolumExecute
    end
    object actset_prs_cinsiyet: TAction
      Caption = 'Cinsiyet'
      ImageIndex = 94
      OnExecute = actset_prs_cinsiyetExecute
    end
    object actset_prs_egitim_seviyesi: TAction
      Caption = 'E'#287'itim Seviyeleri'
      ImageIndex = 67
      OnExecute = actset_prs_egitim_seviyesiExecute
    end
    object actset_prs_ehliyet: TAction
      Caption = 'Ehliyetler'
      ImageIndex = 96
      OnExecute = actset_prs_ehliyetExecute
    end
    object actset_prs_gecis_sistemi_karti: TAction
      Caption = 'PDKS Kart'
      ImageIndex = 100
      OnExecute = actset_prs_gorevExecute
    end
    object actset_prs_gorev: TAction
      Caption = 'G'#246'revler'
      ImageIndex = 76
      OnExecute = actset_prs_gorevExecute
    end
    object actset_prs_lisan: TAction
      Caption = 'Lisanlar'
      ImageIndex = 35
      OnExecute = actset_prs_lisanExecute
    end
    object actset_prs_lisan_seviyesi: TAction
      Caption = 'Lisan Seviyesi'
      ImageIndex = 97
      OnExecute = actset_prs_lisan_seviyesiExecute
    end
    object actset_prs_medeni_durum: TAction
      Caption = 'Medeni Durumlar'
      ImageIndex = 76
      OnExecute = actset_prs_medeni_durumExecute
    end
    object actset_prs_mektup_tipi: TAction
      Caption = 'Mektup Tipleri'
      ImageIndex = 101
      OnExecute = actset_prs_mektup_tipiExecute
    end
    object actset_prs_personel_tipi: TAction
      Caption = 'Personel Tipleri'
      ImageIndex = 76
      OnExecute = actset_prs_personel_tipiExecute
    end
    object actset_prs_rapor_tipi: TAction
      Caption = 'Rapor Tipleri'
      ImageIndex = 102
      OnExecute = actset_prs_rapor_tipiExecute
    end
    object actset_prs_servis_araci: TAction
      Caption = 'Servis Ara'#231'lar'#305
      ImageIndex = 98
      OnExecute = actset_prs_servis_araciExecute
    end
    object actset_prs_src_tipi: TAction
      Caption = 'SRC Tipleri'
      ImageIndex = 76
      OnExecute = actset_prs_src_tipiExecute
    end
    object actset_prs_tatil_tipi: TAction
      Caption = 'Tatil Tipleri'
      ImageIndex = 99
      OnExecute = actset_prs_tatil_tipiExecute
    end
    object actset_prs_yeterlilik_belgesi: TAction
      Caption = 'Mesleki Yeterlilik Belgeleri'
      ImageIndex = 67
      OnExecute = actset_prs_yeterlilik_belgesiExecute
    end
    object actx2: TAction
      Caption = 'actx2'
    end
    object actch_banka: TAction
      Caption = 'Bankalar'
      ImageIndex = 69
      OnExecute = actch_bankaExecute
    end
    object actch_banka_subesi: TAction
      Caption = 'Banka '#350'ubeleri'
      ImageIndex = 69
      OnExecute = actch_banka_subesiExecute
    end
    object actch_bolge: TAction
      Caption = 'B'#246'lge'
      ImageIndex = 72
      OnExecute = actch_bolgeExecute
    end
    object actch_hesap_karti_ara: TAction
      Caption = 'Hesap Kart'#305' Ara Hesap'
      ImageIndex = 14
      OnExecute = actch_hesap_karti_araExecute
    end
    object actch_hesap_karti: TAction
      Caption = 'Hesap Kart'#305
      ImageIndex = 14
      OnExecute = actch_hesap_kartiExecute
    end
    object actset_ch_firma_tipi: TAction
      Caption = 'Firma Tipleri'
      ImageIndex = 76
      OnExecute = actset_ch_firma_tipiExecute
    end
    object actset_ch_firma_turu: TAction
      Caption = 'Firma T'#252'rleri'
      ImageIndex = 76
      OnExecute = actset_ch_firma_turuExecute
    end
    object actset_ch_grup: TAction
      Caption = 'Hesap Gruplar'#305
      ImageIndex = 70
      OnExecute = actset_ch_grupExecute
    end
    object actset_ch_hesap_plani: TAction
      Caption = 'Hesap Planlar'#305
      ImageIndex = 76
      OnExecute = actset_ch_hesap_planiExecute
    end
    object actset_ch_hesap_tipi: TAction
      Caption = 'Hesap Tipleri'
      ImageIndex = 76
      OnExecute = actset_ch_hesap_tipiExecute
    end
    object actset_ch_vergi_orani: TAction
      Caption = 'Vergi Oranlar'#305
      ImageIndex = 68
      OnExecute = actset_ch_vergi_oraniExecute
    end
    object actx3: TAction
      Caption = 'actx3'
    end
    object actset_stk_urun_tipi: TAction
      Caption = #220'r'#252'n Tipleri'
      ImageIndex = 76
      OnExecute = actset_stk_urun_tipiExecute
    end
    object actstk_cins_ozelligi: TAction
      Caption = 'Cins '#214'zellikleri'
      ImageIndex = 76
      OnExecute = actstk_cins_ozelligiExecute
    end
    object actstk_stok_ambar: TAction
      Caption = 'Ambarlar'
      ImageIndex = 73
      OnExecute = actstk_stok_ambarExecute
    end
    object actstk_stok_grubu: TAction
      Caption = 'Stok Gruplar'#305
      ImageIndex = 49
      OnExecute = actstk_stok_grubuExecute
    end
    object actstk_stok_hareketi: TAction
      Caption = 'Stok Hareketleri'
      ImageIndex = 57
      OnExecute = actstk_stok_hareketiExecute
    end
    object actstk_stok_karti: TAction
      Caption = 'Stok Kartlar'#305
      ImageIndex = 56
      OnExecute = actstk_stok_kartiExecute
    end
    object actx4: TAction
      Caption = 'actx4'
    end
    object actrct_recete: TAction
      Caption = 'Re'#231'eteler'
      ImageIndex = 66
      OnExecute = actrct_receteExecute
    end
    object actrct_iscilik_gideri: TAction
      Caption = #304#351#231'ilik Giderleri'
      ImageIndex = 76
      OnExecute = actrct_iscilik_gideriExecute
    end
    object actrct_paket_hammadde: TAction
      Caption = 'Paket Hammaddeler'
      ImageIndex = 76
      OnExecute = actrct_paket_hammaddeExecute
    end
    object actset_rct_iscilik_gider_tipi: TAction
      Caption = #304#351#231'ilik Gider Tipleri'
      ImageIndex = 76
      OnExecute = actset_rct_iscilik_gider_tipiExecute
    end
    object actx5: TAction
      Caption = 'actx5'
    end
    object actset_teklif_tipleri: TAction
      Caption = 'Teklif Tipleri'
      ImageIndex = 88
      OnExecute = actset_teklif_tipleriExecute
    end
    object actteklif_durumlari: TAction
      Caption = 'Teklif Durumlar'#305
      ImageIndex = 88
      OnExecute = actteklif_durumlariExecute
    end
    object actsat_teklif: TAction
      Caption = 'Teklifler'
      ImageIndex = 88
      OnExecute = actsat_teklifExecute
    end
    object actsat_teklif_rapor: TAction
      Caption = 'Teklif Rapor'
      ImageIndex = 9
    end
    object actx6: TAction
      Caption = 'actx6'
    end
    object actsat_siparis: TAction
      Caption = 'Sipari'#351'ler'
      ImageIndex = 86
      OnExecute = actsat_siparisExecute
    end
    object actsat_siparis_rapor: TAction
      Caption = 'Sipari'#351' Rapor'
      ImageIndex = 9
      OnExecute = actsat_siparis_raporExecute
    end
    object actx7: TAction
      Caption = 'actx7'
    end
    object actset_utd_dokuman_tipi: TAction
      Caption = 'UTD Dok'#252'man Tipi'
      ImageIndex = 76
      OnExecute = actset_utd_dokuman_tipiExecute
    end
    object actset_utd_dosya_uzantisi: TAction
      Caption = 'UTD Dosya Uzant'#305's'#305
      ImageIndex = 76
      OnExecute = actset_utd_dosya_uzantisiExecute
    end
    object actutd_dokuman: TAction
      Caption = 'UTD Dok'#252'manlar'
      ImageIndex = 16
      OnExecute = actutd_dokumanExecute
    end
    object actx8: TAction
      Caption = 'actx8'
    end
    object actset_bbk_calisma_durumu: TAction
      Caption = #199'al'#305#351'ma Durumu'
      ImageIndex = 93
      OnExecute = actset_bbk_calisma_durumuExecute
    end
    object actset_bbk_finans_durumu: TAction
      Caption = 'Finans Durumu'
      ImageIndex = 69
      OnExecute = actset_bbk_finans_durumuExecute
    end
    object actset_bbk_firma_tipi: TAction
      Caption = 'Firma Tipi'
      ImageIndex = 71
      OnExecute = actset_bbk_firma_tipiExecute
    end
    object actbbk_kayit: TAction
      Caption = 'Bilgi Bankas'#305
      ImageIndex = 18
      OnExecute = actbbk_kayitExecute
    end
    object actx9: TAction
      Caption = 'actx9'
    end
    object actquality_form_mail_recievers: TAction
      Caption = 'Kalite Form Mail Al'#305'c'#305'lar'#305
      ImageIndex = 30
      OnExecute = actquality_form_mail_recieversExecute
    end
    object acturun_kabul_red_nedenleri: TAction
      Caption = #220'r'#252'n Kabul-Red Nedenleri'
      ImageIndex = 82
      OnExecute = acturun_kabul_red_nedenleriExecute
    end
    object actodeme_baslangic_donemleri: TAction
      Caption = #214'deme Ba'#351'lang'#305#231' D'#246'nemleri'
      ImageIndex = 75
      OnExecute = actodeme_baslangic_donemleriExecute
    end
    object actset_efatura_fatura_tipi: TAction
      Caption = 'E-Fatura Fatura Tipi'
      ImageIndex = 89
      OnExecute = actset_efatura_fatura_tipiExecute
    end
    object actset_efatura_iletisim_kanali: TAction
      Caption = 'E-Fatura '#304'leti'#351'im Kanal'#305
      ImageIndex = 91
    end
    object actset_efatura_istisna_kodu: TAction
      Caption = 'E-Fatura '#304'stisna Kodu'
      ImageIndex = 34
      OnExecute = actset_efatura_istisna_koduExecute
    end
  end
  object pmAbout: TPopupMenu
    Images = dm.il16
    Left = 684
    object mniabout1: TMenuItem
      Action = actsys_hakkinda
    end
    object mniN5: TMenuItem
      Caption = '-'
    end
    object mnichange_password: TMenuItem
      Action = actsys_sifre_guncelle
    end
    object mniN6: TMenuItem
      Caption = '-'
    end
    object mniupdate_application: TMenuItem
      Action = actsys_uygulama_guncelle
    end
  end
  object tmrcheck_is_update_required: TTimer
    Enabled = False
    Interval = 60000
    OnTimer = tmrcheck_is_update_requiredTimer
    Left = 368
    Top = 280
  end
end

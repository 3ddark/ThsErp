inherited frmSysUygulamaAyari: TfrmSysUygulamaAyari
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem Uygulama Ayar'#305
  ClientHeight = 367
  ClientWidth = 698
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 704
  ExplicitHeight = 396
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 694
    Height = 315
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 694
    ExplicitHeight = 315
    inherited pgcMain: TPageControl
      Width = 692
      Height = 313
      ActivePage = tsDiger
      ExplicitWidth = 692
      ExplicitHeight = 313
      inherited tsMain: TTabSheet
        ExplicitWidth = 684
        ExplicitHeight = 285
        object lblunvan: TLabel
          Left = 81
          Top = 5
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
        object lbltel1: TLabel
          Left = 91
          Top = 28
          Width = 24
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tel1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltel2: TLabel
          Left = 91
          Top = 51
          Width = 24
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tel2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltel3: TLabel
          Left = 93
          Top = 74
          Width = 24
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tel3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltel4: TLabel
          Left = 93
          Top = 97
          Width = 24
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tel4'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltel5: TLabel
          Left = 93
          Top = 120
          Width = 24
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tel5'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfaks1: TLabel
          Left = 84
          Top = 143
          Width = 33
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Faks1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfaks2: TLabel
          Left = 84
          Top = 166
          Width = 33
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Faks2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object imglogo: TImage
          Left = 356
          Top = 25
          Width = 320
          Height = 240
          Anchors = [akTop, akRight]
          OnDblClick = imglogoDblClick
          ExplicitLeft = 360
        end
        object edtunvan: TEdit
          Left = 121
          Top = 2
          Width = 559
          Height = 21
          TabOrder = 0
        end
        object edttel1: TEdit
          Left = 121
          Top = 25
          Width = 136
          Height = 21
          TabOrder = 1
        end
        object edttel2: TEdit
          Left = 121
          Top = 48
          Width = 136
          Height = 21
          TabOrder = 2
        end
        object edttel3: TEdit
          Left = 121
          Top = 71
          Width = 136
          Height = 21
          TabOrder = 3
        end
        object edttel4: TEdit
          Left = 121
          Top = 94
          Width = 136
          Height = 21
          TabOrder = 4
        end
        object edttel5: TEdit
          Left = 121
          Top = 117
          Width = 136
          Height = 21
          TabOrder = 5
        end
        object edtfaks1: TEdit
          Left = 121
          Top = 140
          Width = 136
          Height = 21
          TabOrder = 6
        end
        object edtfaks2: TEdit
          Left = 121
          Top = 163
          Width = 136
          Height = 21
          TabOrder = 7
        end
      end
      object tsDiger: TTabSheet
        Caption = 'Di'#287'er'
        ImageIndex = 1
        object lblgrid_color_1: TLabel
          Left = 63
          Top = 6
          Width = 68
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grid Rengi 1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgrid_color_2: TLabel
          Left = 65
          Top = 28
          Width = 68
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grid Rengi 2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgrid_color_active: TLabel
          Left = 43
          Top = 50
          Width = 88
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grid Rengi Aktif'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcrypt_key: TLabel
          Left = 25
          Top = 72
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
        object lblform_rengi: TLabel
          Left = 69
          Top = 95
          Width = 64
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Form Rengi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldonem: TLabel
          Left = 93
          Top = 117
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
        object lbluygulama_lisan: TLabel
          Left = 72
          Top = 139
          Width = 59
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sistem Dili'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmail_host_name: TLabel
          Left = 370
          Top = 6
          Width = 103
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Sunucu Adres'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmail_host_user: TLabel
          Left = 336
          Top = 28
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
        object lblmail_host_pass: TLabel
          Left = 377
          Top = 50
          Width = 96
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Sunucu '#350'ifre'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmail_host_smtp_port: TLabel
          Left = 362
          Top = 72
          Width = 111
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Sunucu Port No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_kalite_form_no_kullan: TLabel
          Left = 308
          Top = 95
          Width = 163
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kalite Form No Kullan'#305'ls'#305'n m'#305'?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsms_service_provider: TLabel
          Left = 358
          Top = 161
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
        object lblsms_user: TLabel
          Left = 379
          Top = 183
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
        object lblsms_password: TLabel
          Left = 362
          Top = 205
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
        object lblsms_title: TLabel
          Left = 421
          Top = 227
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sms Title'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbluygulama_surum: TLabel
          Left = 34
          Top = 227
          Width = 97
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Uygulama S'#252'r'#252'm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtgrid_color_1: TEdit
          Left = 137
          Top = 3
          Width = 130
          Height = 21
          TabOrder = 0
          OnDblClick = edtgrid_color_1DblClick
          OnExit = edtgrid_color_1Exit
        end
        object edtgrid_color_2: TEdit
          Left = 137
          Top = 25
          Width = 130
          Height = 21
          TabOrder = 2
          OnDblClick = edtgrid_color_2DblClick
          OnExit = edtgrid_color_2Exit
        end
        object edtgrid_color_active: TEdit
          Left = 137
          Top = 47
          Width = 130
          Height = 21
          TabOrder = 4
          OnDblClick = edtgrid_color_activeDblClick
          OnExit = edtgrid_color_activeExit
        end
        object secrypt_key: TSpinEdit
          Left = 137
          Top = 69
          Width = 130
          Height = 22
          Hint = 
            #304'lk kurulum s'#305'ras'#305'nda de'#287'i'#351'tirin. Daha sonra de'#287'i'#351'tirmeyiniz. De' +
            #287'i'#351'tirme durumunda verileriniz bozulacakt'#305'r.'
          MaxLength = 5
          MaxValue = 65535
          MinValue = 0
          ParentShowHint = False
          ShowHint = True
          TabOrder = 6
          Value = 0
        end
        object edtform_rengi: TEdit
          Left = 137
          Top = 92
          Width = 130
          Height = 21
          TabOrder = 8
          OnDblClick = edtform_rengiDblClick
          OnExit = edtform_rengiExit
        end
        object edtdonem: TEdit
          Left = 137
          Top = 114
          Width = 130
          Height = 21
          TabOrder = 10
        end
        object edtmail_host_name: TEdit
          Left = 477
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtmail_host_user: TEdit
          Left = 477
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 3
        end
        object edtmail_host_pass: TEdit
          Left = 477
          Top = 47
          Width = 200
          Height = 21
          PasswordChar = '#'
          TabOrder = 5
        end
        object edtmail_host_smtp_port: TEdit
          Left = 477
          Top = 69
          Width = 200
          Height = 21
          TabOrder = 7
        end
        object chkis_kalite_form_no_kullan: TCheckBox
          Left = 477
          Top = 94
          Width = 130
          Height = 17
          TabOrder = 9
        end
        object edtuygulama_lisan: TEdit
          Left = 137
          Top = 136
          Width = 130
          Height = 21
          TabOrder = 11
        end
        object edtsms_service_provider: TEdit
          Left = 477
          Top = 158
          Width = 200
          Height = 21
          TabOrder = 12
        end
        object edtsms_user: TEdit
          Left = 477
          Top = 180
          Width = 200
          Height = 21
          TabOrder = 13
        end
        object edtsms_password: TEdit
          Left = 477
          Top = 202
          Width = 200
          Height = 21
          PasswordChar = '#'
          TabOrder = 14
        end
        object edtsms_title: TEdit
          Left = 477
          Top = 224
          Width = 200
          Height = 21
          TabOrder = 16
        end
        object edtuygulama_surum: TEdit
          Left = 137
          Top = 224
          Width = 130
          Height = 21
          TabOrder = 15
        end
      end
      object tsAdres: TTabSheet
        Caption = 'Adres'
        ImageIndex = 2
        object lblmukellef_tipi_id: TLabel
          Left = 46
          Top = 10
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
        object lblvergi_dairesi: TLabel
          Left = 46
          Top = 32
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
        object lblvergi_no: TLabel
          Left = 71
          Top = 54
          Width = 46
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Vergi No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmersis_no: TLabel
          Left = 63
          Top = 76
          Width = 54
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mersis No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblweb_site: TLabel
          Left = 58
          Top = 112
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
          Left = 429
          Top = 112
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
        object lblulke_id: TLabel
          Left = 92
          Top = 135
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
          Left = 444
          Top = 135
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
          Left = 96
          Top = 158
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
          Left = 429
          Top = 158
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
        object lblcadde: TLabel
          Left = 82
          Top = 181
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
        object lblsokak: TLabel
          Left = 438
          Top = 181
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
          Left = 93
          Top = 204
          Width = 24
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Bina'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkapi_no: TLabel
          Left = 432
          Top = 204
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
          Left = 54
          Top = 227
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
        object lblticaret_sicil_no: TLabel
          Left = 400
          Top = 76
          Width = 73
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ticari Sicil No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtmukellef_tipi_id: TEdit
          Left = 121
          Top = 7
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtvergi_dairesi: TEdit
          Left = 121
          Top = 29
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtvergi_no: TEdit
          Left = 121
          Top = 51
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object edtmersis_no: TEdit
          Left = 121
          Top = 73
          Width = 200
          Height = 21
          TabOrder = 3
        end
        object edtweb_site: TEdit
          Left = 121
          Top = 109
          Width = 200
          Height = 21
          TabOrder = 5
        end
        object edtemail: TEdit
          Left = 477
          Top = 109
          Width = 200
          Height = 21
          TabOrder = 6
        end
        object edtsehir_id: TEdit
          Left = 477
          Top = 132
          Width = 200
          Height = 21
          TabOrder = 8
        end
        object edtilce: TEdit
          Left = 121
          Top = 155
          Width = 200
          Height = 21
          TabOrder = 9
        end
        object edtmahalle: TEdit
          Left = 477
          Top = 155
          Width = 200
          Height = 21
          TabOrder = 10
        end
        object edtcadde: TEdit
          Left = 121
          Top = 178
          Width = 200
          Height = 21
          TabOrder = 11
        end
        object edtsokak: TEdit
          Left = 477
          Top = 178
          Width = 200
          Height = 21
          TabOrder = 12
        end
        object edtbina_adi: TEdit
          Left = 121
          Top = 201
          Width = 200
          Height = 21
          TabOrder = 13
        end
        object edtkapi_no: TEdit
          Left = 477
          Top = 201
          Width = 200
          Height = 21
          TabOrder = 14
        end
        object edtposta_kodu: TEdit
          Left = 121
          Top = 224
          Width = 200
          Height = 21
          TabOrder = 15
        end
        object edtulke_id: TEdit
          Left = 121
          Top = 132
          Width = 200
          Height = 21
          TabOrder = 7
        end
        object edtticaret_sicil_no: TEdit
          Left = 477
          Top = 73
          Width = 200
          Height = 21
          TabOrder = 4
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 319
    Width = 694
    ExplicitTop = 319
    ExplicitWidth = 694
    inherited btnAccept: TButton
      Left = 485
      TabOrder = 2
      ExplicitLeft = 485
    end
    inherited btnClose: TButton
      Left = 589
      TabOrder = 3
      ExplicitLeft = 589
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 349
    Width = 698
    ExplicitTop = 349
    ExplicitWidth = 698
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

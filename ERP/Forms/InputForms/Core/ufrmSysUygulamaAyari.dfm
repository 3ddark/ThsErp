inherited frmSysUygulamaAyari: TfrmSysUygulamaAyari
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'System Application Settings'
  ClientHeight = 323
  ClientWidth = 676
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 690
  ExplicitHeight = 358
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 676
    Height = 273
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 674
    ExplicitHeight = 269
    inherited pgcMain: TPageControl
      Width = 676
      Height = 273
      ExplicitWidth = 674
      ExplicitHeight = 269
      inherited tsMain: TTabSheet
        Caption = 'Main'
        ExplicitTop = 26
        ExplicitWidth = 668
        ExplicitHeight = 243
        object lbltitle: TLabel
          Left = 110
          Top = 6
          Width = 25
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Title'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblphone1: TLabel
          Left = 90
          Top = 29
          Width = 45
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Phone 1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblphone2: TLabel
          Left = 90
          Top = 52
          Width = 45
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Phone 2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblphone3: TLabel
          Left = 90
          Top = 75
          Width = 45
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Phone 3'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfax1: TLabel
          Left = 105
          Top = 98
          Width = 30
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Fax 1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfax2: TLabel
          Left = 105
          Top = 121
          Width = 30
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Fax 2'
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
        object edttitle: TEdit
          Left = 137
          Top = 2
          Width = 543
          Height = 23
          TabOrder = 0
        end
        object edtphone1: TEdit
          Left = 137
          Top = 25
          Width = 136
          Height = 23
          TabOrder = 1
        end
        object edtphone2: TEdit
          Left = 137
          Top = 48
          Width = 136
          Height = 23
          TabOrder = 2
        end
        object edtphone3: TEdit
          Left = 137
          Top = 71
          Width = 136
          Height = 23
          TabOrder = 3
        end
        object edtfax1: TEdit
          Left = 137
          Top = 94
          Width = 136
          Height = 23
          TabOrder = 4
        end
        object edtfax2: TEdit
          Left = 137
          Top = 117
          Width = 136
          Height = 23
          TabOrder = 5
        end
      end
      object tsaddress: TTabSheet
        Caption = 'Address'
        ImageIndex = 2
        object lbltax_administration: TLabel
          Left = 25
          Top = 32
          Width = 108
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tax Administration'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltax_number: TLabel
          Left = 65
          Top = 54
          Width = 68
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tax Number'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblweb_site: TLabel
          Left = 83
          Top = 122
          Width = 50
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Web Site'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemail: TLabel
          Left = 438
          Top = 122
          Width = 35
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'e-Mail'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcountry_id: TLabel
          Left = 88
          Top = 145
          Width = 45
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Country'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcity_id: TLabel
          Left = 451
          Top = 145
          Width = 22
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'City'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldistrict: TLabel
          Left = 92
          Top = 168
          Width = 41
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'District'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblneighborhood: TLabel
          Left = 395
          Top = 168
          Width = 78
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Neighborhood'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblstreet: TLabel
          Left = 437
          Top = 191
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Street'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblbuilding_name: TLabel
          Left = 54
          Top = 214
          Width = 79
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Building Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldoor_no: TLabel
          Left = 429
          Top = 214
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Door No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblpost_code: TLabel
          Left = 67
          Top = 237
          Width = 66
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Postal Code'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edttax_administration: TEdit
          Left = 137
          Top = 26
          Width = 200
          Height = 23
          TabOrder = 0
        end
        object edttax_number: TEdit
          Left = 137
          Top = 49
          Width = 200
          Height = 23
          TabOrder = 1
        end
        object edtweb_site: TEdit
          Left = 137
          Top = 118
          Width = 200
          Height = 23
          TabOrder = 2
        end
        object edtemail: TEdit
          Left = 477
          Top = 118
          Width = 200
          Height = 23
          TabOrder = 3
        end
        object edtcity_id: TEdit
          Left = 477
          Top = 141
          Width = 200
          Height = 23
          TabOrder = 5
        end
        object edtdistrict: TEdit
          Left = 137
          Top = 164
          Width = 200
          Height = 23
          TabOrder = 6
        end
        object edtneighborhood: TEdit
          Left = 477
          Top = 164
          Width = 200
          Height = 23
          TabOrder = 7
        end
        object edtstreet: TEdit
          Left = 477
          Top = 187
          Width = 200
          Height = 23
          TabOrder = 8
        end
        object edtbuilding_name: TEdit
          Left = 137
          Top = 210
          Width = 200
          Height = 23
          TabOrder = 9
        end
        object edtdoor_no: TEdit
          Left = 477
          Top = 210
          Width = 200
          Height = 23
          TabOrder = 10
        end
        object edtpost_code: TEdit
          Left = 137
          Top = 233
          Width = 200
          Height = 23
          TabOrder = 11
        end
        object edtcountry_id: TEdit
          Left = 137
          Top = 141
          Width = 200
          Height = 23
          TabOrder = 4
        end
      end
      object tsother: TTabSheet
        Caption = 'Other'
        ImageIndex = 1
        object lblgrid_color_1: TLabel
          Left = 70
          Top = 7
          Width = 65
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grid Color 1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgrid_color_2: TLabel
          Left = 70
          Top = 30
          Width = 65
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grid Color 2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgrid_color_active: TLabel
          Left = 41
          Top = 53
          Width = 94
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grid Color Active'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcrypt_key: TLabel
          Left = 80
          Top = 76
          Width = 55
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Crypt Key'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblperiod: TLabel
          Left = 99
          Top = 100
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Period'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblapp_language: TLabel
          Left = 14
          Top = 123
          Width = 121
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Application Language'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmail_host_name: TLabel
          Left = 388
          Top = 7
          Width = 87
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Host Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmail_host_user: TLabel
          Left = 362
          Top = 30
          Width = 113
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Host Username'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmail_host_pass: TLabel
          Left = 337
          Top = 53
          Width = 138
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Host User Password'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmail_host_smtp_port: TLabel
          Left = 379
          Top = 76
          Width = 96
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Host Port No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsms_service_provider: TLabel
          Left = 355
          Top = 162
          Width = 120
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'SMS Service Provider'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsms_user: TLabel
          Left = 390
          Top = 185
          Width = 85
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'SMS Username'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsms_password: TLabel
          Left = 365
          Top = 208
          Width = 110
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'SMS User Password'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsms_title: TLabel
          Left = 423
          Top = 231
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
        object lblapp_version: TLabel
          Left = 27
          Top = 231
          Width = 108
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Application Version'
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
          Width = 160
          Height = 23
          TabOrder = 0
          OnDblClick = edtgrid_color_1DblClick
          OnExit = edtgrid_color_1Exit
        end
        object edtgrid_color_2: TEdit
          Left = 137
          Top = 26
          Width = 160
          Height = 23
          TabOrder = 2
          OnDblClick = edtgrid_color_2DblClick
          OnExit = edtgrid_color_2Exit
        end
        object edtgrid_color_active: TEdit
          Left = 137
          Top = 49
          Width = 160
          Height = 23
          TabOrder = 4
          OnDblClick = edtgrid_color_activeDblClick
          OnExit = edtgrid_color_activeExit
        end
        object edtperiod: TEdit
          Left = 137
          Top = 96
          Width = 160
          Height = 23
          TabOrder = 8
        end
        object edtmail_host_name: TEdit
          Left = 477
          Top = 3
          Width = 200
          Height = 23
          TabOrder = 1
        end
        object edtmail_host_user: TEdit
          Left = 477
          Top = 26
          Width = 200
          Height = 23
          TabOrder = 3
        end
        object edtmail_host_pass: TEdit
          Left = 477
          Top = 49
          Width = 200
          Height = 23
          PasswordChar = '#'
          TabOrder = 5
        end
        object edtmail_host_smtp_port: TEdit
          Left = 477
          Top = 72
          Width = 200
          Height = 23
          TabOrder = 7
        end
        object edtapp_language: TEdit
          Left = 137
          Top = 119
          Width = 160
          Height = 23
          TabOrder = 9
        end
        object edtsms_service_provider: TEdit
          Left = 477
          Top = 158
          Width = 200
          Height = 23
          TabOrder = 10
        end
        object edtsms_user: TEdit
          Left = 477
          Top = 181
          Width = 200
          Height = 23
          TabOrder = 11
        end
        object edtsms_password: TEdit
          Left = 477
          Top = 204
          Width = 200
          Height = 23
          PasswordChar = '#'
          TabOrder = 12
        end
        object edtsms_title: TEdit
          Left = 477
          Top = 227
          Width = 200
          Height = 23
          TabOrder = 14
        end
        object edtapp_version: TEdit
          Left = 137
          Top = 227
          Width = 160
          Height = 23
          TabOrder = 13
        end
        object edtcrypt_key: TEdit
          Left = 137
          Top = 72
          Width = 160
          Height = 23
          TabOrder = 6
        end
      end
      object ts1: TTabSheet
        Caption = 'ts1'
        ImageIndex = 3
        object lblpath_stock_image: TLabel
          Left = 30
          Top = 5
          Width = 124
          Height = 13
          Alignment = taRightJustify
          Caption = 'Stok Card Image Path'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblpath_update: TLabel
          Left = 62
          Top = 29
          Width = 92
          Height = 13
          Alignment = taRightJustify
          Caption = 'Update File Path'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtpath_stock_image: TEdit
          Left = 160
          Top = 2
          Width = 462
          Height = 23
          TabOrder = 0
        end
        object btnpath_stock_image: TButton
          Left = 624
          Top = 2
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 1
          OnClick = btnpath_stock_imageClick
        end
        object edtpath_update: TEdit
          Left = 160
          Top = 26
          Width = 462
          Height = 23
          TabOrder = 2
        end
        object btnpath_update: TButton
          Left = 624
          Top = 26
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 3
          OnClick = btnpath_updateClick
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 275
    Width = 672
    ExplicitTop = 271
    ExplicitWidth = 670
    inherited btnAccept: TButton
      Left = 466
      ExplicitLeft = 464
    end
    inherited btnClose: TButton
      Left = 570
      ExplicitLeft = 568
    end
  end
  inherited stbBase: TStatusBar
    Top = 305
    Width = 676
    ExplicitTop = 301
    ExplicitWidth = 674
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

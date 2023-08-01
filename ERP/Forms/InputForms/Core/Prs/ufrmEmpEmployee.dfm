inherited frmEmpEmployee: TfrmEmpEmployee
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Employee Card'
  ClientHeight = 403
  ClientWidth = 597
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 613
  ExplicitHeight = 442
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 597
    Height = 353
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 629
    ExplicitHeight = 417
    inherited pgcMain: TPageControl
      Width = 599
      Height = 357
      ActivePage = tsSpecial
      OnChange = pgcMainChange
      ExplicitWidth = 629
      ExplicitHeight = 417
      inherited tsMain: TTabSheet
        Caption = 'Genel'
        ExplicitWidth = 591
        ExplicitHeight = 329
        object lblis_aktif: TLabel
          Left = 80
          Top = 10
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Active?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblad: TLabel
          Left = 108
          Top = 32
          Width = 16
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ad'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsoyad: TLabel
          Left = 392
          Top = 32
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Soyad'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblpersonel_tipi_id: TLabel
          Left = 49
          Top = 54
          Width = 75
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Personel Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblbolum_id: TLabel
          Left = 89
          Top = 76
          Width = 35
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'B'#246'l'#252'm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblbirim_id: TLabel
          Left = 96
          Top = 98
          Width = 28
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Birim'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgorev_id: TLabel
          Left = 89
          Top = 120
          Width = 35
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'G'#246'rev'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltasima_servisi_id: TLabel
          Left = 376
          Top = 54
          Width = 56
          Height = 13
          Alignment = taRightJustify
          Caption = 'Servis No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblgenel_not: TLabel
          Left = 66
          Top = 142
          Width = 58
          Height = 13
          Alignment = taRightJustify
          Caption = 'Genel Not'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object imgpersonel_resim: TImage
          Left = 433
          Top = 73
          Width = 180
          Height = 180
          Stretch = True
        end
        object chkis_aktif: TCheckBox
          Left = 130
          Top = 7
          Width = 184
          Height = 21
          TabOrder = 0
        end
        object edtad: TEdit
          Left = 130
          Top = 29
          Width = 180
          Height = 21
          TabOrder = 1
        end
        object edtsoyad: TEdit
          Left = 434
          Top = 29
          Width = 180
          Height = 21
          TabOrder = 2
        end
        object cbbpersonel_tipi_id: TComboBox
          Left = 130
          Top = 51
          Width = 180
          Height = 21
          TabOrder = 3
        end
        object cbbtasima_servisi_id: TComboBox
          Left = 433
          Top = 51
          Width = 180
          Height = 21
          TabOrder = 4
        end
        object mmogenel_not: TMemo
          Left = 130
          Top = 139
          Width = 298
          Height = 144
          MaxLength = 256
          ScrollBars = ssVertical
          TabOrder = 8
        end
        object edtbolum_id: TEdit
          Left = 130
          Top = 73
          Width = 180
          Height = 21
          TabOrder = 5
        end
        object edtbirim_id: TEdit
          Left = 130
          Top = 95
          Width = 180
          Height = 21
          TabOrder = 6
        end
        object edtgorev_id: TEdit
          Left = 130
          Top = 117
          Width = 180
          Height = 21
          TabOrder = 7
        end
      end
      object tsDetail: TTabSheet
        Caption = 'Adres'
        ImageIndex = 1
        object lblbina_adi: TLabel
          Left = 78
          Top = 186
          Width = 48
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Bina Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsokak: TLabel
          Left = 89
          Top = 164
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
          Left = 89
          Top = 142
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
          Left = 81
          Top = 120
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
          Left = 104
          Top = 98
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
          Left = 74
          Top = 76
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #350'ehir Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblulke_id: TLabel
          Left = 77
          Top = 54
          Width = 49
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'lke Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblposta_kodu: TLabel
          Left = 60
          Top = 252
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
          Left = 80
          Top = 208
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
        object lblposta_kutusu: TLabel
          Left = 50
          Top = 230
          Width = 76
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Posta Kutusu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtilce: TEdit
          Left = 130
          Top = 95
          Width = 180
          Height = 21
          TabOrder = 2
        end
        object edtmahalle: TEdit
          Left = 130
          Top = 117
          Width = 180
          Height = 21
          TabOrder = 3
        end
        object edtcadde: TEdit
          Left = 130
          Top = 139
          Width = 180
          Height = 21
          TabOrder = 4
        end
        object edtsokak: TEdit
          Left = 130
          Top = 161
          Width = 180
          Height = 21
          TabOrder = 5
        end
        object edtbina_adi: TEdit
          Left = 130
          Top = 183
          Width = 180
          Height = 21
          TabOrder = 6
        end
        object edtkapi_no: TEdit
          Left = 130
          Top = 205
          Width = 180
          Height = 21
          TabOrder = 7
        end
        object edtposta_kodu: TEdit
          Left = 130
          Top = 249
          Width = 180
          Height = 21
          TabOrder = 9
        end
        object edtulke_id: TEdit
          Left = 130
          Top = 51
          Width = 180
          Height = 21
          TabOrder = 0
        end
        object edtsehir_id: TEdit
          Left = 130
          Top = 73
          Width = 180
          Height = 21
          TabOrder = 1
        end
        object edtposta_kutusu: TEdit
          Left = 130
          Top = 227
          Width = 180
          Height = 21
          TabOrder = 8
        end
      end
      object tsSpecial: TTabSheet
        Caption = #214'zel Bilgiler'
        ImageIndex = 2
        object lblmaas: TLabel
          Left = 98
          Top = 224
          Width = 31
          Height = 13
          Alignment = taRightJustify
          Caption = 'Maa'#351
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblozel_not: TLabel
          Left = 79
          Top = 268
          Width = 50
          Height = 13
          Alignment = taRightJustify
          Caption = #214'zel Not'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblikramiye_sayisi: TLabel
          Left = 44
          Top = 246
          Width = 85
          Height = 13
          Alignment = taRightJustify
          Caption = #304'kramiye Say'#305's'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblikramiye_tutar: TLabel
          Left = 351
          Top = 246
          Width = 82
          Height = 13
          Alignment = taRightJustify
          Caption = #304'kramiye Tutar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lbltel1: TLabel
          Left = 74
          Top = 54
          Width = 55
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Telefon 1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltel2: TLabel
          Left = 74
          Top = 76
          Width = 55
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Telefon 2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblyakin_telefon: TLabel
          Left = 42
          Top = 142
          Width = 87
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yak'#305'n Telefonu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblyakin_adi: TLabel
          Left = 74
          Top = 120
          Width = 55
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yak'#305'n Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemail: TLabel
          Left = 93
          Top = 98
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'E-Mail'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblayakkabi_no: TLabel
          Left = 55
          Top = 164
          Width = 73
          Height = 13
          Alignment = taRightJustify
          Caption = 'Ayakkab'#305' No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblelbise_bedeni: TLabel
          Left = 50
          Top = 186
          Width = 78
          Height = 13
          Alignment = taRightJustify
          Caption = 'Elbise Bedeni'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblkimlik_no: TLabel
          Left = 378
          Top = 54
          Width = 54
          Height = 13
          Alignment = taRightJustify
          Caption = 'Kimlik No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lbldogum_tarihi: TLabel
          Left = 356
          Top = 76
          Width = 76
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Do'#287'um Tarihi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkan_grubu: TLabel
          Left = 371
          Top = 98
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kan Grubu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcinsiyet_id: TLabel
          Left = 387
          Top = 120
          Width = 45
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Cinsiyet'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmedeni_durumu_id: TLabel
          Left = 350
          Top = 142
          Width = 82
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Medeni Durum'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblaskerlik_durumu_id: TLabel
          Left = 339
          Top = 186
          Width = 93
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Askerlik Durumu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcocuk_sayisi: TLabel
          Left = 358
          Top = 164
          Width = 74
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #199'ocuk Say'#305's'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edttel1: TEdit
          Left = 130
          Top = 51
          Width = 180
          Height = 21
          TabOrder = 0
        end
        object edttel2: TEdit
          Left = 130
          Top = 73
          Width = 180
          Height = 21
          TabOrder = 2
        end
        object edtemail: TEdit
          Left = 130
          Top = 95
          Width = 180
          Height = 21
          TabOrder = 4
        end
        object edtyakin_adi: TEdit
          Left = 130
          Top = 117
          Width = 180
          Height = 21
          TabOrder = 6
        end
        object edtyakin_telefon: TEdit
          Left = 130
          Top = 139
          Width = 180
          Height = 21
          TabOrder = 8
        end
        object edtayakkabi_no: TEdit
          Left = 131
          Top = 161
          Width = 180
          Height = 21
          MaxLength = 2
          TabOrder = 10
        end
        object edtelbise_bedeni: TEdit
          Left = 131
          Top = 183
          Width = 180
          Height = 21
          MaxLength = 4
          TabOrder = 12
        end
        object edtkimlik_no: TEdit
          Left = 434
          Top = 51
          Width = 180
          Height = 21
          MaxLength = 11
          TabOrder = 1
        end
        object edtdogum_tarihi: TEdit
          Left = 434
          Top = 73
          Width = 180
          Height = 21
          TabOrder = 3
        end
        object cbbkan_grubu: TComboBox
          Left = 434
          Top = 95
          Width = 180
          Height = 21
          TabOrder = 5
        end
        object cbbcinsiyet_id: TComboBox
          Left = 434
          Top = 117
          Width = 180
          Height = 21
          TabOrder = 7
          OnChange = cbbcinsiyet_idChange
        end
        object cbbmedeni_durumu_id: TComboBox
          Left = 434
          Top = 139
          Width = 180
          Height = 21
          TabOrder = 9
          OnChange = cbbmedeni_durumu_idChange
        end
        object edtcocuk_sayisi: TEdit
          Left = 434
          Top = 161
          Width = 180
          Height = 21
          TabOrder = 11
        end
        object cbbaskerlik_durumu_id: TComboBox
          Left = 434
          Top = 183
          Width = 180
          Height = 21
          TabOrder = 13
        end
        object edtmaas: TEdit
          Left = 130
          Top = 221
          Width = 180
          Height = 21
          MaxLength = 10
          TabOrder = 14
        end
        object edtikramiye_sayisi: TEdit
          Left = 130
          Top = 243
          Width = 180
          Height = 21
          MaxLength = 16
          TabOrder = 15
        end
        object edtikramiye_tutar: TEdit
          Left = 434
          Top = 243
          Width = 180
          Height = 21
          MaxLength = 16
          TabOrder = 16
        end
        object mmoozel_not: TMemo
          Left = 130
          Top = 265
          Width = 484
          Height = 112
          MaxLength = 256
          ScrollBars = ssVertical
          TabOrder = 17
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 355
    Width = 593
    ExplicitTop = 419
    ExplicitWidth = 625
    inherited btnAccept: TButton
      Left = 419
      ExplicitLeft = 419
    end
    inherited btnClose: TButton
      Left = 523
      ExplicitLeft = 523
    end
  end
  inherited stbBase: TStatusBar
    Top = 385
    Width = 597
    ExplicitTop = 449
    ExplicitWidth = 629
  end
  inherited pmLabels: TPopupMenu
    Left = 280
    Top = 456
  end
end

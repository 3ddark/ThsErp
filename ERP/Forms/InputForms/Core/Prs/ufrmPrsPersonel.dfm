inherited frmPrsPersonel: TfrmPrsPersonel
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Person Bilgi Kart'#305
  ClientHeight = 458
  ClientWidth = 628
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 644
  ExplicitHeight = 497
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 628
    Height = 408
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 626
    ExplicitHeight = 405
    inherited pgcMain: TPageControl
      Width = 628
      Height = 408
      OnChange = pgcMainChange
      ExplicitWidth = 626
      ExplicitHeight = 405
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 620
        ExplicitHeight = 379
        object lblpasif: TLabel
          Left = 90
          Top = 10
          Width = 34
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Pasif?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblad: TLabel
          Left = 109
          Top = 32
          Width = 15
          Height = 14
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
          Left = 395
          Top = 32
          Width = 33
          Height = 14
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
          Left = 51
          Top = 54
          Width = 73
          Height = 14
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
          Height = 14
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
          Left = 95
          Top = 98
          Width = 29
          Height = 14
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
          Left = 91
          Top = 120
          Width = 33
          Height = 14
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
          Left = 380
          Top = 54
          Width = 52
          Height = 14
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
          Left = 71
          Top = 142
          Width = 53
          Height = 14
          Alignment = taRightJustify
          Caption = 'Genel Not'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object chkpasif: TCheckBox
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
          Left = 432
          Top = 29
          Width = 182
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
          Left = 432
          Top = 51
          Width = 182
          Height = 21
          Style = csDropDownList
          TabOrder = 4
        end
        object mmogenel_not: TMemo
          Left = 130
          Top = 139
          Width = 298
          Height = 144
          MaxLength = 256
          ScrollBars = ssVertical
          TabOrder = 9
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
          TabOrder = 7
        end
        object edtgorev_id: TEdit
          Left = 130
          Top = 117
          Width = 180
          Height = 21
          TabOrder = 8
        end
        object pnlimg: TPanel
          Left = 433
          Top = 73
          Width = 181
          Height = 180
          BevelKind = bkFlat
          BevelOuter = bvNone
          TabOrder = 6
          object imgpersonel_resim: TImage
            Left = 0
            Top = 0
            Width = 177
            Height = 176
            Align = alClient
            PopupMenu = pmimg
            Stretch = True
            ExplicitLeft = 1
            ExplicitTop = -143
            ExplicitWidth = 180
            ExplicitHeight = 180
          end
        end
      end
      object tsDetail: TTabSheet
        Caption = 'Adres'
        ImageIndex = 1
        object lblbina_adi: TLabel
          Left = 103
          Top = 215
          Width = 23
          Height = 14
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
          Left = 92
          Top = 192
          Width = 34
          Height = 14
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
          Left = 91
          Top = 169
          Width = 35
          Height = 14
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
          Left = 84
          Top = 123
          Width = 42
          Height = 14
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
          Left = 107
          Top = 100
          Width = 19
          Height = 14
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
          Left = 97
          Top = 77
          Width = 29
          Height = 14
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
          Left = 102
          Top = 54
          Width = 24
          Height = 14
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
        object lblkapi_no: TLabel
          Left = 86
          Top = 238
          Width = 40
          Height = 14
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
          Left = 97
          Top = 146
          Width = 29
          Height = 14
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
        object lblposta_kodu: TLabel
          Left = 368
          Top = 238
          Width = 62
          Height = 14
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
        object edtilce: TEdit
          Left = 130
          Top = 97
          Width = 180
          Height = 21
          TabOrder = 2
        end
        object edtmahalle: TEdit
          Left = 130
          Top = 120
          Width = 180
          Height = 21
          TabOrder = 3
        end
        object edtcadde: TEdit
          Left = 130
          Top = 166
          Width = 180
          Height = 21
          TabOrder = 5
        end
        object edtsokak: TEdit
          Left = 130
          Top = 189
          Width = 180
          Height = 21
          TabOrder = 6
        end
        object edtbina_adi: TEdit
          Left = 130
          Top = 212
          Width = 180
          Height = 21
          TabOrder = 7
        end
        object edtkapi_no: TEdit
          Left = 130
          Top = 235
          Width = 180
          Height = 21
          TabOrder = 8
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
          Top = 74
          Width = 180
          Height = 21
          TabOrder = 1
        end
        object edtsemt: TEdit
          Left = 130
          Top = 143
          Width = 180
          Height = 21
          TabOrder = 4
        end
        object edtposta_kodu: TEdit
          Left = 434
          Top = 235
          Width = 180
          Height = 21
          TabOrder = 9
        end
      end
      object tsSpecial: TTabSheet
        Caption = #214'zel Bilgiler'
        ImageIndex = 2
        object lblmaas: TLabel
          Left = 100
          Top = 224
          Width = 29
          Height = 14
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
          Left = 84
          Top = 268
          Width = 45
          Height = 14
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
          Left = 46
          Top = 246
          Width = 83
          Height = 14
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
          Left = 354
          Top = 246
          Width = 79
          Height = 14
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
          Left = 79
          Top = 54
          Width = 50
          Height = 14
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
          Left = 79
          Top = 76
          Width = 50
          Height = 14
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
          Left = 49
          Top = 142
          Width = 80
          Height = 14
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
          Left = 79
          Top = 120
          Width = 50
          Height = 14
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
          Left = 97
          Top = 98
          Width = 32
          Height = 14
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
          Left = 61
          Top = 164
          Width = 67
          Height = 14
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
          Left = 54
          Top = 186
          Width = 74
          Height = 14
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
          Left = 381
          Top = 54
          Width = 51
          Height = 14
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
          Left = 360
          Top = 76
          Width = 72
          Height = 14
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
          Left = 375
          Top = 98
          Width = 57
          Height = 14
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
          Height = 14
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
          Left = 351
          Top = 142
          Width = 81
          Height = 14
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
          Left = 338
          Top = 186
          Width = 94
          Height = 14
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
          Left = 362
          Top = 164
          Width = 70
          Height = 14
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
          Style = csDropDownList
          TabOrder = 5
        end
        object cbbcinsiyet_id: TComboBox
          Left = 434
          Top = 117
          Width = 180
          Height = 21
          Style = csDropDownList
          TabOrder = 7
          OnChange = cbbcinsiyet_idChange
        end
        object cbbmedeni_durumu_id: TComboBox
          Left = 434
          Top = 139
          Width = 180
          Height = 21
          Style = csDropDownList
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
          Style = csDropDownList
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
    Top = 410
    Width = 624
    ExplicitTop = 407
    ExplicitWidth = 622
    inherited btnAccept: TButton
      Left = 418
      ExplicitLeft = 416
    end
    inherited btnClose: TButton
      Left = 522
      ExplicitLeft = 520
    end
  end
  inherited stbBase: TStatusBar
    Top = 440
    Width = 628
    ExplicitTop = 437
    ExplicitWidth = 626
  end
  inherited pmLabels: TPopupMenu
    Left = 280
    Top = 456
  end
  object pmimg: TPopupMenu
    Images = dm.il16
    Left = 224
    Top = 328
    object mniResimEkle: TMenuItem
      Caption = 'Resim Ekle'
      ImageIndex = 33
      OnClick = mniResimEkleClick
    end
    object mniResimSil: TMenuItem
      Caption = 'Resim Sil'
      ImageIndex = 51
      OnClick = mniResimSilClick
    end
  end
end

inherited frmSatSiparisDetaylar: TfrmSatSiparisDetaylar
  Caption = 'Sipari'#351' Detaylar'#305
  ClientHeight = 561
  ClientWidth = 904
  ExplicitWidth = 920
  ExplicitHeight = 600
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 900
    Height = 509
    ExplicitWidth = 900
    ExplicitHeight = 509
    inherited splLeft: TSplitter
      Top = 333
      Height = 175
      ExplicitTop = 437
      ExplicitHeight = 502
    end
    inherited splHeader: TSplitter
      Top = 330
      Width = 898
      ExplicitLeft = 0
      ExplicitTop = 74
      ExplicitWidth = 973
    end
    inherited pgcMain: TPageControl
      Top = 333
      Width = 792
      Height = 175
      ExplicitTop = 333
      ExplicitWidth = 792
      ExplicitHeight = 175
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 784
        ExplicitHeight = 147
      end
    end
    inherited pnlHeader: TPanel
      Width = 894
      Height = 326
      ExplicitWidth = 894
      ExplicitHeight = 326
      inherited pgcHeader: TPageControl
        Width = 892
        Height = 324
        ExplicitWidth = 892
        ExplicitHeight = 324
        inherited tsHeader: TTabSheet
          Caption = 'Genel'
          ExplicitLeft = 16
          ExplicitTop = 4
          ExplicitWidth = 864
          ExplicitHeight = 316
          object lblsiparis_no: TLabel
            Left = 626
            Top = 6
            Width = 59
            Height = 13
            Alignment = taRightJustify
            Caption = 'Sipari'#351' No'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblsiparis_tarihi: TLabel
            Left = 610
            Top = 28
            Width = 75
            Height = 13
            Alignment = taRightJustify
            Caption = 'Sipari'#351' Tarihi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblsiparis_durum_id: TLabel
            Left = 35
            Top = 291
            Width = 79
            Height = 13
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            Caption = 'Sipari'#351' Durum'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentBiDiMode = False
            ParentFont = False
          end
          object lblmusteri_kodu: TLabel
            Left = 39
            Top = 5
            Width = 75
            Height = 13
            Alignment = taRightJustify
            Caption = 'M'#252#351'teri Kodu'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblmusteri_adi: TLabel
            Left = 50
            Top = 27
            Width = 64
            Height = 13
            Alignment = taRightJustify
            Caption = 'M'#252#351'teri Ad'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblvergi_dairesi: TLabel
            Left = 41
            Top = 49
            Width = 73
            Height = 13
            Alignment = taRightJustify
            Caption = 'Vergi Dairesi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblvergi_no: TLabel
            Left = 64
            Top = 71
            Width = 50
            Height = 13
            Alignment = taRightJustify
            Caption = 'Vergi No'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblpara_birimi: TLabel
            Left = 624
            Top = 94
            Width = 61
            Height = 13
            Alignment = taRightJustify
            Caption = 'Para Birimi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblkur_dolar: TLabel
            Left = 624
            Top = 116
            Width = 61
            Height = 13
            Alignment = taRightJustify
            Caption = 'Dolar Kuru'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblkur_euro: TLabel
            Left = 628
            Top = 138
            Width = 57
            Height = 13
            Alignment = taRightJustify
            Caption = 'Euro Kuru'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblmusteri_temsilcisi_id: TLabel
            Left = 306
            Top = 49
            Width = 101
            Height = 13
            Alignment = taRightJustify
            Caption = 'M'#252#351'teri Temsilcisi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblteslim_sekli_id: TLabel
            Left = 338
            Top = 181
            Width = 69
            Height = 13
            Alignment = taRightJustify
            Caption = 'Teslim '#350'ekli'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblodeme_sekli_id: TLabel
            Left = 335
            Top = 159
            Width = 72
            Height = 13
            Alignment = taRightJustify
            Caption = #214'deme '#350'ekli'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblreferans: TLabel
            Left = 355
            Top = 204
            Width = 52
            Height = 13
            Alignment = taRightJustify
            Caption = 'Referans'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object lblmuhattap_ad: TLabel
            Left = 334
            Top = 71
            Width = 73
            Height = 13
            Alignment = taRightJustify
            Caption = 'Muhattap Ad'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblteslim_tarihi: TLabel
            Left = 612
            Top = 50
            Width = 73
            Height = 13
            Alignment = taRightJustify
            Caption = 'Teslim Tarihi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblkapi_no: TLabel
            Left = 68
            Top = 247
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
          object lblposta_kodu: TLabel
            Left = 48
            Top = 269
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
          object lblulke_id: TLabel
            Left = 87
            Top = 93
            Width = 27
            Height = 13
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
          object lblsehir_id: TLabel
            Left = 84
            Top = 115
            Width = 30
            Height = 13
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
          object lblilce: TLabel
            Left = 92
            Top = 137
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
          object lblmahalle: TLabel
            Left = 69
            Top = 159
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
          object lblcadde: TLabel
            Left = 77
            Top = 181
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
          object lblsokak: TLabel
            Left = 77
            Top = 203
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
          object lblbina_adi: TLabel
            Left = 88
            Top = 225
            Width = 26
            Height = 13
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
          object lblpaket_tipi_id: TLabel
            Left = 331
            Top = 115
            Width = 76
            Height = 13
            Alignment = taRightJustify
            Caption = 'Ambalaj Cinsi'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltasima_ucreti_id: TLabel
            Left = 326
            Top = 137
            Width = 81
            Height = 13
            Alignment = taRightJustify
            Caption = 'Nakliye '#220'creti'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblaciklama: TLabel
            Left = 355
            Top = 225
            Width = 52
            Height = 13
            Alignment = taRightJustify
            Caption = 'A'#231#305'klama'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblproforma_no: TLabel
            Left = 336
            Top = 291
            Width = 71
            Height = 13
            Alignment = taRightJustify
            Caption = 'Proforma No'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object lblmuhattap_telefon: TLabel
            Left = 306
            Top = 93
            Width = 101
            Height = 13
            Alignment = taRightJustify
            Caption = 'Muhattap Telefon'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object cbbsiparis_durum_id: TComboBox
            Left = 115
            Top = 288
            Width = 150
            Height = 21
            Style = csDropDownList
            TabOrder = 28
          end
          object edtsiparis_no: TEdit
            Left = 686
            Top = 2
            Width = 90
            Height = 21
            TabOrder = 1
          end
          object edtsiparis_tarihi: TEdit
            Left = 686
            Top = 24
            Width = 90
            Height = 21
            TabOrder = 3
          end
          object edtmusteri_kodu: TEdit
            Left = 115
            Top = 2
            Width = 150
            Height = 21
            TabOrder = 0
          end
          object edtmusteri_adi: TEdit
            Left = 115
            Top = 24
            Width = 443
            Height = 21
            TabOrder = 2
          end
          object edtvergi_dairesi: TEdit
            Left = 115
            Top = 46
            Width = 150
            Height = 21
            TabOrder = 4
          end
          object edtvergi_no: TEdit
            Left = 115
            Top = 68
            Width = 150
            Height = 21
            TabOrder = 7
          end
          object edtulke_id: TEdit
            Left = 115
            Top = 90
            Width = 150
            Height = 21
            TabOrder = 9
          end
          object edtsehir_id: TEdit
            Left = 115
            Top = 112
            Width = 150
            Height = 21
            TabOrder = 12
          end
          object edtilce: TEdit
            Left = 115
            Top = 134
            Width = 150
            Height = 21
            TabOrder = 15
          end
          object edtmahalle: TEdit
            Left = 115
            Top = 156
            Width = 150
            Height = 21
            TabOrder = 18
          end
          object edtcadde: TEdit
            Left = 115
            Top = 178
            Width = 150
            Height = 21
            TabOrder = 20
          end
          object edtsokak: TEdit
            Left = 115
            Top = 200
            Width = 150
            Height = 21
            TabOrder = 22
          end
          object edtbina_adi: TEdit
            Left = 115
            Top = 222
            Width = 150
            Height = 21
            TabOrder = 24
          end
          object edtkapi_no: TEdit
            Left = 115
            Top = 244
            Width = 150
            Height = 21
            TabOrder = 26
          end
          object edtposta_kodu: TEdit
            Left = 115
            Top = 266
            Width = 150
            Height = 21
            TabOrder = 27
          end
          object edtteslim_tarihi: TEdit
            Left = 686
            Top = 46
            Width = 90
            Height = 21
            TabOrder = 6
          end
          object edtkur_dolar: TEdit
            Left = 686
            Top = 112
            Width = 90
            Height = 21
            TabOrder = 14
          end
          object edtkur_euro: TEdit
            Left = 686
            Top = 134
            Width = 90
            Height = 21
            TabOrder = 17
          end
          object edtmusteri_temsilcisi_id: TEdit
            Left = 408
            Top = 46
            Width = 150
            Height = 21
            TabOrder = 5
          end
          object edtmuhattap_ad: TEdit
            Left = 408
            Top = 68
            Width = 150
            Height = 21
            TabOrder = 8
          end
          object edtreferans: TEdit
            Left = 408
            Top = 200
            Width = 368
            Height = 21
            TabOrder = 23
          end
          object mmoaciklama: TMemo
            Left = 408
            Top = 222
            Width = 368
            Height = 65
            TabOrder = 25
          end
          object edtproforma_no: TEdit
            Left = 408
            Top = 288
            Width = 150
            Height = 21
            MaxLength = 10
            TabOrder = 29
          end
          object edtmuhattap_telefon: TEdit
            Left = 408
            Top = 90
            Width = 150
            Height = 21
            TabOrder = 10
          end
          object edtpaket_tipi_id: TEdit
            Left = 408
            Top = 112
            Width = 150
            Height = 21
            TabOrder = 13
          end
          object edttasima_ucreti_id: TEdit
            Left = 408
            Top = 134
            Width = 150
            Height = 21
            TabOrder = 16
          end
          object edtpara_birimi: TEdit
            Left = 686
            Top = 90
            Width = 90
            Height = 21
            TabOrder = 11
          end
          object edtodeme_sekli_id: TEdit
            Left = 408
            Top = 156
            Width = 368
            Height = 21
            TabOrder = 19
          end
          object edtteslim_sekli_id: TEdit
            Left = 408
            Top = 178
            Width = 368
            Height = 21
            TabOrder = 21
          end
        end
        inherited tsHeaderDiger: TTabSheet
          ExplicitLeft = 24
          ExplicitTop = 4
          ExplicitWidth = 864
          ExplicitHeight = 316
        end
      end
    end
    inherited pnlContent: TPanel
      Top = 333
      Width = 792
      Height = 175
      ExplicitTop = 333
      ExplicitWidth = 792
      ExplicitHeight = 175
      inherited pgcContent: TPageControl
        Width = 790
        Height = 171
        ExplicitWidth = 790
        ExplicitHeight = 171
        inherited ts1: TTabSheet
          ExplicitLeft = 4
          ExplicitTop = 24
          ExplicitWidth = 782
          ExplicitHeight = 143
          inherited pnl1: TPanel
            Top = 59
            Width = 782
            ExplicitTop = 59
            ExplicitWidth = 782
            inherited grpGenelToplamKalan: TGroupBox
              Left = 312
              ExplicitLeft = 312
            end
            inherited grpGenelToplam: TGroupBox
              Left = 547
              ExplicitLeft = 547
            end
            inherited flwpnl1: TFlowPanel
              Width = 310
              ExplicitWidth = 310
            end
          end
          inherited strngrd1: TStringGrid
            Width = 782
            Height = 59
            ExplicitWidth = 782
            ExplicitHeight = 59
          end
        end
        inherited ts2: TTabSheet
          ExplicitLeft = 4
          ExplicitTop = 24
          ExplicitWidth = 782
          ExplicitHeight = 143
          inherited pnl2: TPanel
            Top = 9
            Width = 782
            TabOrder = 1
            ExplicitTop = 9
            ExplicitWidth = 782
            inherited flwpnl2: TFlowPanel
              Width = 776
              ExplicitWidth = 776
            end
          end
          inherited strngrd2: TStringGrid
            Width = 782
            Height = 9
            TabOrder = 0
            ExplicitWidth = 782
            ExplicitHeight = 9
          end
        end
        inherited ts3: TTabSheet
          ExplicitLeft = 4
          ExplicitTop = 24
          ExplicitWidth = 782
          ExplicitHeight = 143
          inherited strngrd3: TStringGrid
            Width = 782
            Height = 9
            ExplicitWidth = 782
            ExplicitHeight = 9
          end
          inherited pnl3: TPanel
            Top = 9
            Width = 782
            ExplicitTop = 9
            ExplicitWidth = 782
            inherited flwpnl3: TFlowPanel
              Width = 776
              ExplicitWidth = 776
            end
          end
        end
      end
      inherited btnHeaderShowHide: TButton
        Left = 687
        Width = 100
        ExplicitLeft = 687
        ExplicitWidth = 100
      end
    end
    inherited pnlLeft: TPanel
      Top = 334
      Height = 172
      ExplicitTop = 334
      ExplicitHeight = 172
    end
  end
  inherited pnlBottom: TPanel
    Top = 513
    Width = 900
    ExplicitTop = 513
    ExplicitWidth = 900
    inherited btnAccept: TButton
      Left = 691
      ExplicitLeft = 691
    end
    inherited btnClose: TButton
      Left = 795
      ExplicitLeft = 795
    end
  end
  inherited stbBase: TStatusBar
    Top = 543
    Width = 904
    ExplicitTop = 543
    ExplicitWidth = 904
  end
  inherited frxrprtBase: TfrxReport
    ScriptText.Strings = ()
  end
end

inherited frmAlsTeklifDetay: TfrmAlsTeklifDetay
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sat'#305#351' Teklif Detay'
  ClientHeight = 384
  ClientWidth = 421
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 437
  ExplicitHeight = 423
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 421
    Height = 334
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 425
    ExplicitHeight = 340
    inherited pgcMain: TPageControl
      Width = 421
      Height = 334
      ExplicitWidth = 425
      ExplicitHeight = 340
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 413
        ExplicitHeight = 305
        object lblstok_kodu: TLabel
          Left = 39
          Top = 6
          Width = 56
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Stok Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblstok_aciklama: TLabel
          Left = 17
          Top = 28
          Width = 78
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Stok A'#231#305'klama'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfiyat: TLabel
          Left = 70
          Top = 50
          Width = 25
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Fiyat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbliskonto_orani: TLabel
          Left = 53
          Top = 116
          Width = 42
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304'skonto'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkdv_orani: TLabel
          Left = 75
          Top = 138
          Width = 20
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kdv'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmiktar: TLabel
          Left = 60
          Top = 72
          Width = 35
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Miktar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblolcu_birimi: TLabel
          Left = 36
          Top = 94
          Width = 59
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgtip_no: TLabel
          Left = 56
          Top = 160
          Width = 39
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Gtip No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object imgstok_resim: TImage
          Left = 278
          Top = 47
          Width = 131
          Height = 131
          Stretch = True
        end
        object lblkullanici_aciklama: TLabel
          Left = 45
          Top = 182
          Width = 50
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'A'#231#305'klama'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtstok_kodu: TEdit
          Left = 97
          Top = 3
          Width = 150
          Height = 21
          TabOrder = 0
        end
        object edtstok_aciklama: TEdit
          Left = 97
          Top = 25
          Width = 312
          Height = 21
          TabOrder = 1
        end
        object edtfiyat: TEdit
          Left = 97
          Top = 47
          Width = 110
          Height = 21
          TabOrder = 2
          OnChange = edtfiyatChange
          OnExit = edtfiyatExit
        end
        object edtmiktar: TEdit
          Left = 97
          Top = 69
          Width = 110
          Height = 21
          TabOrder = 3
          OnChange = edtmiktarChange
          OnExit = edtmiktarExit
        end
        object edtiskonto_orani: TEdit
          Left = 97
          Top = 113
          Width = 110
          Height = 21
          TabOrder = 5
          OnChange = edtiskonto_oraniChange
          OnExit = edtiskonto_oraniExit
        end
        object edtgtip_no: TEdit
          Left = 97
          Top = 157
          Width = 150
          Height = 21
          TabOrder = 7
        end
        object PanelBilgilendirme: TPanel
          Left = 97
          Top = 200
          Width = 312
          Height = 106
          BevelInner = bvLowered
          ParentColor = True
          TabOrder = 9
          object lbltutar: TLabel
            Left = 96
            Top = 21
            Width = 28
            Height = 14
            Alignment = taRightJustify
            Caption = 'Tutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltutar_val: TLabel
            Left = 124
            Top = 21
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lbliskonto_tutar: TLabel
            Left = 48
            Top = 38
            Width = 76
            Height = 14
            Alignment = taRightJustify
            Caption = #304'skonto Tutar'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbliskonto_tutar_val: TLabel
            Left = 124
            Top = 38
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueIskontoTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lblkdv_tutar: TLabel
            Left = 68
            Top = 72
            Width = 56
            Height = 14
            Alignment = taRightJustify
            Caption = 'KDV Tutar'#305
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblkdv_tutar_val: TLabel
            Left = 124
            Top = 72
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueKDVTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lbltoplam_tutar: TLabel
            Left = 53
            Top = 89
            Width = 71
            Height = 14
            Alignment = taRightJustify
            Caption = 'Toplam Tutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lbltoplam_tutar_val: TLabel
            Left = 124
            Top = 89
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueToplamTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lblnet_fiyat: TLabel
            Left = 78
            Top = 4
            Width = 46
            Height = 14
            Alignment = taRightJustify
            Caption = 'Net Fiyat'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblnet_fiyat_val: TLabel
            Left = 124
            Top = 4
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lblnet_tutar: TLabel
            Left = 75
            Top = 55
            Width = 49
            Height = 14
            Alignment = taRightJustify
            Caption = 'Net Tutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblnet_tutar_val: TLabel
            Left = 124
            Top = 55
            Width = 120
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'ValueTutar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
        end
        object edtkdv_orani: TEdit
          Left = 97
          Top = 135
          Width = 110
          Height = 21
          TabOrder = 6
          OnChange = edtkdv_oraniChange
          OnExit = edtkdv_oraniExit
        end
        object edtolcu_birimi: TEdit
          Left = 97
          Top = 91
          Width = 110
          Height = 21
          TabOrder = 4
        end
        object edtkullanici_aciklama: TEdit
          Left = 97
          Top = 179
          Width = 312
          Height = 21
          TabOrder = 8
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 336
    Width = 417
    ExplicitTop = 342
    ExplicitWidth = 421
    inherited btnAccept: TButton
      Left = 215
      ExplicitLeft = 215
    end
    inherited btnClose: TButton
      Left = 319
      ExplicitLeft = 319
    end
  end
  inherited stbBase: TStatusBar
    Top = 366
    Width = 421
    ExplicitTop = 372
    ExplicitWidth = 425
  end
end

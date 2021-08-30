inherited frmSysUygulamaAyariDiger: TfrmSysUygulamaAyariDiger
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem Uygulama Ayarlar'#305' Di'#287'er'
  ClientHeight = 440
  ClientWidth = 669
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 675
  ExplicitHeight = 469
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 665
    Height = 388
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 665
    ExplicitHeight = 388
    inherited pgcMain: TPageControl
      Width = 663
      Height = 386
      ExplicitWidth = 663
      ExplicitHeight = 386
      inherited tsMain: TTabSheet
        ExplicitWidth = 655
        ExplicitHeight = 358
        object lblis_edefter_aktif: TLabel
          Left = 77
          Top = 3
          Width = 77
          Height = 13
          Alignment = taRightJustify
          Caption = 'E-Defter Aktif'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblis_efatura_aktif: TLabel
          Left = 76
          Top = 21
          Width = 78
          Height = 13
          Alignment = taRightJustify
          Caption = 'E-Fatura Aktif'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblis_eirsaliye_aktif: TLabel
          Left = 70
          Top = 39
          Width = 84
          Height = 13
          Alignment = taRightJustify
          Caption = 'E-'#304'rsaliye Aktif'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblpath_stok_resim: TLabel
          Left = 43
          Top = 59
          Width = 111
          Height = 13
          Alignment = taRightJustify
          Caption = 'Path '#304'mg Stok Kart'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblpath_guncelleme: TLabel
          Left = 23
          Top = 81
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
        object lblpath_utd: TLabel
          Left = 60
          Top = 103
          Width = 94
          Height = 13
          Alignment = taRightJustify
          Caption = 'UTD Yedek Dizini'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lbltemin_suresi_birim: TLabel
          Left = 51
          Top = 147
          Width = 105
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Temin S'#252'resi Birim'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblstok_en_boy_yukseklik_birim: TLabel
          Left = 65
          Top = 169
          Width = 91
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Stok E-B-Y Birim'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object chkis_edefter_aktif: TCheckBox
          Left = 160
          Top = 2
          Width = 250
          Height = 17
          TabOrder = 0
        end
        object chkis_efatura_aktif: TCheckBox
          Left = 160
          Top = 20
          Width = 250
          Height = 17
          TabOrder = 1
        end
        object chkis_eirsaliye_aktif: TCheckBox
          Left = 160
          Top = 38
          Width = 250
          Height = 17
          TabOrder = 2
        end
        object edtpath_stok_resim: TEdit
          Left = 160
          Top = 56
          Width = 462
          Height = 21
          TabOrder = 3
        end
        object btnpath_stok_resim: TButton
          Left = 624
          Top = 56
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 4
          OnClick = btnpath_stok_resimClick
        end
        object edtpath_guncelleme: TEdit
          Left = 160
          Top = 78
          Width = 462
          Height = 21
          TabOrder = 5
        end
        object btnpath_guncelleme: TButton
          Left = 624
          Top = 78
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 6
          OnClick = btnpath_guncellemeClick
        end
        object edtpath_utd: TEdit
          Left = 160
          Top = 100
          Width = 462
          Height = 21
          TabOrder = 7
        end
        object btnpath_utd: TButton
          Left = 624
          Top = 100
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 8
          OnClick = btnpath_utdClick
        end
        object edtstok_en_boy_yukseklik_birim: TEdit
          Left = 160
          Top = 166
          Width = 145
          Height = 21
          TabOrder = 9
        end
        object edttemin_suresi_birim: TEdit
          Left = 160
          Top = 144
          Width = 145
          Height = 21
          TabOrder = 10
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 392
    Width = 665
    ExplicitTop = 392
    ExplicitWidth = 665
    inherited btnAccept: TButton
      Left = 456
      TabOrder = 2
      ExplicitLeft = 456
    end
    inherited btnClose: TButton
      Left = 560
      TabOrder = 3
      ExplicitLeft = 560
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 422
    Width = 669
    ExplicitTop = 422
    ExplicitWidth = 669
  end
end

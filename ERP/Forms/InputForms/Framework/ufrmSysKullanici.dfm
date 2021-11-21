inherited frmSysKullanici: TfrmSysKullanici
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem Kullan'#305'c'#305
  ClientHeight = 307
  ClientWidth = 376
  ParentFont = True
  ExplicitWidth = 382
  ExplicitHeight = 336
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 372
    Height = 255
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 372
    ExplicitHeight = 255
    inherited pgcMain: TPageControl
      Width = 370
      Height = 253
      ExplicitWidth = 370
      ExplicitHeight = 253
      inherited tsMain: TTabSheet
        ExplicitWidth = 362
        ExplicitHeight = 225
        object lblkullanici_adi: TLabel
          Left = 41
          Top = 10
          Width = 67
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kullanici Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkullanici_sifre: TLabel
          Left = 33
          Top = 32
          Width = 75
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kullan'#305'c'#305' '#350'ifre'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_aktif: TLabel
          Left = 75
          Top = 57
          Width = 33
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Aktif?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_online: TLabel
          Left = 67
          Top = 77
          Width = 41
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Online?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_yonetici: TLabel
          Left = 57
          Top = 97
          Width = 51
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yonetici?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_super_kullanici: TLabel
          Left = 20
          Top = 117
          Width = 88
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Super Kullan'#305'c'#305'?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblip_adres: TLabel
          Left = 60
          Top = 142
          Width = 48
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ip Adres'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmac_adres: TLabel
          Left = 49
          Top = 164
          Width = 59
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mac Adres'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblpersonel_ad_soyad_id: TLabel
          Left = 55
          Top = 186
          Width = 53
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ad Soyad'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtkullanici_adi: TEdit
          Left = 114
          Top = 7
          Width = 239
          Height = 21
          TabOrder = 0
        end
        object edtkullanici_sifre: TEdit
          Left = 114
          Top = 29
          Width = 239
          Height = 21
          PasswordChar = '*'
          TabOrder = 1
        end
        object chkis_aktif: TCheckBox
          Left = 114
          Top = 56
          Width = 239
          Height = 17
          TabOrder = 2
        end
        object chkis_online: TCheckBox
          Left = 114
          Top = 76
          Width = 239
          Height = 17
          TabOrder = 3
        end
        object chkis_yonetici: TCheckBox
          Left = 114
          Top = 96
          Width = 239
          Height = 17
          TabOrder = 4
        end
        object chkis_super_kullanici: TCheckBox
          Left = 114
          Top = 116
          Width = 239
          Height = 17
          TabOrder = 5
        end
        object edtip_adres: TEdit
          Left = 114
          Top = 139
          Width = 239
          Height = 21
          TabOrder = 6
        end
        object edtmac_adres: TEdit
          Left = 114
          Top = 161
          Width = 239
          Height = 21
          TabOrder = 7
        end
        object edtpersonel_ad_soyad_id: TEdit
          Left = 114
          Top = 183
          Width = 239
          Height = 21
          TabOrder = 8
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 259
    Width = 372
    ExplicitTop = 259
    ExplicitWidth = 372
    inherited btnAccept: TButton
      Left = 163
      ExplicitLeft = 163
    end
    inherited btnClose: TButton
      Left = 267
      ExplicitLeft = 267
    end
  end
  inherited stbBase: TStatusBar
    Top = 289
    Width = 376
    ExplicitTop = 289
    ExplicitWidth = 376
  end
end

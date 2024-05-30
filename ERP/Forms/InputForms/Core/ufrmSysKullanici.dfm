inherited frmSysKullanici: TfrmSysKullanici
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem Kullan'#305'c'#305
  ClientHeight = 273
  ClientWidth = 366
  ParentFont = True
  ExplicitWidth = 382
  ExplicitHeight = 312
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 366
    Height = 223
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 366
    ExplicitHeight = 223
    inherited pgcMain: TPageControl
      Width = 366
      Height = 223
      ExplicitWidth = 366
      ExplicitHeight = 223
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 358
        ExplicitHeight = 193
        object lblkullanici_adi: TLabel
          Left = 41
          Top = 10
          Width = 67
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kullan'#305'c'#305' Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkullanici_sifre: TLabel
          Left = 24
          Top = 32
          Width = 84
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kullan'#305'c'#305' '#350'ifresi'
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
        object lblis_yonetici: TLabel
          Left = 57
          Top = 77
          Width = 51
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Y'#246'netici?'
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
          Top = 97
          Width = 88
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S'#252'per Kullan'#305'c'#305'?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblip_adres: TLabel
          Left = 57
          Top = 122
          Width = 51
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'IP Adresi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmac_adres: TLabel
          Left = 44
          Top = 144
          Width = 64
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'MAC Adresi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblpersonel_id: TLabel
          Left = 38
          Top = 166
          Width = 70
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Personel Ad'#305
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
          Height = 23
          TabOrder = 0
        end
        object edtkullanici_sifre: TEdit
          Left = 114
          Top = 29
          Width = 239
          Height = 23
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
        object chkis_yonetici: TCheckBox
          Left = 114
          Top = 76
          Width = 239
          Height = 17
          TabOrder = 3
        end
        object chkis_super_kullanici: TCheckBox
          Left = 114
          Top = 96
          Width = 239
          Height = 17
          TabOrder = 4
        end
        object edtip_adres: TEdit
          Left = 114
          Top = 119
          Width = 239
          Height = 23
          TabOrder = 5
        end
        object edtmac_adres: TEdit
          Left = 114
          Top = 141
          Width = 239
          Height = 23
          TabOrder = 6
        end
        object edtpersonel_id: TEdit
          Left = 114
          Top = 163
          Width = 239
          Height = 23
          TabOrder = 7
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 225
    Width = 362
    ExplicitTop = 225
    ExplicitWidth = 362
    inherited btnAccept: TButton
      Left = 156
      ExplicitLeft = 156
    end
    inherited btnClose: TButton
      Left = 260
      ExplicitLeft = 260
    end
  end
  inherited stbBase: TStatusBar
    Top = 255
    Width = 366
    ExplicitTop = 255
    ExplicitWidth = 366
  end
end

inherited frmSysGridKolon: TfrmSysGridKolon
  Left = 501
  Top = 443
  Caption = 'Sistem Grid Kolon'
  ClientHeight = 374
  ClientWidth = 595
  ParentFont = True
  ExplicitWidth = 611
  ExplicitHeight = 413
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 595
    Height = 324
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 595
    ExplicitHeight = 311
    inherited pgcMain: TPageControl
      Width = 595
      Height = 324
      ExplicitWidth = 595
      ExplicitHeight = 324
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 587
        ExplicitHeight = 294
        object lbltablo_adi: TLabel
          Left = 104
          Top = 5
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tablo Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkolon_adi: TLabel
          Left = 104
          Top = 27
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kolon Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkolon_genislik: TLabel
          Left = 112
          Top = 71
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Geni'#351'lik'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsira_no: TLabel
          Left = 117
          Top = 49
          Width = 39
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S'#305'ra No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_gorunur: TLabel
          Left = 110
          Top = 115
          Width = 46
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'G'#246'r'#252'n'#252'r'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_helper_gorunur: TLabel
          Left = 58
          Top = 137
          Width = 98
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yard'#305'mc'#305' G'#246'r'#252'n'#252'r'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmax_renk: TLabel
          Left = 62
          Top = 241
          Width = 94
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Maksimum Renk'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmax_deger: TLabel
          Left = 57
          Top = 219
          Width = 99
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Maksimum De'#287'er'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmin_renk: TLabel
          Left = 72
          Top = 197
          Width = 84
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Minimum Renk'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmin_deger: TLabel
          Left = 67
          Top = 175
          Width = 89
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Minimum De'#287'er'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object imgexample_bar: TImage
          Left = 329
          Top = 261
          Width = 246
          Height = 25
        end
        object lblbar_rengi: TLabel
          Left = 365
          Top = 197
          Width = 54
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Bar Rengi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblbar_arka_rengi: TLabel
          Left = 335
          Top = 219
          Width = 84
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Bar Arka Rengi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblbar_yazi_rengi: TLabel
          Left = 339
          Top = 241
          Width = 80
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Bar Yaz'#305' Rengi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmaks_deger_yuzdesi: TLabel
          Left = 270
          Top = 175
          Width = 149
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Maksimum Y'#252'zdelik De'#287'er'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblveri_formati: TLabel
          Left = 87
          Top = 93
          Width = 69
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Veri Format'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbtablo_adi: TComboBox
          Left = 162
          Top = 2
          Width = 239
          Height = 23
          TabOrder = 0
          OnChange = cbbtablo_adiChange
        end
        object cbbkolon_adi: TComboBox
          Left = 162
          Top = 24
          Width = 239
          Height = 23
          TabOrder = 1
        end
        object edtsira_no: TEdit
          Left = 162
          Top = 46
          Width = 150
          Height = 23
          TabOrder = 2
        end
        object edtkolon_genislik: TEdit
          Left = 162
          Top = 68
          Width = 150
          Height = 23
          TabOrder = 3
        end
        object edtveri_formati: TEdit
          Left = 162
          Top = 90
          Width = 150
          Height = 23
          TabOrder = 4
        end
        object chkis_gorunur: TCheckBox
          Left = 162
          Top = 112
          Width = 150
          Height = 21
          TabOrder = 5
        end
        object chkis_helper_gorunur: TCheckBox
          Left = 162
          Top = 134
          Width = 150
          Height = 21
          TabOrder = 6
        end
        object edtmin_deger: TEdit
          Left = 162
          Top = 172
          Width = 150
          Height = 23
          TabOrder = 7
        end
        object edtmin_renk: TEdit
          Left = 162
          Top = 194
          Width = 150
          Height = 23
          TabOrder = 9
          OnDblClick = edtmin_renkDblClick
        end
        object edtmax_deger: TEdit
          Left = 162
          Top = 216
          Width = 150
          Height = 23
          TabOrder = 11
        end
        object edtmax_renk: TEdit
          Left = 162
          Top = 238
          Width = 150
          Height = 23
          TabOrder = 13
          OnDblClick = edtmax_renkDblClick
        end
        object edtmaks_deger_yuzdesi: TEdit
          Left = 425
          Top = 172
          Width = 150
          Height = 23
          TabOrder = 8
        end
        object edtbar_rengi: TEdit
          Left = 425
          Top = 194
          Width = 150
          Height = 23
          TabOrder = 10
          OnDblClick = edtbar_rengiDblClick
        end
        object edtbar_arka_rengi: TEdit
          Left = 425
          Top = 216
          Width = 150
          Height = 23
          TabOrder = 12
          OnDblClick = edtbar_arka_rengiDblClick
        end
        object edtbar_yazi_rengi: TEdit
          Left = 425
          Top = 238
          Width = 150
          Height = 23
          TabOrder = 14
          OnDblClick = edtbar_yazi_rengiDblClick
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 326
    Width = 591
    ExplicitTop = 313
    ExplicitWidth = 591
    inherited btnAccept: TButton
      Left = 385
      ExplicitLeft = 385
    end
    inherited btnClose: TButton
      Left = 489
      ExplicitLeft = 489
    end
  end
  inherited stbBase: TStatusBar
    Top = 356
    Width = 595
    ExplicitTop = 343
    ExplicitWidth = 595
  end
end

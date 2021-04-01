inherited frmSysUserAccessRight: TfrmSysUserAccessRight
  Left = 501
  Top = 443
  Caption = 'Sistem Eri'#351'im Hakk'#305
  ClientHeight = 264
  ClientWidth = 375
  ParentFont = True
  ExplicitWidth = 381
  ExplicitHeight = 293
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 371
    Height = 198
    Color = clWindow
    ExplicitWidth = 371
    ExplicitHeight = 198
    inherited pgcMain: TPageControl
      Width = 369
      Height = 196
      ExplicitWidth = 369
      ExplicitHeight = 196
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 361
        ExplicitHeight = 168
        object lblkullanici_id: TLabel
          Left = 49
          Top = 6
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
        object lblkaynak_id: TLabel
          Left = 53
          Top = 28
          Width = 63
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kaynak Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_okuma: TLabel
          Left = 70
          Top = 53
          Width = 46
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Okuma?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_yeni_kayit: TLabel
          Left = 54
          Top = 76
          Width = 62
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yeni Kay'#305't?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_guncelleme: TLabel
          Left = 44
          Top = 99
          Width = 72
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'G'#252'ncelleme?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_silme: TLabel
          Left = 79
          Top = 122
          Width = 37
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Silme?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_ozel: TLabel
          Left = 86
          Top = 145
          Width = 30
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'zel?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtkullanici_id: TEdit
          Left = 122
          Top = 3
          Width = 224
          Height = 21
          TabOrder = 0
        end
        object edtkaynak_id: TEdit
          Left = 122
          Top = 25
          Width = 224
          Height = 21
          TabOrder = 1
        end
        object chkis_okuma: TCheckBox
          Left = 122
          Top = 52
          Width = 223
          Height = 17
          TabOrder = 2
        end
        object chkis_yeni_kayit: TCheckBox
          Left = 122
          Top = 75
          Width = 223
          Height = 17
          TabOrder = 3
        end
        object chkis_guncelleme: TCheckBox
          Left = 122
          Top = 98
          Width = 223
          Height = 17
          TabOrder = 4
        end
        object chkis_silme: TCheckBox
          Left = 122
          Top = 121
          Width = 223
          Height = 17
          TabOrder = 5
        end
        object chkis_ozel: TCheckBox
          Left = 122
          Top = 144
          Width = 223
          Height = 17
          TabOrder = 6
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 202
    Width = 371
    ExplicitTop = 202
    ExplicitWidth = 371
    inherited btnAccept: TButton
      Left = 162
      ExplicitLeft = 162
    end
    inherited btnClose: TButton
      Left = 266
      ExplicitLeft = 266
    end
  end
  inherited stbBase: TStatusBar
    Top = 246
    Width = 375
    ExplicitTop = 246
    ExplicitWidth = 375
  end
end

inherited frmSysErisimHakki: TfrmSysErisimHakki
  Left = 501
  Top = 443
  Caption = 'Eri'#351'im Hakk'#305
  ClientHeight = 249
  ClientWidth = 359
  ParentFont = True
  ExplicitWidth = 375
  ExplicitHeight = 288
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 359
    Height = 199
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 359
    ExplicitHeight = 199
    inherited pgcMain: TPageControl
      Width = 359
      Height = 199
      ExplicitWidth = 359
      ExplicitHeight = 199
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 351
        ExplicitHeight = 169
        object lblkullanici_id: TLabel
          Left = 49
          Top = 7
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
          Top = 29
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
          Left = 76
          Top = 53
          Width = 40
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Okuma'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_ekleme: TLabel
          Left = 60
          Top = 76
          Width = 56
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yeni Kay'#305't'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_guncelleme: TLabel
          Left = 50
          Top = 99
          Width = 66
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'G'#252'ncelleme'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_silme: TLabel
          Left = 85
          Top = 122
          Width = 31
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Silme'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_ozel: TLabel
          Left = 92
          Top = 145
          Width = 24
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'zel'
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
          Height = 23
          TabOrder = 0
        end
        object edtkaynak_id: TEdit
          Left = 122
          Top = 25
          Width = 224
          Height = 23
          TabOrder = 1
        end
        object chkis_okuma: TCheckBox
          Left = 122
          Top = 52
          Width = 223
          Height = 17
          TabOrder = 2
        end
        object chkis_ekleme: TCheckBox
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
    Top = 201
    Width = 355
    ExplicitTop = 201
    ExplicitWidth = 355
    inherited btnAccept: TButton
      Left = 149
      ExplicitLeft = 149
    end
    inherited btnClose: TButton
      Left = 253
      ExplicitLeft = 253
    end
  end
  inherited stbBase: TStatusBar
    Top = 231
    Width = 359
    ExplicitTop = 231
    ExplicitWidth = 359
  end
end

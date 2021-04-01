inherited frmSysSehir: TfrmSysSehir
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem '#350'ehir'
  ClientHeight = 166
  ClientWidth = 376
  ParentFont = True
  ExplicitWidth = 382
  ExplicitHeight = 195
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 372
    Height = 100
    Color = clWindow
    ExplicitWidth = 372
    ExplicitHeight = 100
    inherited pgcMain: TPageControl
      Width = 370
      Height = 98
      ExplicitWidth = 370
      ExplicitHeight = 98
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 362
        ExplicitHeight = 70
        object lblulke_adi_id: TLabel
          Left = 62
          Top = 5
          Width = 46
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'lke Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsehir_adi: TLabel
          Left = 58
          Top = 27
          Width = 50
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #350'ehir Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblplaka_kodu: TLabel
          Left = 46
          Top = 49
          Width = 62
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Plaka Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbulke_adi_id: TComboBox
          Left = 114
          Top = 2
          Width = 239
          Height = 21
          TabOrder = 0
        end
        object edtsehir_adi: TEdit
          Left = 114
          Top = 24
          Width = 239
          Height = 21
          TabOrder = 1
        end
        object edtplaka_kodu: TEdit
          Left = 114
          Top = 46
          Width = 239
          Height = 21
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 104
    Width = 372
    ExplicitTop = 104
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
    Top = 148
    Width = 376
    ExplicitTop = 148
    ExplicitWidth = 376
  end
end

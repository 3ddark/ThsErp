inherited frmSetEinvIstisnaKodu: TfrmSetEinvIstisnaKodu
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = #304'stisna Kodu'
  ClientHeight = 196
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 360
  ExplicitHeight = 235
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 344
    Height = 146
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 145
    inherited pgcMain: TPageControl
      Width = 344
      Height = 146
      ExplicitWidth = 338
      ExplicitHeight = 143
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 336
        ExplicitHeight = 117
        object lblkod: TLabel
          Left = 85
          Top = 6
          Width = 21
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kod'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblaciklama: TLabel
          Left = 56
          Top = 28
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
        object lblfatura_tipi_id: TLabel
          Left = 49
          Top = 50
          Width = 57
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Fatura Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_tam_istisna: TLabel
          Left = 36
          Top = 72
          Width = 70
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tam '#304'stisna?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtkod: TEdit
          Left = 110
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtaciklama: TEdit
          Left = 110
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object cbbfatura_tipi_id: TComboBox
          Left = 110
          Top = 47
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object chkis_tam_istisna: TCheckBox
          Left = 110
          Top = 72
          Width = 200
          Height = 17
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 148
    Width = 340
    ExplicitTop = 149
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      ExplicitLeft = 131
    end
    inherited btnClose: TButton
      Left = 235
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 178
    Width = 344
    ExplicitTop = 193
    ExplicitWidth = 344
  end
end

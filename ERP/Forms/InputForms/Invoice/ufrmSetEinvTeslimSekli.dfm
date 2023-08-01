inherited frmSetEinvTeslimSekli: TfrmSetEinvTeslimSekli
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Teslim Sekli'
  ClientHeight = 195
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 360
  ExplicitHeight = 234
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 344
    Height = 145
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 129
    inherited pgcMain: TPageControl
      Width = 344
      Height = 145
      ExplicitWidth = 338
      ExplicitHeight = 127
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 117
        object lblis_active: TLabel
          Left = 92
          Top = 3
          Width = 27
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Aktif'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkod: TLabel
          Left = 96
          Top = 27
          Width = 23
          Height = 13
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
          Left = 67
          Top = 49
          Width = 52
          Height = 13
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
        object lblis_efatura: TLabel
          Left = 70
          Top = 72
          Width = 49
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'E-Fatura'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object chkis_active: TCheckBox
          Left = 120
          Top = 2
          Width = 200
          Height = 17
          TabOrder = 0
        end
        object edtkod: TEdit
          Left = 120
          Top = 24
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtaciklama: TEdit
          Left = 120
          Top = 46
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object chkis_efatura: TCheckBox
          Left = 120
          Top = 71
          Width = 200
          Height = 17
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 147
    Width = 340
    ExplicitTop = 133
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
    Top = 177
    Width = 344
    ExplicitTop = 177
    ExplicitWidth = 344
  end
end

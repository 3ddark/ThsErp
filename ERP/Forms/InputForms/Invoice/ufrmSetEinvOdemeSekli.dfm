inherited frmSetEinvOdemeSekli: TfrmSetEinvOdemeSekli
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = #214'deme '#350'ekli'
  ClientHeight = 209
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 360
  ExplicitHeight = 248
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 344
    Height = 159
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 342
    ExplicitHeight = 151
    inherited pgcMain: TPageControl
      Width = 344
      Height = 159
      ExplicitWidth = 342
      ExplicitHeight = 151
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 131
        object lblodeme_sekli: TLabel
          Left = 46
          Top = 23
          Width = 72
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'deme '#350'ekli'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkod: TLabel
          Left = 95
          Top = 45
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
          Left = 66
          Top = 67
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
          Left = 69
          Top = 87
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
        object edtodeme_sekli: TEdit
          Left = 119
          Top = 20
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtkod: TEdit
          Left = 119
          Top = 42
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtaciklama: TEdit
          Left = 119
          Top = 64
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object chkis_efatura: TCheckBox
          Left = 119
          Top = 86
          Width = 198
          Height = 17
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 161
    Width = 340
    ExplicitTop = 153
    ExplicitWidth = 338
    inherited btnAccept: TButton
      Left = 134
      ExplicitLeft = 132
    end
    inherited btnClose: TButton
      Left = 238
      ExplicitLeft = 236
    end
  end
  inherited stbBase: TStatusBar
    Top = 191
    Width = 344
    ExplicitTop = 183
    ExplicitWidth = 342
  end
end

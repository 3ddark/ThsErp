inherited frmSetOdemeBaslangicDonemi: TfrmSetOdemeBaslangicDonemi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Set '#214'deme Ba'#351'lang'#305#231' D'#246'nemi'
  ClientHeight = 166
  ClientWidth = 340
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 356
  ExplicitHeight = 205
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 340
    Height = 116
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 122
    inherited pgcMain: TPageControl
      Width = 340
      Height = 116
      ExplicitWidth = 338
      ExplicitHeight = 120
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 332
        ExplicitHeight = 87
        object lblaciklama: TLabel
          Left = 38
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
        object lblodeme_baslangic_donemi: TLabel
          Left = 55
          Top = 6
          Width = 33
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'De'#287'er'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_aktif: TLabel
          Left = 55
          Top = 50
          Width = 33
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Aktif?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object chkis_aktif: TCheckBox
          Left = 92
          Top = 49
          Width = 200
          Height = 17
          TabOrder = 2
        end
        object edtaciklama: TEdit
          Left = 92
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtodeme_baslangic_donemi: TEdit
          Left = 92
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 118
    Width = 336
    ExplicitTop = 126
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
    Top = 148
    Width = 340
    ExplicitTop = 156
    ExplicitWidth = 344
  end
end

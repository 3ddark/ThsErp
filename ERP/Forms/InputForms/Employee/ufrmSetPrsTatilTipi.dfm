inherited frmSetPrsTatilTipi: TfrmSetPrsTatilTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Tatil Tipi'
  ClientHeight = 147
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 176
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 81
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 81
    inherited pgcMain: TPageControl
      Width = 338
      Height = 79
      ExplicitWidth = 338
      ExplicitHeight = 79
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 330
        ExplicitHeight = 51
        object lbltatil_tipi: TLabel
          Left = 24
          Top = 6
          Width = 75
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Holiday Type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_resmi_tatil: TLabel
          Left = 10
          Top = 27
          Width = 89
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Public Holiday?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edttatil_tipi: TEdit
          Left = 103
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object chkis_resmi_tatil: TCheckBox
          Left = 103
          Top = 26
          Width = 200
          Height = 17
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 85
    Width = 340
    ExplicitTop = 85
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
    Top = 129
    Width = 344
    ExplicitTop = 129
    ExplicitWidth = 344
  end
end

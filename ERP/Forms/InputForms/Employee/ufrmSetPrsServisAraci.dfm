inherited frmSetPrsServisAraci: TfrmSetPrsServisAraci
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Ta'#351#305'ma Servisi'
  ClientHeight = 152
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 181
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 86
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 86
    inherited pgcMain: TPageControl
      Width = 338
      Height = 84
      ExplicitWidth = 338
      ExplicitHeight = 84
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 330
        ExplicitHeight = 56
        object lblarac_no: TLabel
          Left = 37
          Top = 6
          Width = 56
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Servis No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblarac_adi: TLabel
          Left = 35
          Top = 28
          Width = 58
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Servis Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtarac_no: TEdit
          Left = 97
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtarac_adi: TEdit
          Left = 97
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 90
    Width = 340
    ExplicitTop = 90
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
    Top = 134
    Width = 344
    ExplicitTop = 134
    ExplicitWidth = 344
  end
end

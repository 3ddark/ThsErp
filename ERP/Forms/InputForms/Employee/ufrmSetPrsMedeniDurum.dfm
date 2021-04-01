inherited frmSetPrsMedeniDurum: TfrmSetPrsMedeniDurum
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Medeni Durum'
  ClientHeight = 145
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 174
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 79
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 79
    inherited pgcMain: TPageControl
      Width = 338
      Height = 77
      ExplicitWidth = 338
      ExplicitHeight = 77
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 330
        ExplicitHeight = 49
        object lblmedeni_durum: TLabel
          Left = 59
          Top = 6
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Marital Type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_evli: TLabel
          Left = 80
          Top = 31
          Width = 50
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Married?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtmedeni_durum: TEdit
          Left = 130
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object chkis_evli: TCheckBox
          Left = 130
          Top = 30
          Width = 200
          Height = 17
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 83
    Width = 340
    ExplicitTop = 83
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
    Top = 127
    Width = 344
    ExplicitTop = 127
    ExplicitWidth = 344
  end
end

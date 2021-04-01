inherited frmSetUtdDokumanTipi: TfrmSetUtdDokumanTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'UTD Dok'#252'man Tipi'
  ClientHeight = 149
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 178
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 83
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 83
    inherited pgcMain: TPageControl
      Width = 338
      Height = 81
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 338
      ExplicitHeight = 81
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 53
        object lblalt_klasor: TLabel
          Left = 101
          Top = 27
          Width = 48
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'K'#305'saltma'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldokuman_tipi: TLabel
          Left = 70
          Top = 5
          Width = 79
          Height = 13
          Alignment = taRightJustify
          Caption = 'Dok'#252'man Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtdokuman_tipi: TEdit
          Left = 152
          Top = 2
          Width = 145
          Height = 21
          TabOrder = 0
        end
        object edtalt_klasor: TEdit
          Left = 152
          Top = 24
          Width = 145
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 87
    Width = 340
    ExplicitTop = 87
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      Caption = 'KAYDET'
      ExplicitLeft = 131
    end
    inherited btnDelete: TButton
      Caption = 'S'#304'L'
    end
    inherited btnClose: TButton
      Left = 235
      Caption = 'KAPAT'
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 131
    Width = 344
    ExplicitTop = 131
    ExplicitWidth = 344
  end
  inherited AppEvntsBase: TApplicationEvents
    Left = 376
    Top = 40
  end
  inherited dlgPntBase: TPrintDialog
    Left = 464
    Top = 40
  end
  inherited pmLabels: TPopupMenu
    Left = 400
    Top = 88
  end
end

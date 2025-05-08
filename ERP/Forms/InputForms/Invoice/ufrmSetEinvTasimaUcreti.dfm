inherited frmSetEinvTasimaUcreti: TfrmSetEinvTasimaUcreti
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ta'#351#305'ma '#220'creti'
  ClientHeight = 144
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 360
  ExplicitHeight = 183
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 344
    Height = 94
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 344
    ExplicitHeight = 94
    inherited pgcMain: TPageControl
      Width = 344
      Height = 94
      ExplicitWidth = 344
      ExplicitHeight = 94
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 66
        object lbltasima_ucreti: TLabel
          Left = 35
          Top = 5
          Width = 81
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Nakliye '#220'creti'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edttasima_ucreti: TEdit
          Left = 120
          Top = 2
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 96
    Width = 340
    ExplicitTop = 96
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 134
      ExplicitLeft = 134
    end
    inherited btnClose: TButton
      Left = 238
      ExplicitLeft = 238
    end
  end
  inherited stbBase: TStatusBar
    Top = 126
    Width = 344
    ExplicitTop = 126
    ExplicitWidth = 344
  end
end

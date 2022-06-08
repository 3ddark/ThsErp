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
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 92
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 78
    inherited pgcMain: TPageControl
      Width = 338
      Height = 90
      ExplicitWidth = 338
      ExplicitHeight = 76
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 62
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
        object lblis_active: TLabel
          Left = 87
          Top = 26
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
        object edttasima_ucreti: TEdit
          Left = 120
          Top = 2
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object chkis_active: TCheckBox
          Left = 120
          Top = 25
          Width = 198
          Height = 17
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 96
    Width = 340
    ExplicitTop = 82
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
    Top = 126
    Width = 344
    ExplicitTop = 126
    ExplicitWidth = 344
  end
end

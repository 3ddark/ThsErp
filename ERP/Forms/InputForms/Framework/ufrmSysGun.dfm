inherited frmSysGun: TfrmSysGun
  Left = 501
  Top = 443
  Caption = 'Sistem G'#252'n'
  ClientHeight = 121
  ClientWidth = 354
  ParentFont = True
  ExplicitWidth = 360
  ExplicitHeight = 150
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 350
    Height = 55
    Color = clWindow
    ExplicitWidth = 350
    ExplicitHeight = 58
    inherited pgcMain: TPageControl
      Width = 348
      Height = 53
      ExplicitWidth = 348
      ExplicitHeight = 56
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 340
        ExplicitHeight = 28
        object lblgun_adi: TLabel
          Left = 65
          Top = 5
          Width = 43
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'G'#252'n Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtgun_adi: TEdit
          Left = 114
          Top = 2
          Width = 223
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 59
    Width = 350
    ExplicitTop = 62
    ExplicitWidth = 350
    inherited btnAccept: TButton
      Left = 141
      ExplicitLeft = 141
    end
    inherited btnClose: TButton
      Left = 245
      ExplicitLeft = 245
    end
  end
  inherited stbBase: TStatusBar
    Top = 103
    Width = 354
    ExplicitTop = 106
    ExplicitWidth = 354
  end
end

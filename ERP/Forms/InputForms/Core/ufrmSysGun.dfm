inherited frmSysGun: TfrmSysGun
  Left = 501
  Top = 443
  Caption = 'Sistem G'#252'n'
  ClientHeight = 115
  ClientWidth = 352
  ParentFont = True
  ExplicitWidth = 368
  ExplicitHeight = 154
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 352
    Height = 65
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 352
    ExplicitHeight = 65
    inherited pgcMain: TPageControl
      Width = 352
      Height = 65
      ExplicitWidth = 352
      ExplicitHeight = 65
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 344
        ExplicitHeight = 35
        object lblgun_adi: TLabel
          Left = 65
          Top = 6
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
          Height = 23
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 67
    Width = 348
    ExplicitTop = 67
    ExplicitWidth = 348
    inherited btnAccept: TButton
      Left = 142
      ExplicitLeft = 142
    end
    inherited btnClose: TButton
      Left = 246
      ExplicitLeft = 246
    end
  end
  inherited stbBase: TStatusBar
    Top = 97
    Width = 352
    ExplicitTop = 97
    ExplicitWidth = 352
  end
end

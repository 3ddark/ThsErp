inherited frmSetEmpLanguageLevel: TfrmSetEmpLanguageLevel
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Lisan Seviyesi'
  ClientHeight = 117
  ClientWidth = 360
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 376
  ExplicitHeight = 156
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 360
    Height = 67
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 358
    ExplicitHeight = 55
    inherited pgcMain: TPageControl
      Width = 362
      Height = 71
      ExplicitWidth = 356
      ExplicitHeight = 53
      inherited tsMain: TTabSheet
        ExplicitWidth = 354
        ExplicitHeight = 43
        object lbllisan_seviyesi: TLabel
          Left = 61
          Top = 6
          Width = 82
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Lisan Seviyesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtlisan_seviyesi: TEdit
          Left = 148
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 69
    Width = 356
    ExplicitTop = 59
    ExplicitWidth = 358
    inherited btnAccept: TButton
      Left = 149
      ExplicitLeft = 149
    end
    inherited btnClose: TButton
      Left = 253
      ExplicitLeft = 253
    end
  end
  inherited stbBase: TStatusBar
    Top = 99
    Width = 360
    ExplicitTop = 103
    ExplicitWidth = 362
  end
end

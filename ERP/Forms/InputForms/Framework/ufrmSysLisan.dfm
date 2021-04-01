inherited frmSysLisan: TfrmSysLisan
  Left = 501
  Top = 443
  Caption = 'Sistem Lisan'
  ClientHeight = 121
  ClientWidth = 359
  ParentFont = True
  ExplicitWidth = 365
  ExplicitHeight = 150
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 355
    Height = 55
    Color = clWindow
    ExplicitWidth = 355
    ExplicitHeight = 55
    inherited pgcMain: TPageControl
      Width = 353
      Height = 53
      ExplicitWidth = 353
      ExplicitHeight = 53
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 345
        ExplicitHeight = 25
        object lbllisan: TLabel
          Left = 53
          Top = 5
          Width = 55
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Language'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtlisan: TEdit
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
    Width = 355
    ExplicitTop = 59
    ExplicitWidth = 355
    inherited btnAccept: TButton
      Left = 146
      ExplicitLeft = 146
    end
    inherited btnClose: TButton
      Left = 250
      ExplicitLeft = 250
    end
  end
  inherited stbBase: TStatusBar
    Top = 103
    Width = 359
    ExplicitTop = 103
    ExplicitWidth = 359
  end
end

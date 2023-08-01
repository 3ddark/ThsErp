inherited frmSysLang: TfrmSysLang
  Left = 501
  Top = 443
  Caption = 'System Language'
  ClientHeight = 113
  ClientWidth = 355
  ParentFont = True
  ExplicitWidth = 371
  ExplicitHeight = 152
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 355
    Height = 63
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 359
    ExplicitHeight = 71
    inherited pgcMain: TPageControl
      Width = 357
      Height = 67
      ExplicitWidth = 357
      ExplicitHeight = 67
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 349
        ExplicitHeight = 37
        object lbllang: TLabel
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
        object edtlang: TEdit
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
    Top = 65
    Width = 351
    ExplicitTop = 73
    ExplicitWidth = 355
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
    Top = 95
    Width = 355
    ExplicitTop = 103
    ExplicitWidth = 359
  end
end

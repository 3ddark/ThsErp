inherited frmSysLangDataContent: TfrmSysLangDataContent
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'System Language Data Content'
  ClientHeight = 127
  ClientWidth = 398
  ParentFont = True
  ExplicitWidth = 412
  ExplicitHeight = 162
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 398
    Height = 77
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 396
    ExplicitHeight = 73
    inherited pgcMain: TPageControl
      Width = 398
      Height = 77
      ExplicitWidth = 396
      ExplicitHeight = 73
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 390
        ExplicitHeight = 47
        object lbllang: TLabel
          Left = 87
          Top = 7
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
        object lblvalue: TLabel
          Left = 111
          Top = 29
          Width = 31
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Value'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtlang: TEdit
          Left = 146
          Top = 4
          Width = 240
          Height = 23
          TabOrder = 0
        end
        object edtvalue: TEdit
          Left = 146
          Top = 26
          Width = 240
          Height = 23
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 79
    Width = 394
    ExplicitTop = 75
    ExplicitWidth = 392
    inherited btnAccept: TButton
      Left = 188
      ExplicitLeft = 186
    end
    inherited btnClose: TButton
      Left = 292
      ExplicitLeft = 290
    end
  end
  inherited stbBase: TStatusBar
    Top = 109
    Width = 398
    ExplicitTop = 105
    ExplicitWidth = 396
  end
end

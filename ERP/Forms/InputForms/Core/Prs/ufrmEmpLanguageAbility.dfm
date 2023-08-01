inherited frmEmpLanguageAbility: TfrmEmpLanguageAbility
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Employee Language Ability'
  ClientHeight = 215
  ClientWidth = 425
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 441
  ExplicitHeight = 254
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 425
    Height = 165
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 433
    ExplicitHeight = 173
    inherited pgcMain: TPageControl
      Width = 427
      Height = 169
      ExplicitWidth = 431
      ExplicitHeight = 171
      inherited tsMain: TTabSheet
        ExplicitWidth = 419
        ExplicitHeight = 141
        object lblemp_lang_id: TLabel
          Left = 79
          Top = 6
          Width = 57
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Language'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblread_level_id: TLabel
          Left = 70
          Top = 28
          Width = 66
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Read Level'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblwrite_level_id: TLabel
          Left = 70
          Top = 50
          Width = 66
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Write Level'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblspeak_level_id: TLabel
          Left = 64
          Top = 72
          Width = 72
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Speak Level'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_card_id: TLabel
          Left = 45
          Top = 94
          Width = 91
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Employee Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbemp_lang_id: TComboBox
          Left = 140
          Top = 3
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 0
        end
        object cbbread_level_id: TComboBox
          Left = 140
          Top = 25
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 1
        end
        object cbbwrite_level_id: TComboBox
          Left = 140
          Top = 47
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 2
        end
        object cbbspeak_level_id: TComboBox
          Left = 140
          Top = 69
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 3
        end
        object cbbemp_card_id: TComboBox
          Left = 140
          Top = 91
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 4
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 167
    Width = 421
    ExplicitTop = 177
    ExplicitWidth = 433
    inherited btnAccept: TButton
      Left = 224
      ExplicitLeft = 224
    end
    inherited btnClose: TButton
      Left = 328
      ExplicitLeft = 328
    end
  end
  inherited stbBase: TStatusBar
    Top = 197
    Width = 425
    ExplicitTop = 221
    ExplicitWidth = 437
  end
end

inherited frmEmpLanguageAbility: TfrmEmpLanguageAbility
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Employee Language Ability'
  ClientHeight = 209
  ClientWidth = 421
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 437
  ExplicitHeight = 248
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 421
    Height = 159
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 423
    ExplicitHeight = 162
    inherited pgcMain: TPageControl
      Width = 423
      Height = 162
      ExplicitWidth = 423
      ExplicitHeight = 162
      inherited tsMain: TTabSheet
        ExplicitWidth = 415
        ExplicitHeight = 134
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
    Top = 161
    Width = 417
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
    Top = 191
    Width = 421
    ExplicitTop = 221
    ExplicitWidth = 437
  end
end

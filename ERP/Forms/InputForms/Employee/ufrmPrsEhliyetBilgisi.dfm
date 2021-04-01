inherited frmEmpDriverLicenseAbility: TfrmEmpDriverLicenseAbility
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Employee Driver License Ability'
  ClientHeight = 175
  ClientWidth = 362
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 368
  ExplicitHeight = 204
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 358
    Height = 123
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 358
    ExplicitHeight = 109
    inherited pgcMain: TPageControl
      Width = 356
      Height = 121
      ExplicitWidth = 356
      ExplicitHeight = 107
      inherited tsMain: TTabSheet
        ExplicitWidth = 348
        ExplicitHeight = 93
        object lbldriver_license_id: TLabel
          Left = 53
          Top = 6
          Width = 83
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Driver License'
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
          Top = 28
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
        object lblis_active: TLabel
          Left = 92
          Top = 52
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Active?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbdriver_license_id: TComboBox
          Left = 140
          Top = 3
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 0
        end
        object cbbemp_card_id: TComboBox
          Left = 140
          Top = 25
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 1
        end
        object chkis_active: TCheckBox
          Left = 140
          Top = 51
          Width = 200
          Height = 17
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 127
    Width = 358
    ExplicitTop = 113
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
    Top = 157
    Width = 362
    ExplicitTop = 157
    ExplicitWidth = 362
  end
end

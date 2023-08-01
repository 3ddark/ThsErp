inherited frmEmpDrivingLicence: TfrmEmpDrivingLicence
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Employee Driver License Ability'
  ClientHeight = 159
  ClientWidth = 354
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 370
  ExplicitHeight = 198
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 354
    Height = 109
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 360
    ExplicitHeight = 121
    inherited pgcMain: TPageControl
      Width = 356
      Height = 113
      ExplicitWidth = 360
      ExplicitHeight = 121
      inherited tsMain: TTabSheet
        ExplicitWidth = 348
        ExplicitHeight = 85
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
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 111
    Width = 350
    ExplicitTop = 123
    ExplicitWidth = 356
    inherited btnAccept: TButton
      Left = 150
      ExplicitLeft = 150
    end
    inherited btnClose: TButton
      Left = 254
      ExplicitLeft = 254
    end
  end
  inherited stbBase: TStatusBar
    Top = 141
    Width = 354
    ExplicitTop = 153
    ExplicitWidth = 360
  end
end

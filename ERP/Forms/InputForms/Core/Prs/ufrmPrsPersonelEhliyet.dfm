inherited frmPrsPersonelEhliyet: TfrmPrsPersonelEhliyet
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Ehliyeti'
  ClientHeight = 153
  ClientWidth = 350
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 366
  ExplicitHeight = 192
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 350
    Height = 103
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 352
    ExplicitHeight = 106
    inherited pgcMain: TPageControl
      Width = 352
      Height = 106
      ExplicitWidth = 352
      ExplicitHeight = 106
      inherited tsMain: TTabSheet
        ExplicitWidth = 344
        ExplicitHeight = 78
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
    Top = 105
    Width = 346
    ExplicitTop = 108
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
    Top = 135
    Width = 350
    ExplicitTop = 138
    ExplicitWidth = 352
  end
end

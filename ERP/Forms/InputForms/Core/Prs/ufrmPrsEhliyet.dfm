inherited frmPrsEhliyet: TfrmPrsEhliyet
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Ehliyeti'
  ClientHeight = 153
  ClientWidth = 350
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 356
  ExplicitHeight = 182
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 350
    Height = 103
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 350
    ExplicitHeight = 103
    inherited pgcMain: TPageControl
      Width = 350
      Height = 103
      ExplicitWidth = 350
      ExplicitHeight = 103
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 342
        ExplicitHeight = 75
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
    ExplicitTop = 105
    ExplicitWidth = 346
    inherited btnAccept: TButton
      Left = 140
      ExplicitLeft = 140
    end
    inherited btnClose: TButton
      Left = 244
      ExplicitLeft = 244
    end
  end
  inherited stbBase: TStatusBar
    Top = 135
    Width = 350
    ExplicitTop = 135
    ExplicitWidth = 350
  end
end

inherited frmPrsEhliyet: TfrmPrsEhliyet
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Ehliyeti'
  ClientHeight = 133
  ClientWidth = 350
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 364
  ExplicitHeight = 169
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 350
    Height = 83
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 348
    ExplicitHeight = 100
    inherited pgcMain: TPageControl
      Width = 350
      Height = 83
      ExplicitWidth = 348
      ExplicitHeight = 100
      inherited tsMain: TTabSheet
        ExplicitWidth = 342
        ExplicitHeight = 55
        object lblehliyet_id: TLabel
          Left = 65
          Top = 6
          Width = 39
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ehliyet'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblpersonel_id: TLabel
          Left = 54
          Top = 28
          Width = 50
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Personel'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbehliyet_id: TComboBox
          Left = 108
          Top = 3
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 0
        end
        object cbbpersonel_id: TComboBox
          Left = 108
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
    Top = 85
    Width = 346
    ExplicitTop = 102
    ExplicitWidth = 344
    inherited btnAccept: TButton
      Left = 140
      ExplicitLeft = 138
    end
    inherited btnClose: TButton
      Left = 244
      ExplicitLeft = 242
    end
  end
  inherited stbBase: TStatusBar
    Top = 115
    Width = 350
    ExplicitTop = 132
    ExplicitWidth = 348
  end
end

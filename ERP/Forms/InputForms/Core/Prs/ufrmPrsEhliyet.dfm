inherited frmPrsEhliyet: TfrmPrsEhliyet
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Ehliyeti'
  ClientHeight = 133
  ClientWidth = 350
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 366
  ExplicitHeight = 172
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 350
    Height = 83
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 350
    ExplicitHeight = 83
    inherited pgcMain: TPageControl
      Width = 350
      Height = 83
      ExplicitWidth = 350
      ExplicitHeight = 83
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 342
        ExplicitHeight = 54
        object lblehliyet_id: TLabel
          Left = 68
          Top = 6
          Width = 36
          Height = 14
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
          Height = 14
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
          Style = csDropDownList
          TabOrder = 0
        end
        object edtpersonel_id: TEdit
          Left = 108
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 85
    Width = 346
    ExplicitTop = 85
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
    Top = 115
    Width = 350
    ExplicitTop = 115
    ExplicitWidth = 350
  end
end

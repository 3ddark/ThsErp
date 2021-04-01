inherited frmChTemsilciGrup: TfrmChTemsilciGrup
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Temilci Grup'
  ClientHeight = 150
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 179
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 98
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 84
    inherited pgcMain: TPageControl
      Width = 338
      Height = 96
      ExplicitWidth = 338
      ExplicitHeight = 82
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 54
        object lbltemsilci_grup_turu_id: TLabel
          Left = 19
          Top = 6
          Width = 102
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Temilci Grup T'#252'r'#252
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltemsilci_grup: TLabel
          Left = 49
          Top = 28
          Width = 72
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Temilci Grup'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbtemsilci_grup_turu_id: TComboBox
          Left = 125
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
          Text = 'cbbtemsilci_grup_turu_id'
        end
        object edttemsilci_grup: TEdit
          Left = 125
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 102
    Width = 340
    ExplicitTop = 88
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      ExplicitLeft = 131
    end
    inherited btnClose: TButton
      Left = 235
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 132
    Width = 344
    ExplicitTop = 132
    ExplicitWidth = 344
  end
end

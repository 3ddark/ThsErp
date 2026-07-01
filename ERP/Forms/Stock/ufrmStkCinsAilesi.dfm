inherited frmStkCinsAilesi: TfrmStkCinsAilesi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Cins Ailesi'
  ClientHeight = 130
  ClientWidth = 348
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  StyleElements = [seFont, seClient, seBorder]
  ExplicitWidth = 364
  ExplicitHeight = 169
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 348
    Height = 80
    Color = clWindow
    ParentColor = False
    StyleElements = [seFont, seClient, seBorder]
    ExplicitWidth = 348
    ExplicitHeight = 80
    inherited pgcMain: TPageControl
      Width = 348
      Height = 80
      ExplicitWidth = 348
      ExplicitHeight = 80
      inherited tsMain: TTabSheet
        ExplicitWidth = 340
        ExplicitHeight = 52
        object lblfamily: TLabel
          Left = 66
          Top = 6
          Width = 22
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Aile'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtfamily: TEdit
          Left = 92
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 82
    Width = 344
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 82
    ExplicitWidth = 344
    inherited btnAccept: TButton
      Left = 138
      ExplicitLeft = 138
    end
    inherited btnClose: TButton
      Left = 242
      ExplicitLeft = 242
    end
  end
  inherited stbBase: TStatusBar
    Top = 112
    Width = 348
    ExplicitTop = 112
    ExplicitWidth = 348
  end
end

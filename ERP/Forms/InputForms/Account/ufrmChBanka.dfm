inherited frmChBanka: TfrmChBanka
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Banka'
  ClientHeight = 126
  ClientWidth = 342
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 356
  ExplicitHeight = 161
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 342
    Height = 76
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 72
    inherited pgcMain: TPageControl
      Width = 342
      Height = 76
      ExplicitWidth = 340
      ExplicitHeight = 72
      inherited tsMain: TTabSheet
        ExplicitWidth = 334
        ExplicitHeight = 48
        object lblbanka_adi: TLabel
          Left = 78
          Top = 6
          Width = 19
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblswift_kodu: TLabel
          Left = 35
          Top = 28
          Width = 62
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Swift Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtbanka_adi: TEdit
          Left = 101
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtswift_kodu: TEdit
          Left = 101
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 78
    Width = 338
    ExplicitTop = 74
    ExplicitWidth = 336
    inherited btnAccept: TButton
      Left = 132
      ExplicitLeft = 130
    end
    inherited btnClose: TButton
      Left = 236
      ExplicitLeft = 234
    end
  end
  inherited stbBase: TStatusBar
    Top = 108
    Width = 342
    ExplicitTop = 104
    ExplicitWidth = 340
  end
end

inherited frmChBanka: TfrmChBanka
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Banka'
  ClientHeight = 168
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 360
  ExplicitHeight = 207
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 116
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 102
    inherited pgcMain: TPageControl
      Width = 338
      Height = 114
      ExplicitWidth = 338
      ExplicitHeight = 100
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 86
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
        object lblis_active: TLabel
          Left = 63
          Top = 50
          Width = 34
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Aktif?'
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
        object chkis_active: TCheckBox
          Left = 101
          Top = 49
          Width = 200
          Height = 17
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 120
    Width = 340
    ExplicitTop = 106
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
    Top = 150
    Width = 344
    ExplicitTop = 150
    ExplicitWidth = 344
  end
end

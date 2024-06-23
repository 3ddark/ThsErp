inherited frmSetPrsLisanSeviyesi: TfrmSetPrsLisanSeviyesi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Lisan Seviyesi'
  ClientHeight = 117
  ClientWidth = 360
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 376
  ExplicitHeight = 156
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 360
    Height = 67
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 358
    ExplicitHeight = 64
    inherited pgcMain: TPageControl
      Width = 360
      Height = 67
      ExplicitWidth = 358
      ExplicitHeight = 64
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 352
        ExplicitHeight = 38
        object lbllisan_seviyesi: TLabel
          Left = 64
          Top = 6
          Width = 79
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Lisan Seviyesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtlisan_seviyesi: TEdit
          Left = 148
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 69
    Width = 356
    ExplicitTop = 66
    ExplicitWidth = 354
    inherited btnAccept: TButton
      Left = 150
      ExplicitLeft = 148
    end
    inherited btnClose: TButton
      Left = 254
      ExplicitLeft = 252
    end
  end
  inherited stbBase: TStatusBar
    Top = 99
    Width = 360
    ExplicitTop = 96
    ExplicitWidth = 358
  end
end

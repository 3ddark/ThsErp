inherited frmSetPrsLisan: TfrmSetPrsLisan
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Lisan'
  ClientHeight = 117
  ClientWidth = 342
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 356
  ExplicitHeight = 153
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 342
    Height = 67
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 64
    inherited pgcMain: TPageControl
      Width = 342
      Height = 67
      ExplicitWidth = 340
      ExplicitHeight = 64
      inherited tsMain: TTabSheet
        ExplicitWidth = 334
        ExplicitHeight = 39
        object lbllisan: TLabel
          Left = 77
          Top = 6
          Width = 31
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Lisan'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtlisan: TEdit
          Left = 112
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
    Width = 338
    ExplicitTop = 66
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
    Top = 99
    Width = 342
    ExplicitTop = 96
    ExplicitWidth = 340
  end
end

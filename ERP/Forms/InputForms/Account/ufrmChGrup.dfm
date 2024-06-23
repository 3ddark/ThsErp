inherited frmChGrup: TfrmChGrup
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Hesap Grubu'
  ClientHeight = 124
  ClientWidth = 342
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 358
  ExplicitHeight = 163
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 342
    Height = 74
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 70
    inherited pgcMain: TPageControl
      Width = 342
      Height = 74
      ExplicitWidth = 340
      ExplicitHeight = 70
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 334
        ExplicitHeight = 45
        object lblgrup: TLabel
          Left = 43
          Top = 6
          Width = 27
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grup'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtgrup: TEdit
          Left = 74
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 76
    Width = 338
    ExplicitTop = 72
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
    Top = 106
    Width = 342
    ExplicitTop = 102
    ExplicitWidth = 340
  end
end

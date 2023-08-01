inherited frmSetEmpSection: TfrmSetEmpSection
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel B'#246'l'#252'm'
  ClientHeight = 117
  ClientWidth = 342
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 358
  ExplicitHeight = 156
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 342
    Height = 67
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 68
    inherited pgcMain: TPageControl
      Width = 344
      Height = 71
      ExplicitWidth = 338
      ExplicitHeight = 66
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 43
        object lblbolum: TLabel
          Left = 40
          Top = 6
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Section'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtbolum: TEdit
          Left = 88
          Top = 3
          Width = 239
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 69
    Width = 338
    ExplicitTop = 72
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
    Top = 99
    Width = 342
    ExplicitTop = 116
    ExplicitWidth = 344
  end
end

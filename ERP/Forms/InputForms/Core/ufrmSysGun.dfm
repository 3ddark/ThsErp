inherited frmSysDay: TfrmSysDay
  Left = 501
  Top = 443
  Caption = 'System Day'
  ClientHeight = 115
  ClientWidth = 352
  ParentFont = True
  ExplicitWidth = 366
  ExplicitHeight = 150
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 352
    Height = 65
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 350
    ExplicitHeight = 61
    inherited pgcMain: TPageControl
      Width = 352
      Height = 65
      ExplicitWidth = 350
      ExplicitHeight = 61
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 344
        ExplicitHeight = 35
        object lblday: TLabel
          Left = 86
          Top = 6
          Width = 22
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Day'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtday: TEdit
          Left = 114
          Top = 2
          Width = 223
          Height = 23
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 67
    Width = 348
    ExplicitTop = 63
    ExplicitWidth = 346
    inherited btnAccept: TButton
      Left = 142
      ExplicitLeft = 140
    end
    inherited btnClose: TButton
      Left = 246
      ExplicitLeft = 244
    end
  end
  inherited stbBase: TStatusBar
    Top = 97
    Width = 352
    ExplicitTop = 93
    ExplicitWidth = 350
  end
end

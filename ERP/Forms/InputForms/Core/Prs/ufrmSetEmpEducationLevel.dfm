inherited frmSetEmpEducationLevel: TfrmSetEmpEducationLevel
  ActiveControl = btnClose
  Caption = 'Employee Education Level'
  ClientHeight = 111
  ClientWidth = 339
  ExplicitWidth = 355
  ExplicitHeight = 150
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 339
    Height = 61
    ExplicitWidth = 343
    ExplicitHeight = 61
    inherited pgcMain: TPageControl
      Width = 341
      Height = 65
      ExplicitWidth = 343
      ExplicitHeight = 61
      inherited tsMain: TTabSheet
        ExplicitWidth = 333
        ExplicitHeight = 37
        object lbleducation_level: TLabel
          Left = 35
          Top = 6
          Width = 88
          Height = 13
          Alignment = taRightJustify
          Caption = 'Education Level'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edteducation_level: TEdit
          Left = 127
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 63
    Width = 335
    ExplicitTop = 63
    ExplicitWidth = 339
  end
  inherited stbBase: TStatusBar
    Top = 93
    Width = 339
    ExplicitTop = 93
    ExplicitWidth = 343
  end
end

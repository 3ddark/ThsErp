inherited frmSysCurrency: TfrmSysCurrency
  Left = 501
  Top = 443
  Caption = 'System Currency'
  ClientHeight = 157
  ClientWidth = 355
  ParentFont = True
  ExplicitWidth = 371
  ExplicitHeight = 196
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 355
    Height = 107
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 359
    ExplicitHeight = 115
    inherited pgcMain: TPageControl
      Width = 357
      Height = 111
      ExplicitWidth = 357
      ExplicitHeight = 111
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 349
        ExplicitHeight = 81
        object lblcurrency: TLabel
          Left = 57
          Top = 8
          Width = 51
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Currency'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsymbol: TLabel
          Left = 66
          Top = 32
          Width = 42
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Symbol'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblexplanation: TLabel
          Left = 42
          Top = 56
          Width = 66
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Explanation'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtcurrency: TEdit
          Left = 114
          Top = 4
          Width = 223
          Height = 23
          TabOrder = 0
        end
        object edtsymbol: TEdit
          Left = 114
          Top = 28
          Width = 223
          Height = 23
          TabOrder = 1
        end
        object edtexplanation: TEdit
          Left = 114
          Top = 52
          Width = 223
          Height = 23
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 109
    Width = 351
    ExplicitTop = 117
    ExplicitWidth = 355
    inherited btnAccept: TButton
      Left = 149
      ExplicitLeft = 149
    end
    inherited btnClose: TButton
      Left = 253
      ExplicitLeft = 253
    end
  end
  inherited stbBase: TStatusBar
    Top = 139
    Width = 355
    ExplicitTop = 147
    ExplicitWidth = 359
  end
end

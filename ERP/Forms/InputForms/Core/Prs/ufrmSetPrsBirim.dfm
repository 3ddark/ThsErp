inherited frmSetPrsBirim: TfrmSetPrsBirim
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Birim'
  ClientHeight = 132
  ClientWidth = 347
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 363
  ExplicitHeight = 171
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 347
    Height = 82
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 345
    ExplicitHeight = 79
    inherited pgcMain: TPageControl
      Width = 347
      Height = 82
      ExplicitWidth = 345
      ExplicitHeight = 79
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 339
        ExplicitHeight = 53
        object lblbolum_id: TLabel
          Left = 57
          Top = 5
          Width = 35
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'B'#246'l'#252'm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblbirim: TLabel
          Left = 63
          Top = 27
          Width = 29
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Birim'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtbolum_id: TEdit
          Left = 96
          Top = 2
          Width = 232
          Height = 21
          TabOrder = 0
        end
        object edtbirim: TEdit
          Left = 96
          Top = 24
          Width = 232
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 84
    Width = 343
    ExplicitTop = 81
    ExplicitWidth = 341
    inherited btnAccept: TButton
      Left = 137
      ExplicitLeft = 135
    end
    inherited btnClose: TButton
      Left = 241
      ExplicitLeft = 239
    end
  end
  inherited stbBase: TStatusBar
    Top = 114
    Width = 347
    ExplicitTop = 111
    ExplicitWidth = 345
  end
end

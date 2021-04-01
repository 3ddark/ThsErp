inherited frmEmpSrcAbility: TfrmEmpSrcAbility
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Employee Src Ability'
  ClientHeight = 148
  ClientWidth = 362
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 368
  ExplicitHeight = 177
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 358
    Height = 96
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 433
    ExplicitHeight = 173
    inherited pgcMain: TPageControl
      Width = 356
      Height = 94
      ExplicitWidth = 431
      ExplicitHeight = 171
      inherited tsMain: TTabSheet
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 423
        ExplicitHeight = 143
        object lblsrc_type_id: TLabel
          Left = 84
          Top = 6
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Src Type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_card_id: TLabel
          Left = 45
          Top = 28
          Width = 91
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Employee Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbsrc_type_id: TComboBox
          Left = 140
          Top = 3
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 0
        end
        object cbbemp_card_id: TComboBox
          Left = 140
          Top = 25
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 100
    Width = 358
    ExplicitTop = 177
    ExplicitWidth = 433
    inherited btnAccept: TButton
      Left = 149
      ExplicitLeft = 224
    end
    inherited btnClose: TButton
      Left = 253
      ExplicitLeft = 328
    end
  end
  inherited stbBase: TStatusBar
    Top = 130
    Width = 362
    ExplicitTop = 221
    ExplicitWidth = 437
  end
end

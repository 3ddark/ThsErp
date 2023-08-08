inherited frmSysMukellefTipi: TfrmSysMukellefTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'System Taxpayer Type'
  ClientHeight = 134
  ClientWidth = 364
  ParentFont = True
  ExplicitWidth = 380
  ExplicitHeight = 173
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 364
    Height = 84
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 368
    ExplicitHeight = 92
    inherited pgcMain: TPageControl
      Width = 366
      Height = 88
      ExplicitWidth = 366
      ExplicitHeight = 88
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 358
        ExplicitHeight = 58
        object lbltaxpayer_type: TLabel
          Left = -23
          Top = 5
          Width = 131
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'System Taxpayer Type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_default: TLabel
          Left = 61
          Top = 25
          Width = 47
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Default?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edttaxpayer_type: TEdit
          Left = 110
          Top = 2
          Width = 224
          Height = 23
          TabOrder = 0
        end
        object chkis_default: TCheckBox
          Left = 110
          Top = 24
          Width = 224
          Height = 17
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 86
    Width = 360
    ExplicitTop = 94
    ExplicitWidth = 364
    inherited btnAccept: TButton
      Left = 158
      ExplicitLeft = 158
    end
    inherited btnClose: TButton
      Left = 262
      ExplicitLeft = 262
    end
  end
  inherited stbBase: TStatusBar
    Top = 116
    Width = 364
    ExplicitTop = 124
    ExplicitWidth = 368
  end
end

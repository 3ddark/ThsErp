inherited frmSysKaynakGrubu: TfrmSysKaynakGrubu
  Left = 501
  Top = 443
  Caption = 'Resource Group'
  ClientHeight = 124
  ClientWidth = 348
  ParentFont = True
  ExplicitWidth = 364
  ExplicitHeight = 163
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 348
    Height = 74
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 352
    ExplicitHeight = 82
    inherited pgcMain: TPageControl
      Width = 350
      Height = 78
      ExplicitWidth = 350
      ExplicitHeight = 78
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 342
        ExplicitHeight = 48
        object lblgroup: TLabel
          Left = 74
          Top = 7
          Width = 34
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Group'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtgroup: TEdit
          Left = 114
          Top = 4
          Width = 223
          Height = 23
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 76
    Width = 344
    ExplicitTop = 84
    ExplicitWidth = 348
    inherited btnAccept: TButton
      Left = 142
      ExplicitLeft = 142
    end
    inherited btnClose: TButton
      Left = 246
      ExplicitLeft = 246
    end
  end
  inherited stbBase: TStatusBar
    Top = 106
    Width = 348
    ExplicitTop = 114
    ExplicitWidth = 352
  end
end

inherited frmSysKaynakGrubu: TfrmSysKaynakGrubu
  Left = 501
  Top = 443
  Caption = 'Sistem Kaynak Grubu'
  ClientHeight = 111
  ClientWidth = 348
  ParentFont = True
  ExplicitWidth = 364
  ExplicitHeight = 150
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 348
    Height = 61
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 348
    ExplicitHeight = 74
    inherited pgcMain: TPageControl
      Width = 348
      Height = 61
      ExplicitWidth = 350
      ExplicitHeight = 61
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 340
        ExplicitHeight = 31
        object lblgrup: TLabel
          Left = 81
          Top = 7
          Width = 27
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Grup'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtgrup: TEdit
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
    Top = 63
    Width = 344
    ExplicitTop = 76
    ExplicitWidth = 344
    inherited btnAccept: TButton
      Left = 138
      ExplicitLeft = 138
    end
    inherited btnClose: TButton
      Left = 242
      ExplicitLeft = 242
    end
  end
  inherited stbBase: TStatusBar
    Top = 93
    Width = 348
    ExplicitTop = 106
    ExplicitWidth = 348
  end
end

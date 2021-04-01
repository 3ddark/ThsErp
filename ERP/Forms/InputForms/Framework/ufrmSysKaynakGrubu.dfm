inherited frmSysKaynakGrubu: TfrmSysKaynakGrubu
  Left = 501
  Top = 443
  Caption = 'Sistem Kaynak Grubu'
  ClientHeight = 132
  ClientWidth = 352
  ParentFont = True
  ExplicitWidth = 358
  ExplicitHeight = 161
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 348
    Height = 66
    Color = clWindow
    ExplicitWidth = 348
    ExplicitHeight = 66
    inherited pgcMain: TPageControl
      Width = 346
      Height = 64
      ExplicitWidth = 346
      ExplicitHeight = 64
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 338
        ExplicitHeight = 36
        object lblkaynak_grup: TLabel
          Left = 36
          Top = 7
          Width = 72
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kaynak Grup'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtkaynak_grup: TEdit
          Left = 114
          Top = 4
          Width = 223
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 70
    Width = 348
    ExplicitTop = 70
    ExplicitWidth = 348
    inherited btnAccept: TButton
      Left = 139
      ExplicitLeft = 139
    end
    inherited btnClose: TButton
      Left = 243
      ExplicitLeft = 243
    end
  end
  inherited stbBase: TStatusBar
    Top = 114
    Width = 352
    ExplicitTop = 114
    ExplicitWidth = 352
  end
end

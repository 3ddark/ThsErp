inherited frmSysMultiLangDataTableList: TfrmSysMultiLangDataTableList
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sys Multi Language Data Table'
  ClientHeight = 128
  ClientWidth = 344
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 350
  ExplicitHeight = 157
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 62
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 62
    inherited pgcMain: TPageControl
      Width = 338
      Height = 60
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 338
      ExplicitHeight = 60
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 32
        object lbltable_name: TLabel
          Left = 23
          Top = 6
          Width = 66
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Table Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edttable_name: TEdit
          Left = 93
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 66
    Width = 340
    ExplicitTop = 66
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
    Top = 110
    Width = 344
    ExplicitTop = 110
    ExplicitWidth = 344
  end
end

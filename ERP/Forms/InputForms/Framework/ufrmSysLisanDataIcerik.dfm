inherited frmSysLangDataContent: TfrmSysLangDataContent
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem Lisan Data '#304#231'erik'
  ClientHeight = 150
  ClientWidth = 404
  ParentFont = True
  ExplicitWidth = 410
  ExplicitHeight = 179
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 400
    Height = 84
    Color = clWindow
    ExplicitWidth = 400
    ExplicitHeight = 84
    inherited pgcMain: TPageControl
      Width = 398
      Height = 82
      ExplicitWidth = 398
      ExplicitHeight = 82
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 390
        ExplicitHeight = 54
        object lbllisan: TLabel
          Left = 113
          Top = 7
          Width = 29
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Lisan'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldeger: TLabel
          Left = 108
          Top = 29
          Width = 34
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'De'#287'er'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtlisan: TEdit
          Left = 146
          Top = 4
          Width = 240
          Height = 21
          TabOrder = 0
        end
        object edtdeger: TEdit
          Left = 146
          Top = 26
          Width = 240
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 88
    Width = 400
    ExplicitTop = 88
    ExplicitWidth = 400
    inherited btnAccept: TButton
      Left = 191
      ExplicitLeft = 191
    end
    inherited btnClose: TButton
      Left = 295
      ExplicitLeft = 295
    end
  end
  inherited stbBase: TStatusBar
    Top = 132
    Width = 404
    ExplicitTop = 132
    ExplicitWidth = 404
  end
end

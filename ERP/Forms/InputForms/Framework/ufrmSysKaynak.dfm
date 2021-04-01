inherited frmSysKaynak: TfrmSysKaynak
  Left = 501
  Top = 443
  Caption = 'Sistem Kaynak'
  ClientHeight = 167
  ClientWidth = 359
  ParentFont = True
  ExplicitWidth = 365
  ExplicitHeight = 196
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 355
    Height = 101
    Color = clWindow
    ExplicitWidth = 355
    ExplicitHeight = 101
    inherited pgcMain: TPageControl
      Width = 353
      Height = 99
      ExplicitWidth = 353
      ExplicitHeight = 99
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 345
        ExplicitHeight = 71
        object lblkaynak_grup_id: TLabel
          Left = 36
          Top = 5
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
        object lblkaynak_kodu: TLabel
          Left = 35
          Top = 27
          Width = 73
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kaynak Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkaynak_adi: TLabel
          Left = 45
          Top = 49
          Width = 63
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kaynak Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtkaynak_grup_id: TEdit
          Left = 114
          Top = 2
          Width = 223
          Height = 21
          TabOrder = 0
        end
        object edtkaynak_kodu: TEdit
          Left = 114
          Top = 24
          Width = 223
          Height = 21
          TabOrder = 1
        end
        object edtkaynak_adi: TEdit
          Left = 114
          Top = 46
          Width = 223
          Height = 21
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 105
    Width = 355
    ExplicitTop = 105
    ExplicitWidth = 355
    inherited btnAccept: TButton
      Left = 146
      ExplicitLeft = 146
    end
    inherited btnClose: TButton
      Left = 250
      ExplicitLeft = 250
    end
  end
  inherited stbBase: TStatusBar
    Top = 149
    Width = 359
    ExplicitTop = 149
    ExplicitWidth = 359
  end
end

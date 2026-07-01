inherited frmSysKaynak: TfrmSysKaynak
  Left = 501
  Top = 443
  Caption = 'Sistem Kaynak'
  ClientHeight = 147
  ClientWidth = 349
  ParentFont = True
  ExplicitWidth = 365
  ExplicitHeight = 186
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 349
    Height = 97
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 349
    ExplicitHeight = 97
    inherited pgcMain: TPageControl
      Width = 349
      Height = 97
      ExplicitWidth = 349
      ExplicitHeight = 97
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 341
        ExplicitHeight = 67
        object lblkaynak_grup_id: TLabel
          Left = 29
          Top = 5
          Width = 79
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kaynak Grubu'
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
          Height = 23
          TabOrder = 0
        end
        object edtkaynak_kodu: TEdit
          Left = 114
          Top = 24
          Width = 223
          Height = 23
          TabOrder = 1
        end
        object edtkaynak_adi: TEdit
          Left = 114
          Top = 46
          Width = 223
          Height = 23
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 99
    Width = 345
    ExplicitTop = 99
    ExplicitWidth = 345
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
    Top = 129
    Width = 349
    ExplicitTop = 129
    ExplicitWidth = 349
  end
end

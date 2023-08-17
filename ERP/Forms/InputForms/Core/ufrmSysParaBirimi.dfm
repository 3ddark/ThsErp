inherited frmSysParaBirimi: TfrmSysParaBirimi
  Left = 501
  Top = 443
  Caption = 'Sistem Para Birimi'
  ClientHeight = 157
  ClientWidth = 355
  ParentFont = True
  ExplicitWidth = 361
  ExplicitHeight = 186
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 355
    Height = 107
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 355
    ExplicitHeight = 107
    inherited pgcMain: TPageControl
      Width = 355
      Height = 107
      ExplicitWidth = 355
      ExplicitHeight = 107
      inherited tsMain: TTabSheet
        ExplicitWidth = 347
        ExplicitHeight = 79
        object lblpara: TLabel
          Left = 82
          Top = 8
          Width = 26
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Para'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsembol: TLabel
          Left = 66
          Top = 32
          Width = 42
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sembol'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblaciklama: TLabel
          Left = 56
          Top = 56
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'A'#231#305'klama'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtpara: TEdit
          Left = 114
          Top = 4
          Width = 223
          Height = 21
          TabOrder = 0
        end
        object edtsembol: TEdit
          Left = 114
          Top = 28
          Width = 223
          Height = 21
          TabOrder = 1
        end
        object edtaciklama: TEdit
          Left = 114
          Top = 52
          Width = 223
          Height = 21
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 109
    Width = 351
    ExplicitTop = 109
    ExplicitWidth = 351
    inherited btnAccept: TButton
      Left = 145
      ExplicitLeft = 145
    end
    inherited btnClose: TButton
      Left = 249
      ExplicitLeft = 249
    end
  end
  inherited stbBase: TStatusBar
    Top = 139
    Width = 355
    ExplicitTop = 139
    ExplicitWidth = 355
  end
end

inherited frmSysDovizKuru: TfrmSysDovizKuru
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem D'#246'viz Kuru'
  ClientHeight = 171
  ClientWidth = 344
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 350
  ExplicitHeight = 200
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 119
    ExplicitWidth = 340
    ExplicitHeight = 119
    inherited pgcMain: TPageControl
      Width = 338
      Height = 117
      ExplicitWidth = 338
      ExplicitHeight = 117
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 89
        object lbltarih: TLabel
          Left = 84
          Top = 6
          Width = 29
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tarih'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblpara_birimi: TLabel
          Left = 52
          Top = 28
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Para Birimi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkur: TLabel
          Left = 94
          Top = 50
          Width = 19
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kur'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edttarih: TEdit
          Left = 117
          Top = 3
          Width = 120
          Height = 21
          TabOrder = 0
        end
        object edtpara_birimi: TEdit
          Left = 117
          Top = 25
          Width = 120
          Height = 21
          TabOrder = 1
        end
        object edtkur: TEdit
          Left = 117
          Top = 47
          Width = 120
          Height = 21
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 123
    Width = 340
    ExplicitTop = 123
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
    Top = 153
    Width = 344
    ExplicitTop = 153
    ExplicitWidth = 344
  end
end

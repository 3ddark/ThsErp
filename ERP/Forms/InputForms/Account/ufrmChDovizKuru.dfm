inherited frmChDovizKuru: TfrmChDovizKuru
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem D'#246'viz Kuru'
  ClientHeight = 171
  ClientWidth = 344
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 358
  ExplicitHeight = 206
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 344
    Height = 121
    ExplicitWidth = 342
    ExplicitHeight = 117
    inherited pgcMain: TPageControl
      Width = 344
      Height = 121
      ExplicitWidth = 342
      ExplicitHeight = 117
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 336
        ExplicitHeight = 91
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
          Height = 23
          TabOrder = 0
        end
        object edtpara_birimi: TEdit
          Left = 117
          Top = 25
          Width = 120
          Height = 23
          TabOrder = 1
        end
        object edtkur: TEdit
          Left = 117
          Top = 47
          Width = 120
          Height = 23
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 123
    Width = 340
    ExplicitTop = 119
    ExplicitWidth = 338
    inherited btnAccept: TButton
      Left = 134
      ExplicitLeft = 132
    end
    inherited btnClose: TButton
      Left = 238
      ExplicitLeft = 236
    end
  end
  inherited stbBase: TStatusBar
    Top = 153
    Width = 344
    ExplicitTop = 149
    ExplicitWidth = 342
  end
end

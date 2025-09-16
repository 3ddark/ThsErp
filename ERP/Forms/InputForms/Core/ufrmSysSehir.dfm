inherited frmSysSehir: TfrmSysSehir
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem '#350'ehir'
  ClientHeight = 150
  ClientWidth = 368
  ParentFont = True
  StyleElements = [seFont, seClient, seBorder]
  ExplicitWidth = 384
  ExplicitHeight = 189
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 368
    Height = 100
    Color = clWindow
    ParentColor = False
    StyleElements = [seFont, seClient, seBorder]
    ExplicitWidth = 368
    ExplicitHeight = 100
    inherited pgcMain: TPageControl
      Width = 368
      Height = 100
      ExplicitWidth = 368
      ExplicitHeight = 100
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 360
        ExplicitHeight = 70
        object lblulke_id: TLabel
          Left = 83
          Top = 6
          Width = 25
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'lke'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsehir: TLabel
          Left = 79
          Top = 30
          Width = 29
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #350'ehir'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblplaka_kodu: TLabel
          Left = 46
          Top = 54
          Width = 62
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Plaka Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtsehir: TEdit
          Left = 114
          Top = 26
          Width = 239
          Height = 23
          TabOrder = 1
        end
        object edtplaka_kodu: TEdit
          Left = 114
          Top = 50
          Width = 239
          Height = 23
          TabOrder = 2
        end
        object edtulke_id: TEdit
          Left = 114
          Top = 2
          Width = 239
          Height = 23
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 102
    Width = 364
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 102
    ExplicitWidth = 364
    inherited btnAccept: TButton
      Left = 158
      ExplicitLeft = 158
    end
    inherited btnClose: TButton
      Left = 262
      ExplicitLeft = 262
    end
  end
  inherited stbBase: TStatusBar
    Top = 132
    Width = 368
    ExplicitTop = 132
    ExplicitWidth = 368
  end
end

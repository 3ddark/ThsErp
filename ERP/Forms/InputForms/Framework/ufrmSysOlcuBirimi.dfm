inherited frmSysOlcuBirimi: TfrmSysOlcuBirimi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem '#214'l'#231#252' Birimi'
  ClientHeight = 193
  ClientWidth = 344
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 350
  ExplicitHeight = 222
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 127
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 127
    inherited pgcMain: TPageControl
      Width = 338
      Height = 125
      ExplicitWidth = 338
      ExplicitHeight = 125
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 330
        ExplicitHeight = 97
        object lblolcu_birimi: TLabel
          Left = 54
          Top = 6
          Width = 59
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblolcu_birimi_einv: TLabel
          Left = 22
          Top = 28
          Width = 91
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi E-Fat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblaciklama: TLabel
          Left = 61
          Top = 50
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
        object lblis_ondalik: TLabel
          Left = 65
          Top = 72
          Width = 48
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ondal'#305'k?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtolcu_birimi: TEdit
          Left = 117
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtolcu_birimi_einv: TEdit
          Left = 117
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtaciklama: TEdit
          Left = 117
          Top = 47
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object chkis_ondalik: TCheckBox
          Left = 117
          Top = 72
          Width = 200
          Height = 17
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 131
    Width = 340
    ExplicitTop = 131
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
    Top = 175
    Width = 344
    ExplicitTop = 175
    ExplicitWidth = 344
  end
end

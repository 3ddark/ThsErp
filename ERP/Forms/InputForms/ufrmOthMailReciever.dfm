inherited frmOthMailReciever: TfrmOthMailReciever
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Kalite Formlar'#305' Mail Al'#305'c'#305's'#305
  ClientHeight = 127
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 360
  ExplicitHeight = 166
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 344
    Height = 77
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 55
    inherited pgcMain: TPageControl
      Width = 344
      Height = 77
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 338
      ExplicitHeight = 53
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 49
        object lblMailAdresi: TLabel
          Left = 35
          Top = 6
          Width = 63
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mail Adresi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtmail_adresi: TEdit
          Left = 104
          Top = 3
          Width = 223
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 79
    Width = 340
    ExplicitTop = 59
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
    Top = 109
    Width = 344
    ExplicitTop = 103
    ExplicitWidth = 344
  end
end

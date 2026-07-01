inherited frmOthMailReciever: TfrmOthMailReciever
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Kalite Formlar'#305' Mail Al'#305'c'#305's'#305
  ClientHeight = 123
  ClientWidth = 342
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 358
  ExplicitHeight = 162
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 342
    Height = 73
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 55
    inherited pgcMain: TPageControl
      Width = 342
      Height = 73
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 338
      ExplicitHeight = 53
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 334
        ExplicitHeight = 44
        object lblMailAdresi: TLabel
          Left = 36
          Top = 6
          Width = 62
          Height = 14
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
    Top = 75
    Width = 338
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
    Top = 105
    Width = 342
    ExplicitTop = 103
    ExplicitWidth = 344
  end
end

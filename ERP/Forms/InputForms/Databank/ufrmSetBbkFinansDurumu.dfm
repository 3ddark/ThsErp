inherited frmSetBbkFinansDurumu: TfrmSetBbkFinansDurumu
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Bilgi Bankas'#305' Finans Durumu'
  ClientHeight = 121
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 360
  ExplicitHeight = 160
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 344
    Height = 71
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 66
    inherited pgcMain: TPageControl
      Width = 344
      Height = 71
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 338
      ExplicitHeight = 64
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 43
        object lblfinans_durumu: TLabel
          Left = 62
          Top = 5
          Width = 85
          Height = 13
          Alignment = taRightJustify
          Caption = 'Finans Durumu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtfinans_durumu: TEdit
          Left = 150
          Top = 2
          Width = 145
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 73
    Width = 340
    ExplicitTop = 70
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      Caption = 'KAYDET'
      ExplicitLeft = 131
    end
    inherited btnClose: TButton
      Left = 235
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 103
    Width = 344
    ExplicitTop = 114
    ExplicitWidth = 344
  end
  inherited AppEvntsBase: TApplicationEvents
    Left = 376
    Top = 40
  end
  inherited dlgPntBase: TPrintDialog
    Left = 464
    Top = 40
  end
  inherited pmLabels: TPopupMenu
    Left = 400
    Top = 88
  end
end

inherited frmSetBbkCalismaDurumu: TfrmSetBbkCalismaDurumu
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Bilgi Bankas'#305' '#199'al'#305#351'ma Durumu'
  ClientHeight = 117
  ClientWidth = 342
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 358
  ExplicitHeight = 156
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 342
    Height = 67
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
        object lblcalisma_durumu: TLabel
          Left = 54
          Top = 5
          Width = 91
          Height = 13
          Alignment = taRightJustify
          Caption = #199'al'#305#351'ma Durumu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtcalisma_durumu: TEdit
          Left = 150
          Top = 2
          Width = 177
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 69
    Width = 338
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
    Top = 99
    Width = 342
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

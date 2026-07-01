inherited frmSetBbkFinansDurumu: TfrmSetBbkFinansDurumu
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Bilgi Bankas'#305' Finans Durumu'
  ClientHeight = 117
  ClientWidth = 342
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 358
  ExplicitHeight = 156
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 342
    Height = 67
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 66
    inherited pgcMain: TPageControl
      Width = 342
      Height = 67
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 338
      ExplicitHeight = 64
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 334
        ExplicitHeight = 38
        object lblfinans_durumu: TLabel
          Left = 64
          Top = 5
          Width = 83
          Height = 14
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
  inherited pmLabels: TPopupMenu
    Left = 400
    Top = 88
  end
end

inherited frmBbkBolgeSehir: TfrmBbkBolgeSehir
  Caption = 'Bilgi Bankas'#305' B'#246'lge '#350'ehir'
  ClientHeight = 144
  ClientWidth = 344
  ExplicitWidth = 350
  ExplicitHeight = 173
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 78
    ExplicitWidth = 340
    ExplicitHeight = 78
    inherited pgcMain: TPageControl
      Width = 338
      Height = 76
      ExplicitWidth = 338
      ExplicitHeight = 76
      inherited tsMain: TTabSheet
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 330
        ExplicitHeight = 48
        object lblsehir_id: TLabel
          Left = 117
          Top = 5
          Width = 30
          Height = 13
          Alignment = taRightJustify
          Caption = #350'ehir'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblbolge_id: TLabel
          Left = 114
          Top = 27
          Width = 33
          Height = 13
          Alignment = taRightJustify
          Caption = 'B'#246'lge'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtsehir_id: TEdit
          Left = 150
          Top = 2
          Width = 169
          Height = 21
          TabOrder = 0
        end
        object edtbolge_id: TEdit
          Left = 150
          Top = 24
          Width = 169
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 82
    Width = 340
    ExplicitTop = 82
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
    Top = 126
    Width = 344
    ExplicitTop = 126
    ExplicitWidth = 344
  end
end

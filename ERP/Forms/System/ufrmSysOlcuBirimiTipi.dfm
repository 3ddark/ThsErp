inherited frmSysOlcuBirimiTipi: TfrmSysOlcuBirimiTipi
  ActiveControl = btnClose
  Caption = 'Sistem '#214'l'#231#252' Birimi Tipi'
  ClientHeight = 115
  ClientWidth = 336
  ExplicitWidth = 352
  ExplicitHeight = 154
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 336
    Height = 65
    ExplicitWidth = 336
    ExplicitHeight = 65
    inherited pgcMain: TPageControl
      Width = 336
      Height = 65
      ExplicitWidth = 336
      ExplicitHeight = 65
      inherited tsMain: TTabSheet
        ExplicitWidth = 328
        ExplicitHeight = 37
        object lblolcu_birimi_tipi: TLabel
          Left = 33
          Top = 6
          Width = 82
          Height = 13
          Alignment = taRightJustify
          Caption = #214'l'#231#252' Birimi Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtolcu_birimi_tipi: TEdit
          Left = 119
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 67
    Width = 332
    ExplicitTop = 67
    ExplicitWidth = 332
    inherited btnAccept: TButton
      Left = 230
      TabOrder = 3
      ExplicitLeft = 230
    end
    inherited btnClose: TButton
      Left = 126
      TabOrder = 2
      ExplicitLeft = 126
    end
  end
  inherited stbBase: TStatusBar
    Top = 97
    Width = 336
    ExplicitTop = 97
    ExplicitWidth = 336
  end
end

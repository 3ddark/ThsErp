inherited frmSysOlcuBirimiTipi: TfrmSysOlcuBirimiTipi
  ActiveControl = btnClose
  Caption = 'Sistem '#214'l'#231#252' Birimi Tipi'
  ClientHeight = 115
  ClientWidth = 336
  ExplicitWidth = 350
  ExplicitHeight = 150
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 336
    Height = 65
    ExplicitWidth = 334
    ExplicitHeight = 61
    inherited pgcMain: TPageControl
      Width = 336
      Height = 65
      ExplicitWidth = 334
      ExplicitHeight = 61
      inherited tsMain: TTabSheet
        ExplicitWidth = 328
        ExplicitHeight = 37
        object lblunit_type: TLabel
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
        object edtunit_type: TEdit
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
    ExplicitTop = 63
    ExplicitWidth = 330
    inherited btnAccept: TButton
      Left = 230
      TabOrder = 3
      ExplicitLeft = 228
    end
    inherited btnClose: TButton
      Left = 126
      TabOrder = 2
      ExplicitLeft = 124
    end
  end
  inherited stbBase: TStatusBar
    Top = 97
    Width = 336
    ExplicitTop = 93
    ExplicitWidth = 334
  end
end

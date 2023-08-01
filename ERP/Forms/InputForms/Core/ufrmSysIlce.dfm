inherited frmSysIlce: TfrmSysIlce
  ActiveControl = btnClose
  Caption = 'Sys '#304'l'#231'e'
  ClientHeight = 132
  ClientWidth = 344
  ExplicitWidth = 360
  ExplicitHeight = 171
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 344
    Height = 82
    ExplicitWidth = 340
    ExplicitHeight = 80
    inherited pgcMain: TPageControl
      Width = 344
      Height = 82
      ExplicitWidth = 338
      ExplicitHeight = 78
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 54
        object lblilce_adi: TLabel
          Left = 43
          Top = 6
          Width = 42
          Height = 13
          Alignment = taRightJustify
          Caption = #304'l'#231'e Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblsehir_id: TLabel
          Left = 35
          Top = 28
          Width = 50
          Height = 13
          Alignment = taRightJustify
          Caption = #350'ehir Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtilce_adi: TEdit
          Left = 89
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtsehir_id: TEdit
          Left = 89
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 84
    Width = 340
    ExplicitTop = 84
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
    Top = 114
    Width = 344
    ExplicitTop = 114
    ExplicitWidth = 344
  end
end

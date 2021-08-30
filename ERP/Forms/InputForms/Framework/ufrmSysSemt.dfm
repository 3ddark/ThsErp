inherited frmSysSemt: TfrmSysSemt
  ActiveControl = btnClose
  Caption = 'Sys Semt'
  ClientHeight = 131
  ClientWidth = 344
  ExplicitWidth = 350
  ExplicitHeight = 160
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 79
    ExplicitWidth = 340
    ExplicitHeight = 69
    inherited pgcMain: TPageControl
      Width = 338
      Height = 77
      ExplicitWidth = 338
      ExplicitHeight = 67
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 39
        object lblsemt_adi: TLabel
          Left = 39
          Top = 6
          Width = 51
          Height = 13
          Alignment = taRightJustify
          Caption = 'Semt Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblilce_id: TLabel
          Left = 48
          Top = 28
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
        object edtsemt_adi: TEdit
          Left = 94
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtilce_id: TEdit
          Left = 94
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 83
    Width = 340
    ExplicitTop = 73
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
    Top = 113
    Width = 344
    ExplicitTop = 103
    ExplicitWidth = 344
  end
end

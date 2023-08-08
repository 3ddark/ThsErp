inherited frmSetPrsPersonelTipi: TfrmSetPrsPersonelTipi
  ActiveControl = btnClose
  Caption = 'Employee Type'
  ClientHeight = 111
  ClientWidth = 337
  ExplicitWidth = 353
  ExplicitHeight = 150
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 337
    Height = 61
    ExplicitWidth = 341
    ExplicitHeight = 61
    inherited pgcMain: TPageControl
      Width = 339
      Height = 65
      ExplicitWidth = 341
      ExplicitHeight = 61
      inherited tsMain: TTabSheet
        ExplicitWidth = 331
        ExplicitHeight = 37
        object lblemployee_type: TLabel
          Left = 35
          Top = 6
          Width = 86
          Height = 13
          Alignment = taRightJustify
          Caption = 'Employee Type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtemployee_type: TEdit
          Left = 125
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 63
    Width = 333
    ExplicitTop = 63
    ExplicitWidth = 337
  end
  inherited stbBase: TStatusBar
    Top = 93
    Width = 337
    ExplicitTop = 93
    ExplicitWidth = 341
  end
end

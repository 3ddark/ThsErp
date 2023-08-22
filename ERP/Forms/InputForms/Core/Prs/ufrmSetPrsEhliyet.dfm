inherited frmSetPrsEhliyet: TfrmSetPrsEhliyet
  ActiveControl = btnClose
  Caption = 'Personel Ehliyet Tipi'
  ClientHeight = 114
  ClientWidth = 337
  ExplicitWidth = 351
  ExplicitHeight = 150
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 337
    Height = 64
    ExplicitWidth = 335
    ExplicitHeight = 61
    inherited pgcMain: TPageControl
      Width = 337
      Height = 64
      ExplicitWidth = 335
      ExplicitHeight = 61
      inherited tsMain: TTabSheet
        ExplicitWidth = 329
        ExplicitHeight = 36
        object lblehliyet: TLabel
          Left = 81
          Top = 6
          Width = 38
          Height = 13
          Alignment = taRightJustify
          Caption = 'Ehliyet'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtehliyet: TEdit
          Left = 123
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 66
    Width = 333
    ExplicitTop = 63
    ExplicitWidth = 331
    inherited btnAccept: TButton
      Left = 127
      TabOrder = 2
      ExplicitLeft = 125
    end
    inherited btnClose: TButton
      Left = 231
      ExplicitLeft = 229
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 96
    Width = 337
    ExplicitTop = 93
    ExplicitWidth = 335
  end
end

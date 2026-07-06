inherited frmTarihHaftaSecici: TfrmTarihHaftaSecici
  Caption = 'frmTarihHaftaSecici'
  ClientHeight = 149
  ClientWidth = 239
  ExplicitWidth = 255
  ExplicitHeight = 188
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 239
    Height = 99
    ExplicitWidth = 246
    ExplicitHeight = 113
    inherited pgcMain: TPageControl
      Width = 239
      Height = 99
      ExplicitWidth = 244
      ExplicitHeight = 111
      inherited tsMain: TTabSheet
        ExplicitWidth = 231
        ExplicitHeight = 71
        object lblyil: TLabel
          Left = 52
          Top = 6
          Width = 13
          Height = 13
          Alignment = taRightJustify
          Caption = 'Y'#305'l'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
        end
        object lblhafta: TLabel
          Left = 34
          Top = 28
          Width = 31
          Height = 13
          Alignment = taRightJustify
          Caption = 'Hafta'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
        end
        object lblgun: TLabel
          Left = 43
          Top = 50
          Width = 22
          Height = 13
          Alignment = taRightJustify
          Caption = 'G'#252'n'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
        end
        object edtyil: TEdit
          Left = 69
          Top = 3
          Width = 143
          Height = 21
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 4
          ParentFont = False
          TabOrder = 0
          OnKeyPress = edtyilKeyPress
        end
        object edthafta: TEdit
          Left = 69
          Top = 25
          Width = 143
          Height = 21
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 2
          ParentFont = False
          ReadOnly = True
          TabOrder = 1
          OnExit = edthaftaExit
          OnKeyPress = edthaftaKeyPress
        end
        object edtgun: TEdit
          Left = 69
          Top = 47
          Width = 143
          Height = 21
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 10
          ParentFont = False
          TabOrder = 2
          OnExit = edtgunExit
          OnKeyPress = edtgunKeyPress
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 101
    Width = 235
    ExplicitTop = 117
    ExplicitWidth = 246
    inherited btnAccept: TButton
      Left = 26
      ExplicitLeft = 37
    end
    inherited btnClose: TButton
      Left = 130
      ExplicitLeft = 141
    end
  end
  inherited stbBase: TStatusBar
    Top = 131
    Width = 239
    ExplicitTop = 147
    ExplicitWidth = 250
  end
end

inherited frmSysOlcuBirimi: TfrmSysOlcuBirimi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem '#214'l'#231#252' Birimi'
  ClientHeight = 218
  ClientWidth = 340
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 354
  ExplicitHeight = 253
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 340
    Height = 168
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 338
    ExplicitHeight = 164
    inherited pgcMain: TPageControl
      Width = 340
      Height = 168
      ExplicitWidth = 338
      ExplicitHeight = 164
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 332
        ExplicitHeight = 138
        object lblunit: TLabel
          Left = 54
          Top = 6
          Width = 59
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblunit_einv: TLabel
          Left = 22
          Top = 28
          Width = 91
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi E-Fat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblexplanation: TLabel
          Left = 61
          Top = 50
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'A'#231#305'klama'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_decimal: TLabel
          Left = 44
          Top = 72
          Width = 69
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ondal'#305'k Say'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblunit_type_id: TLabel
          Left = 31
          Top = 98
          Width = 82
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmultiply: TLabel
          Left = 73
          Top = 120
          Width = 40
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #199'arpan'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtunit: TEdit
          Left = 117
          Top = 3
          Width = 200
          Height = 23
          TabOrder = 0
        end
        object edtunit_einv: TEdit
          Left = 117
          Top = 25
          Width = 200
          Height = 23
          TabOrder = 1
        end
        object edtexplanation: TEdit
          Left = 117
          Top = 47
          Width = 200
          Height = 23
          TabOrder = 2
        end
        object chkis_decimal: TCheckBox
          Left = 117
          Top = 72
          Width = 200
          Height = 17
          TabOrder = 3
        end
        object edtunit_type_id: TEdit
          Left = 117
          Top = 95
          Width = 200
          Height = 23
          TabOrder = 4
        end
        object edtmultiply: TEdit
          Left = 117
          Top = 117
          Width = 200
          Height = 23
          TabOrder = 5
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 170
    Width = 336
    ExplicitTop = 166
    ExplicitWidth = 334
    inherited btnAccept: TButton
      Left = 130
      ExplicitLeft = 128
    end
    inherited btnClose: TButton
      Left = 234
      ExplicitLeft = 232
    end
  end
  inherited stbBase: TStatusBar
    Top = 200
    Width = 340
    ExplicitTop = 196
    ExplicitWidth = 338
  end
end

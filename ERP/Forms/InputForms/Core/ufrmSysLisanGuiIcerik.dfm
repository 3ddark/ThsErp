inherited frmSysLangGuiContent: TfrmSysLangGuiContent
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'System Language GUI Content'
  ClientHeight = 247
  ClientWidth = 433
  ParentFont = True
  ExplicitWidth = 449
  ExplicitHeight = 286
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 433
    Height = 197
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 441
    ExplicitHeight = 213
    inherited pgcMain: TPageControl
      Width = 435
      Height = 201
      ExplicitWidth = 435
      ExplicitHeight = 201
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 427
        ExplicitHeight = 171
        object lbllang: TLabel
          Left = 77
          Top = 7
          Width = 55
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Language'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcode: TLabel
          Left = 104
          Top = 29
          Width = 28
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Code'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblvalue: TLabel
          Left = 101
          Top = 51
          Width = 31
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Value'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcontent_type: TLabel
          Left = 56
          Top = 73
          Width = 76
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Content Type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltable_name: TLabel
          Left = 66
          Top = 95
          Width = 66
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Table Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblform_name: TLabel
          Left = 68
          Top = 117
          Width = 64
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Form Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_factory: TLabel
          Left = 41
          Top = 141
          Width = 91
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Default Setting?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbblang: TComboBox
          Left = 138
          Top = 4
          Width = 279
          Height = 23
          TabOrder = 0
        end
        object edtcode: TEdit
          Left = 138
          Top = 26
          Width = 279
          Height = 23
          TabOrder = 1
        end
        object edtvalue: TEdit
          Left = 138
          Top = 48
          Width = 279
          Height = 23
          TabOrder = 2
        end
        object edtcontent_type: TEdit
          Left = 138
          Top = 70
          Width = 279
          Height = 23
          TabOrder = 3
        end
        object cbbtable_name: TComboBox
          Left = 138
          Top = 92
          Width = 279
          Height = 23
          TabOrder = 4
        end
        object edtform_name: TEdit
          Left = 138
          Top = 114
          Width = 279
          Height = 23
          TabOrder = 5
        end
        object chkis_factory: TCheckBox
          Left = 138
          Top = 140
          Width = 279
          Height = 17
          TabOrder = 6
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 199
    Width = 429
    ExplicitTop = 215
    ExplicitWidth = 437
    inherited btnAccept: TButton
      Left = 231
      ExplicitLeft = 231
    end
    inherited btnClose: TButton
      Left = 335
      ExplicitLeft = 335
    end
  end
  inherited stbBase: TStatusBar
    Top = 229
    Width = 433
    ExplicitTop = 245
    ExplicitWidth = 441
  end
end

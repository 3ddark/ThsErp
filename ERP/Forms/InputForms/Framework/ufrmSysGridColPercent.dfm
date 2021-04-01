inherited frmSysGridColPercent: TfrmSysGridColPercent
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'City'
  ClientHeight = 299
  ClientWidth = 388
  ParentFont = True
  ExplicitWidth = 394
  ExplicitHeight = 328
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 384
    Height = 233
    Color = clWindow
    ExplicitWidth = 384
    ExplicitHeight = 233
    inherited pgcMain: TPageControl
      Width = 382
      Height = 231
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 382
      ExplicitHeight = 231
      inherited tsMain: TTabSheet
        ExplicitWidth = 374
        ExplicitHeight = 203
        object imgExample: TImage
          Left = 122
          Top = 172
          Width = 240
          Height = 26
        end
        object lblcolor_bar: TLabel
          Left = 65
          Top = 76
          Width = 51
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Color Bar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcolor_bar_back: TLabel
          Left = 35
          Top = 99
          Width = 81
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Color Bar Back'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcolor_bar_text: TLabel
          Left = 58
          Top = 122
          Width = 58
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Color Text'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcolor_bar_text_active: TLabel
          Left = 19
          Top = 145
          Width = 97
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Color Text Active'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcolumn_name: TLabel
          Left = 39
          Top = 30
          Width = 77
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Column Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmax_value: TLabel
          Left = 58
          Top = 53
          Width = 58
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Max Value'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltable_name: TLabel
          Left = 50
          Top = 7
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
        object cbbtable_name: TComboBox
          Left = 122
          Top = 4
          Width = 240
          Height = 21
          TabOrder = 0
          OnChange = cbbtable_nameChange
        end
        object cbbcolumn_name: TComboBox
          Left = 122
          Top = 27
          Width = 240
          Height = 21
          TabOrder = 1
        end
        object edtmax_value: TEdit
          Left = 122
          Top = 50
          Width = 240
          Height = 21
          TabOrder = 2
        end
        object edtcolor_bar: TEdit
          Left = 122
          Top = 73
          Width = 240
          Height = 21
          TabOrder = 3
          OnDblClick = edtcolor_barDblClick
        end
        object edtcolor_bar_back: TEdit
          Left = 122
          Top = 96
          Width = 240
          Height = 21
          TabOrder = 4
          OnDblClick = edtcolor_bar_backDblClick
        end
        object edtcolor_bar_text: TEdit
          Left = 122
          Top = 119
          Width = 240
          Height = 21
          TabOrder = 5
          OnDblClick = edtcolor_bar_textDblClick
        end
        object edtcolor_bar_text_active: TEdit
          Left = 122
          Top = 142
          Width = 240
          Height = 21
          TabOrder = 6
          OnDblClick = edtcolor_bar_text_activeDblClick
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 237
    Width = 384
    ExplicitTop = 237
    ExplicitWidth = 384
    inherited btnAccept: TButton
      Left = 175
      ExplicitLeft = 175
    end
    inherited btnClose: TButton
      Left = 279
      ExplicitLeft = 279
    end
  end
  inherited stbBase: TStatusBar
    Top = 281
    Width = 388
    ExplicitTop = 281
    ExplicitWidth = 388
  end
end

inherited frmSysGridKolon: TfrmSysGridKolon
  Left = 501
  Top = 443
  Caption = 'System Grid Column'
  ClientHeight = 361
  ClientWidth = 595
  ParentFont = True
  ExplicitWidth = 611
  ExplicitHeight = 400
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 595
    Height = 311
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 595
    ExplicitHeight = 311
    inherited pgcMain: TPageControl
      Width = 595
      Height = 311
      ExplicitWidth = 595
      ExplicitHeight = 311
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 587
        ExplicitHeight = 281
        object lbltable_name: TLabel
          Left = 90
          Top = 5
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
        object lblcolumn_name: TLabel
          Left = 79
          Top = 27
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
        object lblcol_width: TLabel
          Left = 123
          Top = 71
          Width = 33
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Width'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblseq_no: TLabel
          Left = 84
          Top = 49
          Width = 72
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sequence No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_show: TLabel
          Left = 120
          Top = 115
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Show?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_show_helper: TLabel
          Left = 80
          Top = 137
          Width = 76
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Show Helper?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmax_color: TLabel
          Left = 68
          Top = 241
          Width = 88
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Maximum Color'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmax_value: TLabel
          Left = 66
          Top = 219
          Width = 90
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Maximum Value'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmin_color: TLabel
          Left = 72
          Top = 197
          Width = 84
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Minimum Color'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmin_value: TLabel
          Left = 70
          Top = 175
          Width = 86
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Minimum Value'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object imgexample_bar: TImage
          Left = 425
          Top = 261
          Width = 150
          Height = 25
        end
        object lblcolor_bar: TLabel
          Left = 368
          Top = 197
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
          Left = 338
          Top = 219
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
          Left = 339
          Top = 241
          Width = 80
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Color Bar Text'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmax_value_percent: TLabel
          Left = 329
          Top = 175
          Width = 90
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Maximum Value'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldata_format: TLabel
          Left = 85
          Top = 93
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Data Format'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbtable_name: TComboBox
          Left = 162
          Top = 2
          Width = 239
          Height = 23
          TabOrder = 0
          OnChange = cbbtable_nameChange
        end
        object cbbcolumn_name: TComboBox
          Left = 162
          Top = 24
          Width = 239
          Height = 23
          TabOrder = 1
        end
        object edtseq_no: TEdit
          Left = 162
          Top = 46
          Width = 150
          Height = 23
          TabOrder = 2
        end
        object edtcol_width: TEdit
          Left = 162
          Top = 68
          Width = 150
          Height = 23
          TabOrder = 3
        end
        object edtdata_format: TEdit
          Left = 162
          Top = 90
          Width = 150
          Height = 23
          TabOrder = 4
        end
        object chkis_show: TCheckBox
          Left = 162
          Top = 112
          Width = 150
          Height = 21
          TabOrder = 5
        end
        object chkis_show_helper: TCheckBox
          Left = 162
          Top = 134
          Width = 150
          Height = 21
          TabOrder = 6
        end
        object edtmin_value: TEdit
          Left = 162
          Top = 172
          Width = 150
          Height = 23
          TabOrder = 7
        end
        object edtmin_color: TEdit
          Left = 162
          Top = 194
          Width = 150
          Height = 23
          TabOrder = 9
          OnDblClick = edtmin_colorDblClick
        end
        object edtmax_value: TEdit
          Left = 162
          Top = 216
          Width = 150
          Height = 23
          TabOrder = 11
        end
        object edtmax_color: TEdit
          Left = 162
          Top = 238
          Width = 150
          Height = 23
          TabOrder = 13
          OnDblClick = edtmax_colorDblClick
        end
        object edtmax_value_percent: TEdit
          Left = 425
          Top = 172
          Width = 150
          Height = 23
          TabOrder = 8
        end
        object edtcolor_bar: TEdit
          Left = 425
          Top = 194
          Width = 150
          Height = 23
          TabOrder = 10
          OnDblClick = edtcolor_barDblClick
        end
        object edtcolor_bar_back: TEdit
          Left = 425
          Top = 216
          Width = 150
          Height = 23
          TabOrder = 12
          OnDblClick = edtcolor_bar_backDblClick
        end
        object edtcolor_bar_text: TEdit
          Left = 425
          Top = 238
          Width = 150
          Height = 23
          TabOrder = 14
          OnDblClick = edtcolor_bar_textDblClick
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 313
    Width = 591
    ExplicitTop = 325
    ExplicitWidth = 597
    inherited btnAccept: TButton
      Left = 391
      ExplicitLeft = 391
    end
    inherited btnClose: TButton
      Left = 495
      ExplicitLeft = 495
    end
  end
  inherited stbBase: TStatusBar
    Top = 343
    Width = 595
    ExplicitTop = 355
    ExplicitWidth = 601
  end
end

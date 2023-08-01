inherited frmSysGridColSummary: TfrmSysGridColSummary
  Left = 501
  Top = 443
  Caption = 'Grid Column Summary'
  ClientHeight = 198
  ClientWidth = 392
  ParentFont = True
  ExplicitWidth = 398
  ExplicitHeight = 227
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 388
    Height = 132
    Color = clWindow
    ExplicitWidth = 388
    ExplicitHeight = 132
    inherited pgcMain: TPageControl
      Width = 386
      Height = 130
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 386
      ExplicitHeight = 130
      inherited tsMain: TTabSheet
        ExplicitWidth = 378
        ExplicitHeight = 102
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
        object lblsummary_type: TLabel
          Left = 30
          Top = 53
          Width = 86
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Summary Type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblformat: TLabel
          Left = 75
          Top = 76
          Width = 41
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Format'
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
          Width = 239
          Height = 21
          TabOrder = 0
          OnChange = cbbtable_nameChange
        end
        object cbbcolumn_name: TComboBox
          Left = 122
          Top = 27
          Width = 239
          Height = 21
          TabOrder = 1
        end
        object cbbsummary_type: TComboBox
          Left = 122
          Top = 50
          Width = 239
          Height = 21
          Style = csDropDownList
          TabOrder = 2
        end
        object edtformat: TEdit
          Left = 122
          Top = 73
          Width = 239
          Height = 21
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 136
    Width = 388
    ExplicitTop = 136
    ExplicitWidth = 388
    inherited btnAccept: TButton
      Left = 179
      ExplicitLeft = 179
    end
    inherited btnClose: TButton
      Left = 283
      ExplicitLeft = 283
    end
  end
  inherited stbBase: TStatusBar
    Top = 180
    Width = 392
    ExplicitTop = 180
    ExplicitWidth = 392
  end
end

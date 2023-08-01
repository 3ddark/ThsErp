inherited frmSysGridFilterSort: TfrmSysGridFilterSort
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'System Grid Filter Sort'
  ClientHeight = 139
  ClientWidth = 380
  ParentFont = True
  ExplicitWidth = 396
  ExplicitHeight = 178
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 380
    Height = 89
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 380
    ExplicitHeight = 89
    inherited pgcMain: TPageControl
      Width = 382
      Height = 93
      ExplicitWidth = 382
      ExplicitHeight = 93
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 374
        ExplicitHeight = 63
        object lbltable_name: TLabel
          Left = 13
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
        object lblcontent: TLabel
          Left = 48
          Top = 27
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
        object lblis_sort: TLabel
          Left = 55
          Top = 49
          Width = 24
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Sort'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbtable_name: TComboBox
          Left = 82
          Top = 2
          Width = 287
          Height = 23
          TabOrder = 0
        end
        object edtcontent: TEdit
          Left = 82
          Top = 24
          Width = 287
          Height = 23
          TabOrder = 1
        end
        object chkis_sort: TCheckBox
          Left = 82
          Top = 48
          Width = 287
          Height = 17
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 91
    Width = 376
    ExplicitTop = 91
    ExplicitWidth = 376
    inherited btnAccept: TButton
      Left = 172
      ExplicitLeft = 170
    end
    inherited btnClose: TButton
      Left = 276
      ExplicitLeft = 274
    end
  end
  inherited stbBase: TStatusBar
    Top = 121
    Width = 380
    ExplicitTop = 121
    ExplicitWidth = 380
  end
end

inherited frmSysGuiContent: TfrmSysGuiContent
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem GUI '#304#231'erik'
  ClientHeight = 221
  ClientWidth = 433
  ParentFont = True
  ExplicitWidth = 449
  ExplicitHeight = 260
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 433
    Height = 171
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 433
    ExplicitHeight = 171
    inherited pgcMain: TPageControl
      Width = 433
      Height = 171
      ExplicitWidth = 435
      ExplicitHeight = 171
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 425
        ExplicitHeight = 141
        object lblCode: TLabel
          Left = 111
          Top = 5
          Width = 21
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
        object lblContent: TLabel
          Left = 98
          Top = 27
          Width = 34
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Content'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblContentType: TLabel
          Left = 76
          Top = 49
          Width = 56
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
        object lblTableName: TLabel
          Left = 80
          Top = 71
          Width = 52
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
        object lblFormName: TLabel
          Left = 82
          Top = 93
          Width = 50
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
        object lblIsFactory: TLabel
          Left = 50
          Top = 117
          Width = 82
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Is Factory'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtCode: TEdit
          Left = 138
          Top = 2
          Width = 279
          Height = 23
          TabOrder = 0
        end
        object edtContent: TEdit
          Left = 138
          Top = 24
          Width = 279
          Height = 23
          TabOrder = 1
        end
        object edtContentType: TEdit
          Left = 138
          Top = 46
          Width = 279
          Height = 23
          TabOrder = 2
        end
        object cbbTableName: TComboBox
          Left = 138
          Top = 68
          Width = 279
          Height = 23
          TabOrder = 3
        end
        object edtFormName: TEdit
          Left = 138
          Top = 90
          Width = 279
          Height = 23
          TabOrder = 4
        end
        object chkIsFactory: TCheckBox
          Left = 138
          Top = 116
          Width = 279
          Height = 17
          TabOrder = 5
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 173
    Width = 429
    ExplicitTop = 173
    ExplicitWidth = 429
    inherited btnAccept: TButton
      Left = 223
      ExplicitLeft = 223
    end
    inherited btnClose: TButton
      Left = 327
      ExplicitLeft = 327
    end
  end
  inherited stbBase: TStatusBar
    Top = 203
    Width = 433
    ExplicitTop = 203
    ExplicitWidth = 433
  end
end

object frmSysGuiContent: TfrmSysGuiContent
  Left = 501
  Top = 443
  Caption = 'Sistem GUI '#304#231'erik'
  ClientHeight = 221
  ClientWidth = 433
  Color = clBtnFace
  ParentFont = True
  TextHeight = 15
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 433
    Height = 171
    Color = clWindow
    TabOrder = 0
    object lblCode: TLabel
      Left = 104
      Top = 5
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
    object lblContent: TLabel
      Left = 87
      Top = 27
      Width = 45
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
      Left = 56
      Top = 49
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
    object lblTableName: TLabel
      Left = 66
      Top = 71
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
    object lblFormName: TLabel
      Left = 68
      Top = 93
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
    object lblIsFactory: TLabel
      Left = 75
      Top = 117
      Width = 57
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

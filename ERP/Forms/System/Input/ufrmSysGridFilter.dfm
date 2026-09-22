object frmSysGridFilter: TfrmSysGridFilter
  Left = 0
  Top = 0
  Caption = 'Sutun Filtre Kayit'
  ClientHeight = 405
  ClientWidth = 610
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 14
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 610
    Height = 405
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 350
    object lblTableName: TLabel
      Left = 12
      Top = 8
      Width = 85
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Tablo Ad'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblColumnName: TLabel
      Left = 12
      Top = 35
      Width = 85
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kolon Ad'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblOperator: TLabel
      Left = 290
      Top = 35
      Width = 51
      Height = 13
      Alignment = taRightJustify
      Caption = 'Operat'#246'r'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblValue: TLabel
      Left = 12
      Top = 62
      Width = 85
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'De'#287'er'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblConjunction: TLabel
      Left = 398
      Top = 62
      Width = 37
      Height = 13
      Alignment = taRightJustify
      Caption = 'Ba'#287'la'#231
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblFilterList: TLabel
      Left = 12
      Top = 117
      Width = 85
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Filtre Listesi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblFilterContent: TLabel
      Left = 12
      Top = 265
      Width = 85
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Filtre '#304'fadesi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTableName: TEdit
      Left = 104
      Top = 5
      Width = 486
      Height = 22
      TabOrder = 0
      OnExit = edtTableNameExit
    end
    object cbbColumnName: TComboBox
      Left = 104
      Top = 32
      Width = 180
      Height = 22
      Style = csDropDownList
      TabOrder = 1
    end
    object cbbOperator: TComboBox
      Left = 346
      Top = 32
      Width = 150
      Height = 22
      Style = csDropDownList
      TabOrder = 2
      OnChange = cbbOperatorChange
    end
    object chkNot: TCheckBox
      Left = 506
      Top = 34
      Width = 88
      Height = 17
      Caption = 'NOT (De'#287'il)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
    end
    object edtValue: TEdit
      Left = 104
      Top = 59
      Width = 284
      Height = 22
      TabOrder = 4
    end
    object cbbConjunction: TComboBox
      Left = 440
      Top = 59
      Width = 80
      Height = 22
      Style = csDropDownList
      TabOrder = 5
    end
    object btnAddFilter: TButton
      Left = 104
      Top = 87
      Width = 68
      Height = 25
      Caption = '+ Ekle'
      TabOrder = 6
      OnClick = btnAddFilterClick
    end
    object btnDeleteFilter: TButton
      Left = 176
      Top = 87
      Width = 68
      Height = 25
      Caption = '- Sil'
      TabOrder = 7
      OnClick = btnDeleteFilterClick
    end
    object btnMoveUp: TButton
      Left = 248
      Top = 87
      Width = 68
      Height = 25
      Caption = #9650' Yukar'#305
      TabOrder = 8
      OnClick = btnMoveUpClick
    end
    object btnMoveDown: TButton
      Left = 320
      Top = 87
      Width = 68
      Height = 25
      Caption = #9660' A'#351'a'#287#305
      TabOrder = 9
      OnClick = btnMoveDownClick
    end
    object btnClearFilter: TButton
      Left = 392
      Top = 87
      Width = 68
      Height = 25
      Caption = 'Temizle'
      TabOrder = 10
      OnClick = btnClearFilterClick
    end
    object lbxFilterList: TListBox
      Left = 104
      Top = 117
      Width = 486
      Height = 140
      ItemHeight = 14
      TabOrder = 11
    end
    object mmoFilterContent: TMemo
      Left = 104
      Top = 265
      Width = 486
      Height = 65
      ScrollBars = ssVertical
      TabOrder = 12
    end
  end
end

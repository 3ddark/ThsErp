object frmSysGridSort: TfrmSysGridSort
  Left = 0
  Top = 0
  Caption = 'Sutun Siralama Kayit'
  ClientHeight = 375
  ClientWidth = 520
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
    Width = 520
    Height = 375
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 360
    object lblTableName: TLabel
      Left = 24
      Top = 8
      Width = 90
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
      Left = 24
      Top = 35
      Width = 90
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
    object lblSortDirection: TLabel
      Left = 336
      Top = 35
      Width = 21
      Height = 13
      Caption = 'Y'#246'n'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSortList: TLabel
      Left = 24
      Top = 95
      Width = 90
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'S'#305'ralama Listesi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSortContent: TLabel
      Left = 24
      Top = 270
      Width = 90
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'S'#305'ralama '#304'fadesi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTableName: TEdit
      Left = 120
      Top = 5
      Width = 380
      Height = 22
      TabOrder = 0
      OnExit = edtTableNameExit
    end
    object cbbColumnName: TComboBox
      Left = 120
      Top = 32
      Width = 210
      Height = 22
      Style = csDropDownList
      TabOrder = 1
    end
    object cbbSortDirection: TComboBox
      Left = 368
      Top = 32
      Width = 132
      Height = 22
      Style = csDropDownList
      TabOrder = 2
    end
    object btnAddSort: TButton
      Left = 120
      Top = 60
      Width = 65
      Height = 25
      Caption = '+ Ekle'
      TabOrder = 3
      OnClick = btnAddSortClick
    end
    object btnDeleteSort: TButton
      Left = 190
      Top = 60
      Width = 65
      Height = 25
      Caption = '- Sil'
      TabOrder = 4
      OnClick = btnDeleteSortClick
    end
    object btnMoveUp: TButton
      Left = 260
      Top = 60
      Width = 65
      Height = 25
      Caption = #9650' Yukar'#305
      TabOrder = 5
      OnClick = btnMoveUpClick
    end
    object btnMoveDown: TButton
      Left = 330
      Top = 60
      Width = 65
      Height = 25
      Caption = #9660' A'#351'a'#287#305
      TabOrder = 6
      OnClick = btnMoveDownClick
    end
    object btnClearSort: TButton
      Left = 400
      Top = 60
      Width = 65
      Height = 25
      Caption = 'Temizle'
      TabOrder = 7
      OnClick = btnClearSortClick
    end
    object lbxSortList: TListBox
      Left = 120
      Top = 92
      Width = 380
      Height = 165
      ItemHeight = 14
      TabOrder = 8
    end
    object edtSortContent: TEdit
      Left = 120
      Top = 267
      Width = 380
      Height = 22
      TabOrder = 9
    end
  end
end

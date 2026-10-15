object frmSysMenu: TfrmSysMenu
  Left = 0
  Top = 0
  Caption = 'Menu Screen'
  ClientHeight = 334
  ClientWidth = 600
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
    Width = 600
    Height = 334
    Align = alClient
    TabOrder = 0
    object lblMenuCode: TLabel
      Left = 4
      Top = 10
      Width = 160
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMenuKey: TLabel
      Left = 4
      Top = 34
      Width = 160
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Key'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblActionName: TLabel
      Left = 4
      Top = 58
      Width = 160
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Action'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSysPermissionId: TLabel
      Left = 4
      Top = 82
      Width = 160
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Read Permission'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtMenuCode: TEdit
      Left = 168
      Top = 6
      Width = 120
      Height = 22
      MaxLength = 6
      TabOrder = 0
    end
    object edtMenuKey: TEdit
      Left = 168
      Top = 30
      Width = 420
      Height = 22
      MaxLength = 64
      TabOrder = 1
    end
    object edtActionName: TEdit
      Left = 168
      Top = 54
      Width = 420
      Height = 22
      MaxLength = 64
      TabOrder = 2
    end
    object edtSysPermissionId: TEdit
      Left = 168
      Top = 78
      Width = 420
      Height = 22
      ReadOnly = True
      TabOrder = 3
    end
    object chkIsActive: TCheckBox
      Left = 168
      Top = 104
      Width = 260
      Height = 17
      Caption = 'Active'
      TabOrder = 4
    end
    object scrlbxMenuName: TScrollBox
      Left = 0
      Top = 128
      Width = 596
      Height = 72
      HorzScrollBar.Visible = False
      BorderStyle = bsNone
      TabOrder = 5
    end
    object scrlbxKeywords: TScrollBox
      Left = 0
      Top = 206
      Width = 596
      Height = 72
      HorzScrollBar.Visible = False
      BorderStyle = bsNone
      TabOrder = 6
    end
  end
end

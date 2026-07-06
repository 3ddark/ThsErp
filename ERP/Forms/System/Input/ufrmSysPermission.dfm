object frmSysPermission: TfrmSysPermission
  Left = 0
  Top = 0
  Caption = 'frmSysPermission'
  ClientHeight = 197
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 197
    Align = alClient
    TabOrder = 0
    object lblPermissionCode: TLabel
      Left = 12
      Top = 11
      Width = 94
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblPermissionName: TLabel
      Left = 9
      Top = 41
      Width = 97
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblPermissionGroupId: TLabel
      Left = 7
      Top = 71
      Width = 99
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Group'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPermissionCode: TEdit
      Left = 108
      Top = 7
      Width = 120
      Height = 23
      TabOrder = 0
    end
    object edtPermissionName: TEdit
      Left = 108
      Top = 37
      Width = 385
      Height = 23
      TabOrder = 1
    end
    object edtPermissionGroupId: TEdit
      Left = 108
      Top = 67
      Width = 250
      Height = 23
      ReadOnly = True
      TabOrder = 2
    end
    object btnPermissionGroupSelect: TButton
      Left = 364
      Top = 63
      Width = 75
      Height = 25
      Caption = 'Select'
      TabOrder = 3
    end
  end
end

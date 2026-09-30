object frmSysUserPermissionTemplate: TfrmSysUserPermissionTemplate
  Left = 0
  Top = 0
  Caption = 'User Permission Template'
  ClientHeight = 115
  ClientWidth = 500
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
    Width = 500
    Height = 115
    Align = alClient
    TabOrder = 0
    object lblSysUserId: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'User'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSysPermissionTemplateId: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Template'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSysUserId: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 0
    end
    object edtSysPermissionTemplateId: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 1
    end
  end
end

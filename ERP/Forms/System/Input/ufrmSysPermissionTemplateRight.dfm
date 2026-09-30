object frmSysPermissionTemplateRight: TfrmSysPermissionTemplateRight
  Left = 0
  Top = 0
  Caption = 'Template Right'
  ClientHeight = 169
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
    Height = 169
    Align = alClient
    TabOrder = 0
    object lblSysPermissionTemplateId: TLabel
      Left = 4
      Top = 6
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
    object lblSysPermissionId: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Permission'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSysPermissionTemplateId: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 0
    end
    object edtSysPermissionId: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 1
    end
    object chkIsRead: TCheckBox
      Left = 132
      Top = 48
      Width = 140
      Height = 17
      Caption = 'Read'
      TabOrder = 2
    end
    object chkIsAdd: TCheckBox
      Left = 282
      Top = 48
      Width = 140
      Height = 17
      Caption = 'Add'
      TabOrder = 3
    end
    object chkIsUpdate: TCheckBox
      Left = 132
      Top = 66
      Width = 140
      Height = 17
      Caption = 'Update'
      TabOrder = 4
    end
    object chkIsDelete: TCheckBox
      Left = 282
      Top = 66
      Width = 140
      Height = 17
      Caption = 'Delete'
      TabOrder = 5
    end
    object chkIsSpecial: TCheckBox
      Left = 132
      Top = 84
      Width = 290
      Height = 17
      Caption = 'Special'
      TabOrder = 6
    end
  end
end

object frmSysAccessRight: TfrmSysAccessRight
  Left = 0
  Top = 0
  Caption = 'Access Right'
  ClientHeight = 267
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
    Height = 267
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 206
    object lblSysUserId: TLabel
      Left = 60
      Top = 6
      Width = 26
      Height = 13
      Alignment = taRightJustify
      Caption = 'User'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSysPermissionId: TLabel
      Left = 24
      Top = 27
      Width = 62
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblGrant: TLabel
      Left = 88
      Top = 50
      Width = 350
      Height = 13
      AutoSize = False
      Caption = 'Extra Grant'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDeny: TLabel
      Left = 88
      Top = 128
      Width = 350
      Height = 13
      AutoSize = False
      Caption = 'Deny'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSysUserId: TEdit
      Left = 88
      Top = 2
      Width = 350
      Height = 22
      ReadOnly = True
      TabOrder = 0
    end
    object edtSysPermissionId: TEdit
      Left = 88
      Top = 23
      Width = 350
      Height = 22
      ReadOnly = True
      TabOrder = 1
    end
    object chkIsRead: TCheckBox
      Left = 88
      Top = 68
      Width = 140
      Height = 17
      Caption = 'Read'
      TabOrder = 2
    end
    object chkIsAdd: TCheckBox
      Left = 238
      Top = 68
      Width = 140
      Height = 17
      Caption = 'Add'
      TabOrder = 3
    end
    object chkIsUpdate: TCheckBox
      Left = 88
      Top = 86
      Width = 140
      Height = 17
      Caption = 'Update'
      TabOrder = 4
    end
    object chkIsDelete: TCheckBox
      Left = 238
      Top = 86
      Width = 140
      Height = 17
      Caption = 'Delete'
      TabOrder = 5
    end
    object chkIsSpecial: TCheckBox
      Left = 88
      Top = 104
      Width = 290
      Height = 17
      Caption = 'Special'
      TabOrder = 6
    end
    object chkDenyRead: TCheckBox
      Left = 88
      Top = 146
      Width = 140
      Height = 17
      Caption = 'Read'
      TabOrder = 7
    end
    object chkDenyAdd: TCheckBox
      Left = 238
      Top = 146
      Width = 140
      Height = 17
      Caption = 'Add'
      TabOrder = 8
    end
    object chkDenyUpdate: TCheckBox
      Left = 88
      Top = 164
      Width = 140
      Height = 17
      Caption = 'Update'
      TabOrder = 9
    end
    object chkDenyDelete: TCheckBox
      Left = 238
      Top = 164
      Width = 140
      Height = 17
      Caption = 'Delete'
      TabOrder = 10
    end
    object chkDenySpecial: TCheckBox
      Left = 88
      Top = 182
      Width = 290
      Height = 17
      Caption = 'Special'
      TabOrder = 11
    end
  end
end

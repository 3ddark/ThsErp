object frmSysAccessRight: TfrmSysAccessRight
  Left = 0
  Top = 0
  Caption = 'Access Right'
  ClientHeight = 212
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
    Height = 212
    Align = alClient
    TabOrder = 0
    object lblUserId: TLabel
      Left = 60
      Top = 11
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
    object lblPermissionId: TLabel
      Left = 24
      Top = 41
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
    object edtUserId: TEdit
      Left = 88
      Top = 7
      Width = 350
      Height = 22
      ReadOnly = True
      TabOrder = 0
    end
    object edtPermissionId: TEdit
      Left = 88
      Top = 37
      Width = 350
      Height = 22
      ReadOnly = True
      TabOrder = 1
    end
    object chkIsRead: TCheckBox
      Left = 88
      Top = 70
      Width = 140
      Height = 17
      Caption = 'Read'
      TabOrder = 2
    end
    object chkIsAdd: TCheckBox
      Left = 238
      Top = 70
      Width = 140
      Height = 17
      Caption = 'Add'
      TabOrder = 3
    end
    object chkIsUpdate: TCheckBox
      Left = 88
      Top = 95
      Width = 140
      Height = 17
      Caption = 'Update'
      TabOrder = 4
    end
    object chkIsDelete: TCheckBox
      Left = 238
      Top = 95
      Width = 140
      Height = 17
      Caption = 'Delete'
      TabOrder = 5
    end
    object chkIsSpecial: TCheckBox
      Left = 88
      Top = 120
      Width = 290
      Height = 17
      Caption = 'Special'
      TabOrder = 6
    end
  end
end

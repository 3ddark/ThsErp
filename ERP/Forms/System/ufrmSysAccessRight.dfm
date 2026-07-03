object frmSysAccessRight: TfrmSysAccessRight
  Left = 0
  Top = 0
  Caption = 'frmSysAccessRight'
  ClientHeight = 267
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
    Height = 267
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 265
    object lbluser_id: TLabel
      Left = 31
      Top = 11
      Width = 55
      Height = 13
      Alignment = taRightJustify
      Caption = 'User'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtuser_id: TEdit
      Left = 80
      Top = 7
      Width = 250
      Height = 23
      ReadOnly = True
      TabOrder = 0
    end
    object btnuser_sec: TButton
      Left = 336
      Top = 3
      Width = 75
      Height = 25
      Caption = 'Select'
      TabOrder = 1
    end
    object lblpermission_id: TLabel
      Left = 8
      Top = 41
      Width = 78
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtpermission_id: TEdit
      Left = 80
      Top = 37
      Width = 250
      Height = 23
      ReadOnly = True
      TabOrder = 2
    end
    object btnpermission_sec: TButton
      Left = 336
      Top = 33
      Width = 75
      Height = 25
      Caption = 'Select'
      TabOrder = 3
    end
    object chkis_read: TCheckBox
      Left = 80
      Top = 70
      Width = 140
      Height = 17
      Caption = 'Read'
      TabOrder = 4
    end
    object chkis_add: TCheckBox
      Left = 230
      Top = 70
      Width = 140
      Height = 17
      Caption = 'Add'
      TabOrder = 5
    end
    object chkis_update: TCheckBox
      Left = 80
      Top = 95
      Width = 140
      Height = 17
      Caption = 'Update'
      TabOrder = 6
    end
    object chkis_delete: TCheckBox
      Left = 230
      Top = 95
      Width = 140
      Height = 17
      Caption = 'Delete'
      TabOrder = 7
    end
    object chkis_special: TCheckBox
      Left = 80
      Top = 120
      Width = 290
      Height = 17
      Caption = 'Special'
      TabOrder = 8
    end
  end
end

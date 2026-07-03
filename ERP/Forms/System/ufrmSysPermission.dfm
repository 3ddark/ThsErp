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
    ExplicitWidth = 498
    ExplicitHeight = 195
    object lblpermission_code: TLabel
      Left = 12
      Top = 11
      Width = 78
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtpermission_code: TEdit
      Left = 80
      Top = 7
      Width = 120
      Height = 23
      TabOrder = 0
    end
    object lblpermission_name: TLabel
      Left = 26
      Top = 41
      Width = 64
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtpermission_name: TEdit
      Left = 80
      Top = 37
      Width = 385
      Height = 23
      TabOrder = 1
    end
    object lblpermission_group_id: TLabel
      Left = -4
      Top = 71
      Width = 94
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Group'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtpermission_group_id: TEdit
      Left = 80
      Top = 67
      Width = 250
      Height = 23
      ReadOnly = True
      TabOrder = 2
    end
    object btnpermission_group_sec: TButton
      Left = 336
      Top = 63
      Width = 75
      Height = 25
      Caption = 'Select'
      TabOrder = 3
    end
  end
end

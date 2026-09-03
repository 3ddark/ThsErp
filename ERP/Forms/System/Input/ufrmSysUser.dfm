object frmSysUser: TfrmSysUser
  Left = 0
  Top = 0
  Caption = 'frmSysUser'
  ClientHeight = 276
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
    Height = 276
    Align = alClient
    TabOrder = 0
    object lblUsername: TLabel
      Left = 45
      Top = 11
      Width = 58
      Height = 13
      Alignment = taRightJustify
      Caption = 'Username'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblPersonId: TLabel
      Left = 47
      Top = 41
      Width = 56
      Height = 13
      Alignment = taRightJustify
      Caption = 'Personnel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblActive: TLabel
      Left = 67
      Top = 68
      Width = 36
      Height = 13
      Alignment = taRightJustify
      Caption = 'Active'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblManager: TLabel
      Left = 53
      Top = 93
      Width = 50
      Height = 13
      Alignment = taRightJustify
      Caption = 'Manager'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSuperUser: TLabel
      Left = 41
      Top = 118
      Width = 62
      Height = 13
      Alignment = taRightJustify
      Caption = 'Super User'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblIpAddress: TLabel
      Left = 42
      Top = 151
      Width = 61
      Height = 13
      Alignment = taRightJustify
      Caption = 'IP Address'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMacAddress: TLabel
      Left = 29
      Top = 181
      Width = 74
      Height = 13
      Alignment = taRightJustify
      Caption = 'MAC Address'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtUsername: TEdit
      Left = 104
      Top = 7
      Width = 385
      Height = 22
      TabOrder = 0
    end
    object edtPersonId: TEdit
      Left = 104
      Top = 37
      Width = 385
      Height = 22
      TabOrder = 1
    end
    object chkActive: TCheckBox
      Left = 104
      Top = 67
      Width = 90
      Height = 17
      Caption = 'Active'
      TabOrder = 2
    end
    object chkManager: TCheckBox
      Left = 104
      Top = 92
      Width = 90
      Height = 17
      Caption = 'Manager'
      TabOrder = 3
    end
    object chkSuperUser: TCheckBox
      Left = 104
      Top = 117
      Width = 90
      Height = 17
      Caption = 'Super User'
      TabOrder = 4
    end
    object edtIpAddress: TEdit
      Left = 104
      Top = 147
      Width = 385
      Height = 22
      TabOrder = 5
    end
    object edtMacAddress: TEdit
      Left = 104
      Top = 177
      Width = 385
      Height = 22
      TabOrder = 6
    end
  end
end

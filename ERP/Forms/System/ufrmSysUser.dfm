object frmSysUser: TfrmSysUser
  Left = 0
  Top = 0
  Caption = 'frmSysUser'
  ClientHeight = 237
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
    Height = 237
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 235
    object lblusername: TLabel
      Left = 26
      Top = 11
      Width = 54
      Height = 13
      Alignment = taRightJustify
      Caption = 'Username'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtusername: TEdit
      Left = 80
      Top = 7
      Width = 385
      Height = 23
      TabOrder = 0
    end
    object lbluser_password: TLabel
      Left = 14
      Top = 41
      Width = 66
      Height = 13
      Alignment = taRightJustify
      Caption = 'Password'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtuser_password: TEdit
      Left = 80
      Top = 37
      Width = 385
      Height = 23
      TabOrder = 1
    end
    object lblactive: TLabel
      Left = 42
      Top = 71
      Width = 38
      Height = 13
      Alignment = taRightJustify
      Caption = 'Active'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object chkactive: TCheckBox
      Left = 80
      Top = 67
      Width = 90
      Height = 17
      Caption = 'Active'
      TabOrder = 2
    end
    object lblmanager: TLabel
      Left = 34
      Top = 96
      Width = 46
      Height = 13
      Alignment = taRightJustify
      Caption = 'Manager'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object chkmanager: TCheckBox
      Left = 80
      Top = 92
      Width = 90
      Height = 17
      Caption = 'Manager'
      TabOrder = 3
    end
    object lblsuper_user: TLabel
      Left = 14
      Top = 121
      Width = 66
      Height = 13
      Alignment = taRightJustify
      Caption = 'Super User'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object chksuper_user: TCheckBox
      Left = 80
      Top = 117
      Width = 90
      Height = 17
      Caption = 'Super User'
      TabOrder = 4
    end
    object lbllp_address: TLabel
      Left = 12
      Top = 151
      Width = 68
      Height = 13
      Alignment = taRightJustify
      Caption = 'IP Address'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtlp_address: TEdit
      Left = 80
      Top = 147
      Width = 385
      Height = 23
      TabOrder = 5
    end
    object lblmac_address: TLabel
      Left = 6
      Top = 181
      Width = 74
      Height = 13
      Alignment = taRightJustify
      Caption = 'MAC Address'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtmac_address: TEdit
      Left = 80
      Top = 177
      Width = 385
      Height = 23
      TabOrder = 6
    end
  end
end

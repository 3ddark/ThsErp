inherited frmSysUserPassword: TfrmSysUserPassword
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Password'
  ClientHeight = 166
  ClientWidth = 400
  ExplicitWidth = 416
  ExplicitHeight = 205
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 400
    Height = 116
    ExplicitWidth = 400
    ExplicitHeight = 100
    object lblUsername: TLabel
      Left = 8
      Top = 14
      Width = 150
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Username'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblOldPassword: TLabel
      Left = 8
      Top = 39
      Width = 150
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Current Password'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblNewPassword: TLabel
      Left = 8
      Top = 64
      Width = 150
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'New Password'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblNewPasswordConfirm: TLabel
      Left = 8
      Top = 89
      Width = 150
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Confirm New Password'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtUsername: TEdit
      Left = 164
      Top = 10
      Width = 220
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object edtOldPassword: TEdit
      Left = 164
      Top = 35
      Width = 220
      Height = 21
      MaxLength = 128
      PasswordChar = '*'
      TabOrder = 1
    end
    object edtNewPassword: TEdit
      Left = 164
      Top = 60
      Width = 220
      Height = 21
      MaxLength = 128
      PasswordChar = '*'
      TabOrder = 2
    end
    object edtNewPasswordConfirm: TEdit
      Left = 164
      Top = 85
      Width = 220
      Height = 21
      MaxLength = 128
      PasswordChar = '*'
      TabOrder = 3
    end
  end
  inherited pnlBottom: TPanel
    Top = 118
    Width = 396
    ExplicitTop = 102
    ExplicitWidth = 396
    inherited btnAccept: TButton
      Left = 190
      ExplicitLeft = 190
    end
    inherited btnClose: TButton
      Left = 294
      ExplicitLeft = 294
    end
  end
  inherited stbBase: TStatusBar
    Top = 148
    Width = 400
    ExplicitTop = 132
    ExplicitWidth = 400
  end
end

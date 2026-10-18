object frmSysApiService: TfrmSysApiService
  Left = 0
  Top = 0
  Caption = 'Entegrasyon Servisi'
  ClientHeight = 413
  ClientWidth = 567
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
    Width = 567
    Height = 413
    Align = alClient
    TabOrder = 0
    object lblServiceKind: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Servis T'#252'r'#252
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtServiceKind: TEdit
      Left = 132
      Top = 2
      Width = 420
      Height = 22
      MaxLength = 32
      TabOrder = 0
    end
    object lblProviderCode: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sa'#287'lay'#305'c'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtProviderCode: TEdit
      Left = 132
      Top = 25
      Width = 420
      Height = 22
      MaxLength = 32
      TabOrder = 1
    end
    object lblEnvironment: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ortam'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbEnvironment: TComboBox
      Left = 132
      Top = 48
      Width = 420
      Height = 22
      Style = csDropDownList
      TabOrder = 2
    end
    object lblBaseUrl: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Servis Adresi (URL)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBaseUrl: TEdit
      Left = 132
      Top = 71
      Width = 420
      Height = 22
      MaxLength = 512
      TabOrder = 3
    end
    object lblUsername: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kullan'#305'c'#305' Ad'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtUsername: TEdit
      Left = 132
      Top = 94
      Width = 420
      Height = 22
      MaxLength = 128
      TabOrder = 4
    end
    object lblPassword: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Password'
    end
    object edtPassword: TEdit
      Left = 132
      Top = 117
      Width = 420
      Height = 22
      MaxLength = 256
      PasswordChar = '*'
      TabOrder = 20
    end
    object lblApiKey: TLabel
      Left = 4
      Top = 144
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'API Key'
    end
    object edtApiKey: TEdit
      Left = 132
      Top = 140
      Width = 420
      Height = 22
      MaxLength = 1024
      PasswordChar = '*'
      TabOrder = 21
    end
    object chkClearSecrets: TCheckBox
      Left = 132
      Top = 165
      Width = 420
      Height = 17
      Caption = 'Delete saved password / key'
      TabOrder = 22
    end
    object lblTimeoutSeconds: TLabel
      Left = 4
      Top = 190
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Zaman A'#351#305'm'#305' (sn)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTimeoutSeconds: TEdit
      Left = 132
      Top = 186
      Width = 420
      Height = 22
      TabOrder = 5
    end
    object lblOptions: TLabel
      Left = 4
      Top = 213
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sa'#287'lay'#305'c'#305' Ayarlar'#305' (JSON)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object mmoOptions: TMemo
      Left = 132
      Top = 209
      Width = 420
      Height = 90
      MaxLength = 8000
      ScrollBars = ssVertical
      TabOrder = 6
    end
    object lblDescription: TLabel
      Left = 4
      Top = 304
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'A'#231#305'klama'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDescription: TEdit
      Left = 132
      Top = 300
      Width = 420
      Height = 22
      MaxLength = 256
      TabOrder = 7
    end
    object lblIsActive: TLabel
      Left = 4
      Top = 327
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Aktif'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkIsActive: TCheckBox
      Left = 132
      Top = 326
      Width = 420
      Height = 17
      TabOrder = 8
    end
  end
end

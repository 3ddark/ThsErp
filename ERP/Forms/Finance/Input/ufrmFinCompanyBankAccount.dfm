object frmFinCompanyBankAccount: TfrmFinCompanyBankAccount
  Left = 0
  Top = 0
  Caption = 'Firma Banka Hesab'#305
  ClientHeight = 253
  ClientWidth = 811
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
    Width = 811
    Height = 253
    Align = alClient
    TabOrder = 0
    object lblAccBankId: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Banka'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccBankId: TEdit
      Left = 132
      Top = 2
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 0
    end
    object lblBranchCode: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #350'ube Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBranchCode: TEdit
      Left = 132
      Top = 25
      Width = 260
      Height = 22
      MaxLength = 16
      TabOrder = 1
    end
    object lblBranchName: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #350'ube Ad'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBranchName: TEdit
      Left = 132
      Top = 48
      Width = 260
      Height = 22
      MaxLength = 64
      TabOrder = 2
    end
    object lblSysCityId: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #350'ube '#350'ehri'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSysCityId: TEdit
      Left = 132
      Top = 71
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 3
    end
    object lblAccountNo: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Hesap No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccountNo: TEdit
      Left = 132
      Top = 94
      Width = 260
      Height = 22
      MaxLength = 32
      TabOrder = 4
    end
    object lblIban: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'IBAN'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtIban: TEdit
      Left = 132
      Top = 117
      Width = 260
      Height = 22
      MaxLength = 34
      TabOrder = 5
    end
    object lblCurrency: TLabel
      Left = 4
      Top = 144
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Para Birimi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCurrency: TEdit
      Left = 132
      Top = 140
      Width = 260
      Height = 22
      MaxLength = 3
      ReadOnly = True
      TabOrder = 6
    end
    object lblAccountHolder: TLabel
      Left = 4
      Top = 167
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Hesap Sahibi / Unvan'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccountHolder: TEdit
      Left = 132
      Top = 163
      Width = 260
      Height = 22
      MaxLength = 128
      TabOrder = 7
    end
    object lblShowOnCheque: TLabel
      Left = 408
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #199'ekte Kullan'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkShowOnCheque: TCheckBox
      Left = 536
      Top = 5
      Width = 260
      Height = 17
      TabOrder = 8
    end
    object lblShowOnNote: TLabel
      Left = 408
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Senette Kullan'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkShowOnNote: TCheckBox
      Left = 536
      Top = 28
      Width = 260
      Height = 17
      TabOrder = 9
    end
    object lblShowOnPrint: TLabel
      Left = 408
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #199#305'kt'#305'larda G'#246'ster'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkShowOnPrint: TCheckBox
      Left = 536
      Top = 51
      Width = 260
      Height = 17
      TabOrder = 10
    end
    object lblSortOrder: TLabel
      Left = 408
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'S'#305'ra'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSortOrder: TEdit
      Left = 536
      Top = 71
      Width = 260
      Height = 22
      TabOrder = 11
    end
    object lblIsActive: TLabel
      Left = 408
      Top = 98
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
      Left = 536
      Top = 97
      Width = 260
      Height = 17
      TabOrder = 12
    end
    object lblDescription: TLabel
      Left = 408
      Top = 121
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
      Left = 536
      Top = 117
      Width = 260
      Height = 22
      MaxLength = 256
      TabOrder = 13
    end
  end
end

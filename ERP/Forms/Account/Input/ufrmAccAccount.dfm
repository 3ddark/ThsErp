object frmAccAccount: TfrmAccAccount
  Left = 0
  Top = 0
  Caption = 'Account Card'
  ClientHeight = 438
  ClientWidth = 960
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
    Width = 960
    Height = 438
    Align = alClient
    TabOrder = 0
    object lblCode: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Account Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCode: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      MaxLength = 16
      TabOrder = 0
    end
    object lblName: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Account Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtName: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      MaxLength = 128
      TabOrder = 1
    end
    object lblAccSetAccountTypeId: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Account Type'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccSetAccountTypeId: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 2
    end
    object lblAccGroupId: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Group'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccGroupId: TEdit
      Left = 132
      Top = 71
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 3
    end
    object lblAccRegionId: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Region'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccRegionId: TEdit
      Left = 132
      Top = 94
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 4
    end
    object lblRootCode: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Root Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtRootCode: TEdit
      Left = 132
      Top = 117
      Width = 333
      Height = 22
      MaxLength = 3
      ReadOnly = True
      TabOrder = 5
    end
    object lblSubCode: TLabel
      Left = 4
      Top = 144
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Parent Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSubCode: TEdit
      Left = 132
      Top = 140
      Width = 333
      Height = 22
      MaxLength = 8
      ReadOnly = True
      TabOrder = 6
    end
    object lblIban: TLabel
      Left = 4
      Top = 167
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
      Top = 163
      Width = 333
      Height = 22
      MaxLength = 64
      TabOrder = 7
    end
    object lblIbanCurrency: TLabel
      Left = 4
      Top = 190
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'IBAN Currency'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtIbanCurrency: TEdit
      Left = 132
      Top = 186
      Width = 333
      Height = 22
      MaxLength = 3
      ReadOnly = True
      TabOrder = 8
    end
    object lblDiscountRate: TLabel
      Left = 4
      Top = 213
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Discount Rate'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDiscountRate: TEdit
      Left = 132
      Top = 209
      Width = 333
      Height = 22
      TabOrder = 9
    end
    object lblEInvoiceActive: TLabel
      Left = 4
      Top = 236
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'E-Invoice Active'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkEInvoiceActive: TCheckBox
      Left = 132
      Top = 234
      Width = 333
      Height = 17
      TabOrder = 10
    end
    object lblEInvoicePackageName: TLabel
      Left = 4
      Top = 259
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'E-Invoice Package'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEInvoicePackageName: TEdit
      Left = 132
      Top = 255
      Width = 333
      Height = 22
      MaxLength = 128
      TabOrder = 11
    end
    object lblIsPassive: TLabel
      Left = 4
      Top = 282
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Passive'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkIsPassive: TCheckBox
      Left = 132
      Top = 280
      Width = 333
      Height = 17
      TabOrder = 12
    end
    object lblNotes: TLabel
      Left = 4
      Top = 305
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Notes'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtNotes: TEdit
      Left = 132
      Top = 301
      Width = 333
      Height = 22
      MaxLength = 512
      TabOrder = 13
    end
    object lblTaxpayerType: TLabel
      Left = 4
      Top = 328
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Taxpayer Type'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbTaxpayerType: TComboBox
      Left = 132
      Top = 324
      Width = 333
      Height = 22
      Style = csDropDownList
      TabOrder = 14
    end
    object lblTaxpayerName: TLabel
      Left = 4
      Top = 351
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Taxpayer Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTaxpayerName: TEdit
      Left = 132
      Top = 347
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 15
    end
    object lblTaxpayerName2: TLabel
      Left = 484
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Taxpayer Name 2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTaxpayerName2: TEdit
      Left = 612
      Top = 2
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 16
    end
    object lblTaxpayerSurname: TLabel
      Left = 484
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Taxpayer Surname'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTaxpayerSurname: TEdit
      Left = 612
      Top = 25
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 17
    end
    object lblTaxOffice: TLabel
      Left = 484
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Tax Office'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTaxOffice: TEdit
      Left = 612
      Top = 48
      Width = 333
      Height = 22
      MaxLength = 64
      TabOrder = 18
    end
    object lblTaxNo: TLabel
      Left = 484
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Tax No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTaxNo: TEdit
      Left = 612
      Top = 71
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 19
    end
    object lblNaceCode: TLabel
      Left = 484
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'NACE Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtNaceCode: TEdit
      Left = 612
      Top = 94
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 20
    end
    object lblAuthorizedPerson1: TLabel
      Left = 484
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Contact Person 1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAuthorizedPerson1: TEdit
      Left = 612
      Top = 117
      Width = 333
      Height = 22
      MaxLength = 64
      TabOrder = 21
    end
    object lblAuthorizedPhone1: TLabel
      Left = 484
      Top = 144
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Contact Phone 1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAuthorizedPhone1: TEdit
      Left = 612
      Top = 140
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 22
    end
    object lblAuthorizedPerson2: TLabel
      Left = 484
      Top = 167
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Contact Person 2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAuthorizedPerson2: TEdit
      Left = 612
      Top = 163
      Width = 333
      Height = 22
      MaxLength = 64
      TabOrder = 23
    end
    object lblAuthorizedPhone2: TLabel
      Left = 484
      Top = 190
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Contact Phone 2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAuthorizedPhone2: TEdit
      Left = 612
      Top = 186
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 24
    end
    object lblAuthorizedPerson3: TLabel
      Left = 484
      Top = 213
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Contact Person 3'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAuthorizedPerson3: TEdit
      Left = 612
      Top = 209
      Width = 333
      Height = 22
      MaxLength = 64
      TabOrder = 25
    end
    object lblAuthorizedPhone3: TLabel
      Left = 484
      Top = 236
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Contact Phone 3'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAuthorizedPhone3: TEdit
      Left = 612
      Top = 232
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 26
    end
    object lblFax: TLabel
      Left = 484
      Top = 259
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Fax'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtFax: TEdit
      Left = 612
      Top = 255
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 27
    end
    object lblAccountantPhone: TLabel
      Left = 484
      Top = 282
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Accountant Phone'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccountantPhone: TEdit
      Left = 612
      Top = 278
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 28
    end
    object lblAccountantEmail: TLabel
      Left = 484
      Top = 305
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Accountant E-Mail'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccountantEmail: TEdit
      Left = 612
      Top = 301
      Width = 333
      Height = 22
      MaxLength = 128
      TabOrder = 29
    end
    object lblAccountantAuthorized: TLabel
      Left = 484
      Top = 328
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Accountant Contact'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccountantAuthorized: TEdit
      Left = 612
      Top = 324
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 30
    end
  end
end

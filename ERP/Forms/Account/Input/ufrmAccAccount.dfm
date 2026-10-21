object frmAccAccount: TfrmAccAccount
  Left = 0
  Top = 0
  Caption = 'Account Card'
  ClientHeight = 397
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
    Height = 397
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pgcMain: TPageControl
      Left = 0
      Top = 0
      Width = 960
      Height = 397
      ActivePage = tsGeneral
      Align = alClient
      TabOrder = 0
      object tsGeneral: TTabSheet
        Caption = 'General'
        object lblCode: TLabel
          Left = 4
          Top = 52
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
        object lblName: TLabel
          Left = 4
          Top = 75
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
        object lblAccGroupId: TLabel
          Left = 4
          Top = 98
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
        object lblAccRegionId: TLabel
          Left = 4
          Top = 121
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
        object lblRootCode: TLabel
          Left = 4
          Top = 6
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
        object lblSubCode: TLabel
          Left = 4
          Top = 29
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
        object lblIban: TLabel
          Left = 4
          Top = 144
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
        object lblDiscountRate: TLabel
          Left = 4
          Top = 167
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
        object lblEInvoiceActive: TLabel
          Left = 4
          Top = 190
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
        object lblIsPassive: TLabel
          Left = 4
          Top = 213
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
        object lblNotes: TLabel
          Left = 4
          Top = 236
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
        object lblEInvoicePkAlias: TLabel
          Left = 476
          Top = 6
          Width = 210
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'e-Invoice Mailbox (PK)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblEInvoiceGbAlias: TLabel
          Left = 476
          Top = 29
          Width = 210
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'e-Invoice Sender Unit (GB)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblEDespatchPkAlias: TLabel
          Left = 476
          Top = 52
          Width = 210
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'e-Despatch Mailbox (PK)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblEDespatchGbAlias: TLabel
          Left = 476
          Top = 75
          Width = 210
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'e-Despatch Sender Unit (GB)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object cbbCode: TComboBox
          Left = 132
          Top = 48
          Width = 333
          Height = 22
          Style = csDropDownList
          TabOrder = 2
        end
        object edtName: TEdit
          Left = 132
          Top = 71
          Width = 333
          Height = 22
          MaxLength = 128
          TabOrder = 3
        end
        object edtAccGroupId: TEdit
          Left = 132
          Top = 94
          Width = 333
          Height = 22
          ReadOnly = True
          TabOrder = 4
        end
        object edtAccRegionId: TEdit
          Left = 132
          Top = 117
          Width = 333
          Height = 22
          ReadOnly = True
          TabOrder = 5
        end
        object cbbRootCode: TComboBox
          Left = 132
          Top = 2
          Width = 333
          Height = 22
          Style = csDropDownList
          TabOrder = 0
        end
        object cbbSubCode: TComboBox
          Left = 132
          Top = 25
          Width = 333
          Height = 22
          Style = csDropDownList
          TabOrder = 1
        end
        object edtIban: TEdit
          Left = 132
          Top = 140
          Width = 285
          Height = 22
          MaxLength = 64
          TabOrder = 6
        end
        object edtIbanCurrency: TEdit
          Left = 416
          Top = 140
          Width = 49
          Height = 22
          MaxLength = 3
          ReadOnly = True
          TabOrder = 7
        end
        object edtDiscountRate: TEdit
          Left = 132
          Top = 163
          Width = 333
          Height = 22
          TabOrder = 8
        end
        object chkEInvoiceActive: TCheckBox
          Left = 132
          Top = 188
          Width = 150
          Height = 17
          TabOrder = 9
        end
        object chkEDespatchActive: TCheckBox
          Left = 288
          Top = 188
          Width = 177
          Height = 17
          Caption = 'e-Despatch Active'
          TabOrder = 10
        end
        object chkIsPassive: TCheckBox
          Left = 132
          Top = 211
          Width = 333
          Height = 17
          TabOrder = 11
        end
        object edtNotes: TEdit
          Left = 132
          Top = 232
          Width = 333
          Height = 22
          MaxLength = 512
          TabOrder = 12
        end
        object edtEInvoicePkAlias: TEdit
          Left = 690
          Top = 2
          Width = 255
          Height = 22
          MaxLength = 256
          TabOrder = 13
        end
        object edtEInvoiceGbAlias: TEdit
          Left = 690
          Top = 25
          Width = 255
          Height = 22
          MaxLength = 256
          TabOrder = 14
        end
        object edtEDespatchPkAlias: TEdit
          Left = 690
          Top = 48
          Width = 255
          Height = 22
          MaxLength = 256
          TabOrder = 15
        end
        object edtEDespatchGbAlias: TEdit
          Left = 690
          Top = 71
          Width = 255
          Height = 22
          MaxLength = 256
          TabOrder = 16
        end
      end
      object tsTaxpayer: TTabSheet
        Caption = 'Taxpayer'
        object lblTaxpayerType: TLabel
          Left = 4
          Top = 6
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
        object lblTaxpayerName: TLabel
          Left = 4
          Top = 29
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
        object lblTaxpayerName2: TLabel
          Left = 4
          Top = 52
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
        object lblTaxpayerSurname: TLabel
          Left = 4
          Top = 75
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
        object lblTaxOffice: TLabel
          Left = 4
          Top = 98
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
        object lblTaxNo: TLabel
          Left = 4
          Top = 121
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
        object lblNaceCode: TLabel
          Left = 4
          Top = 144
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
        object cbbTaxpayerType: TComboBox
          Left = 132
          Top = 2
          Width = 333
          Height = 22
          Style = csDropDownList
          TabOrder = 0
        end
        object edtTaxpayerName: TEdit
          Left = 132
          Top = 25
          Width = 333
          Height = 22
          MaxLength = 32
          TabOrder = 1
        end
        object edtTaxpayerName2: TEdit
          Left = 132
          Top = 48
          Width = 333
          Height = 22
          MaxLength = 32
          TabOrder = 2
        end
        object edtTaxpayerSurname: TEdit
          Left = 132
          Top = 71
          Width = 333
          Height = 22
          MaxLength = 32
          TabOrder = 3
        end
        object edtTaxOffice: TEdit
          Left = 132
          Top = 94
          Width = 333
          Height = 22
          MaxLength = 64
          TabOrder = 4
        end
        object edtTaxNo: TEdit
          Left = 132
          Top = 117
          Width = 333
          Height = 22
          MaxLength = 32
          TabOrder = 5
        end
        object edtNaceCode: TEdit
          Left = 132
          Top = 140
          Width = 333
          Height = 22
          MaxLength = 32
          TabOrder = 6
        end
      end
      object tsContact: TTabSheet
        Caption = 'Contact'
        object lblAuthorizedPerson1: TLabel
          Left = 4
          Top = 6
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
        object lblAuthorizedPhone1: TLabel
          Left = 4
          Top = 29
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
        object lblAuthorizedPerson2: TLabel
          Left = 4
          Top = 52
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
        object lblAuthorizedPhone2: TLabel
          Left = 4
          Top = 75
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
        object lblAuthorizedPerson3: TLabel
          Left = 4
          Top = 98
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
        object lblAuthorizedPhone3: TLabel
          Left = 4
          Top = 121
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
        object lblFax: TLabel
          Left = 4
          Top = 144
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
        object lblAccountantAuthorized: TLabel
          Left = 484
          Top = 6
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
        object lblAccountantPhone: TLabel
          Left = 484
          Top = 29
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
        object lblAccountantEmail: TLabel
          Left = 484
          Top = 52
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
        object edtAuthorizedPerson1: TEdit
          Left = 132
          Top = 2
          Width = 333
          Height = 22
          MaxLength = 64
          TabOrder = 0
        end
        object edtAuthorizedPhone1: TEdit
          Left = 132
          Top = 25
          Width = 333
          Height = 22
          MaxLength = 32
          TabOrder = 1
        end
        object edtAuthorizedPerson2: TEdit
          Left = 132
          Top = 48
          Width = 333
          Height = 22
          MaxLength = 64
          TabOrder = 2
        end
        object edtAuthorizedPhone2: TEdit
          Left = 132
          Top = 71
          Width = 333
          Height = 22
          MaxLength = 32
          TabOrder = 3
        end
        object edtAuthorizedPerson3: TEdit
          Left = 132
          Top = 94
          Width = 333
          Height = 22
          MaxLength = 64
          TabOrder = 4
        end
        object edtAuthorizedPhone3: TEdit
          Left = 132
          Top = 117
          Width = 333
          Height = 22
          MaxLength = 32
          TabOrder = 5
        end
        object edtFax: TEdit
          Left = 132
          Top = 140
          Width = 333
          Height = 22
          MaxLength = 32
          TabOrder = 6
        end
        object edtAccountantAuthorized: TEdit
          Left = 612
          Top = 2
          Width = 333
          Height = 22
          MaxLength = 32
          TabOrder = 7
        end
        object edtAccountantPhone: TEdit
          Left = 612
          Top = 25
          Width = 333
          Height = 22
          MaxLength = 32
          TabOrder = 8
        end
        object edtAccountantEmail: TEdit
          Left = 612
          Top = 48
          Width = 333
          Height = 22
          MaxLength = 128
          TabOrder = 9
        end
      end
      object tsBillingAddress: TTabSheet
        Caption = 'Billing Address'
      end
      object tsShippingAddress: TTabSheet
        Caption = 'Shipping Address'
      end
      object tsLegalAddress: TTabSheet
        Caption = 'Legal Address'
      end
      object tsOtherAddress: TTabSheet
        Caption = 'Other Address'
      end
    end
  end
end

object frmAccAccount: TfrmAccAccount
  Left = 0
  Top = 0
  Caption = 'frmAccAccount'
  ClientHeight = 567
  ClientWidth = 650
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 650
    Height = 567
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 648
    ExplicitHeight = 565
    object lblcode: TLabel
      Left = 20
      Top = 11
      Width = 36
      Height = 13
      Alignment = taRightJustify
      Caption = 'Code'
      Font.Style = [fsBold]
    end
    object edtcode: TEdit
      Left = 80
      Top = 7
      Width = 250
      Height = 23
      TabOrder = 0
    end
    object lblname: TLabel
      Left = 24
      Top = 41
      Width = 32
      Height = 13
      Alignment = taRightJustify
      Caption = 'Name'
      Font.Style = [fsBold]
    end
    object edtname: TEdit
      Left = 80
      Top = 37
      Width = 540
      Height = 23
      TabOrder = 1
    end
    object lbltype_id: TLabel
      Left = 12
      Top = 71
      Width = 44
      Height = 13
      Alignment = taRightJustify
      Caption = 'Type'
      Font.Style = [fsBold]
    end
    object eddtype_id: TEdit
      Left = 80
      Top = 67
      Width = 350
      Height = 23
      ReadOnly = True
      TabOrder = 2
    end
    object btn_type_sec: TButton
      Left = 436
      Top = 63
      Width = 75
      Height = 25
      Caption = 'Select'
      TabOrder = 3
    end
    object lblgroup_id: TLabel
      Left = 10
      Top = 101
      Width = 46
      Height = 13
      Alignment = taRightJustify
      Caption = 'Group'
      Font.Style = [fsBold]
    end
    object edtgroup_id: TEdit
      Left = 80
      Top = 97
      Width = 350
      Height = 23
      ReadOnly = True
      TabOrder = 4
    end
    object btn_group_sec: TButton
      Left = 436
      Top = 93
      Width = 75
      Height = 25
      Caption = 'Select'
      TabOrder = 5
    end
    object lblregion_id: TLabel
      Left = 6
      Top = 131
      Width = 50
      Height = 13
      Alignment = taRightJustify
      Caption = 'Region'
      Font.Style = [fsBold]
    end
    object edtregion_id: TEdit
      Left = 80
      Top = 127
      Width = 350
      Height = 23
      ReadOnly = True
      TabOrder = 6
    end
    object btn_region_sec: TButton
      Left = 436
      Top = 123
      Width = 75
      Height = 25
      Caption = 'Select'
      TabOrder = 7
    end
    object lbltaxpayer_name: TLabel
      Left = 0
      Top = 161
      Width = 60
      Height = 13
      Alignment = taRightJustify
      Caption = 'Taxpayer Name'
      Font.Style = [fsBold]
    end
    object edtaxpayer_name: TEdit
      Left = 80
      Top = 157
      Width = 250
      Height = 23
      TabOrder = 8
    end
    object lbltaxpayer_surname: TLabel
      Left = -6
      Top = 191
      Width = 66
      Height = 13
      Alignment = taRightJustify
      Caption = 'Taxpayer Surname'
      Font.Style = [fsBold]
    end
    object edtaxpayer_surname: TEdit
      Left = 80
      Top = 187
      Width = 250
      Height = 23
      TabOrder = 9
    end
    object lbntax_no: TLabel
      Left = 26
      Top = 221
      Width = 40
      Height = 13
      Alignment = taRightJustify
      Caption = 'Tax No'
      Font.Style = [fsBold]
    end
    object edtax_no: TEdit
      Left = 80
      Top = 217
      Width = 150
      Height = 23
      TabOrder = 10
    end
    object lbntax_office: TLabel
      Left = 16
      Top = 251
      Width = 50
      Height = 13
      Alignment = taRightJustify
      Caption = 'Tax Office'
      Font.Style = [fsBold]
    end
    object edt_tax_office: TEdit
      Left = 80
      Top = 247
      Width = 250
      Height = 23
      TabOrder = 11
    end
    object lbliban: TLabel
      Left = 36
      Top = 281
      Width = 30
      Height = 13
      Alignment = taRightJustify
      Caption = 'IBAN'
      Font.Style = [fsBold]
    end
    object edtiban: TEdit
      Left = 80
      Top = 277
      Width = 450
      Height = 23
      TabOrder = 12
    end
    object lblfax: TLabel
      Left = 38
      Top = 311
      Width = 28
      Height = 13
      Alignment = taRightJustify
      Caption = 'Fax'
      Font.Style = [fsBold]
    end
    object edtfax: TEdit
      Left = 80
      Top = 307
      Width = 250
      Height = 23
      TabOrder = 13
    end
    object lblaccountant_phone: TLabel
      Left = -6
      Top = 341
      Width = 66
      Height = 13
      Alignment = taRightJustify
      Caption = 'Acct Phone'
      Font.Style = [fsBold]
    end
    object edtaccountant_phone: TEdit
      Left = 80
      Top = 337
      Width = 250
      Height = 23
      TabOrder = 14
    end
    object lblaccountant_email: TLabel
      Left = -16
      Top = 371
      Width = 76
      Height = 13
      Alignment = taRightJustify
      Caption = 'Acct Email'
      Font.Style = [fsBold]
    end
    object edtaccountant_email: TEdit
      Left = 80
      Top = 367
      Width = 350
      Height = 23
      TabOrder = 15
    end
    object chk_e_invoice_active: TCheckBox
      Left = 80
      Top = 400
      Width = 180
      Height = 17
      Caption = 'E-Invoice Active'
      TabOrder = 16
    end
    object lbldiscount_rate: TLabel
      Left = -2
      Top = 430
      Width = 62
      Height = 13
      Alignment = taRightJustify
      Caption = 'Discount Rate'
      Font.Style = [fsBold]
    end
    object edtdiscount_rate: TSpinEdit
      Left = 80
      Top = 426
      Width = 100
      Height = 23
      MaxValue = 100
      MinValue = 0
      TabOrder = 17
      Value = 0.000000000000000000
    end
  end
end

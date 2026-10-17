object frmEInvTaxExemption: TfrmEInvTaxExemption
  Left = 0
  Top = 0
  Caption = 'Vergi '#304'stisna Kodu'
  ClientHeight = 253
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
    Height = 253
    Align = alClient
    TabOrder = 0
    object lblCode: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'stisna Kodu'
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
      Width = 420
      Height = 22
      MaxLength = 8
      TabOrder = 0
    end
    object lblName: TLabel
      Left = 4
      Top = 29
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
    object edtName: TEdit
      Left = 132
      Top = 25
      Width = 420
      Height = 22
      MaxLength = 512
      TabOrder = 1
    end
    object lblExemptionGroup: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'stisna Grubu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbExemptionGroup: TComboBox
      Left = 132
      Top = 48
      Width = 420
      Height = 22
      Style = csDropDownList
      TabOrder = 2
    end
    object lblEinvInvoiceTypeId: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Fatura Tipi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEinvInvoiceTypeId: TEdit
      Left = 132
      Top = 71
      Width = 420
      Height = 22
      ReadOnly = True
      TabOrder = 3
    end
    object lblRequiresGtip: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kalemde GT'#304'P Zorunlu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkRequiresGtip: TCheckBox
      Left = 132
      Top = 97
      Width = 420
      Height = 17
      TabOrder = 4
    end
    object lblRequiresDiib: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'D'#304#304'B Sat'#305'r Kodu Zorunlu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkRequiresDiib: TCheckBox
      Left = 132
      Top = 120
      Width = 420
      Height = 17
      TabOrder = 5
    end
    object lblRequiresZeroVat: TLabel
      Left = 4
      Top = 144
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '%0 KDV'#39'li Kalem Gerekir'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkRequiresZeroVat: TCheckBox
      Left = 132
      Top = 143
      Width = 420
      Height = 17
      TabOrder = 6
    end
    object lblIsActive: TLabel
      Left = 4
      Top = 167
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
      Top = 166
      Width = 420
      Height = 17
      TabOrder = 7
    end
  end
end

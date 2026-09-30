object frmAccAccountAddress: TfrmAccAccountAddress
  Left = 0
  Top = 0
  Caption = 'Account Address'
  ClientHeight = 208
  ClientWidth = 480
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
    Width = 480
    Height = 208
    Align = alClient
    TabOrder = 0
    object lblAccAccountId: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Account'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccAccountId: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 0
    end
    object lblSysAddressId: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Address'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSysAddressId: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 1
    end
    object lblAddressType: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Address Type'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbAddressType: TComboBox
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      Style = csDropDownList
      TabOrder = 2
      Items.Strings = (
        'BILLING'
        'SHIPPING'
        'LEGAL'
        'OTHER')
    end
    object lblIsPrimary: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Primary'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkIsPrimary: TCheckBox
      Left = 132
      Top = 73
      Width = 333
      Height = 17
      TabOrder = 3
    end
    object lblValidFrom: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Valid From'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtValidFrom: TEdit
      Left = 132
      Top = 94
      Width = 333
      Height = 22
      TabOrder = 4
    end
    object lblValidTo: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Valid To'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtValidTo: TEdit
      Left = 132
      Top = 117
      Width = 333
      Height = 22
      TabOrder = 5
    end
  end
end

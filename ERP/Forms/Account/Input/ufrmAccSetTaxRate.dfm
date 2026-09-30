object frmAccSetTaxRate: TfrmAccSetTaxRate
  Left = 0
  Top = 0
  Caption = 'Tax Rate'
  ClientHeight = 185
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
    Height = 185
    Align = alClient
    TabOrder = 0
    object lblTaxRate: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Tax Rate'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTaxRate: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      TabOrder = 0
    end
    object lblSalesAccount: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sales Account'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSalesAccount: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      MaxLength = 16
      ReadOnly = True
      TabOrder = 1
    end
    object lblSalesReturnAccount: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sales Return Account'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSalesReturnAccount: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      MaxLength = 16
      ReadOnly = True
      TabOrder = 2
    end
    object lblPurchaseAccount: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Purchase Account'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPurchaseAccount: TEdit
      Left = 132
      Top = 71
      Width = 333
      Height = 22
      MaxLength = 16
      ReadOnly = True
      TabOrder = 3
    end
    object lblPurchaseReturnAccount: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Purchase Return Account'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPurchaseReturnAccount: TEdit
      Left = 132
      Top = 94
      Width = 333
      Height = 22
      MaxLength = 16
      ReadOnly = True
      TabOrder = 4
    end
  end
end

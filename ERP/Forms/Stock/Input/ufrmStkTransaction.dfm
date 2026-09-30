object frmStkTransaction: TfrmStkTransaction
  Left = 0
  Top = 0
  Caption = 'Stock Transaction'
  ClientHeight = 208
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
    Height = 208
    Align = alClient
    TabOrder = 0
    object lblTransactionDate: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Date'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTransactionDate: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      TabOrder = 0
    end
    object lblTransactionType: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Transaction Type'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbTransactionType: TComboBox
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      Style = csDropDownList
      TabOrder = 1
    end
    object lblStkInventoryId: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Stock Card'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtStkInventoryId: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 2
    end
    object lblFromStkWarehouseId: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'From Warehouse'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtFromStkWarehouseId: TEdit
      Left = 132
      Top = 71
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 3
    end
    object lblToStkWarehouseId: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'To Warehouse'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtToStkWarehouseId: TEdit
      Left = 132
      Top = 94
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 4
    end
    object lblQuantity: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Quantity'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtQuantity: TEdit
      Left = 132
      Top = 117
      Width = 333
      Height = 22
      TabOrder = 5
    end
    object lblAmount: TLabel
      Left = 484
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Amount'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAmount: TEdit
      Left = 612
      Top = 2
      Width = 333
      Height = 22
      TabOrder = 6
    end
    object lblAmountForeign: TLabel
      Left = 484
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Foreign Amount'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAmountForeign: TEdit
      Left = 612
      Top = 25
      Width = 333
      Height = 22
      TabOrder = 7
    end
    object lblCurrency: TLabel
      Left = 484
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Currency'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCurrency: TEdit
      Left = 612
      Top = 48
      Width = 333
      Height = 22
      MaxLength = 3
      ReadOnly = True
      TabOrder = 8
    end
    object lblIsOpening: TLabel
      Left = 484
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Opening Balance'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkIsOpening: TCheckBox
      Left = 612
      Top = 73
      Width = 333
      Height = 17
      TabOrder = 9
    end
    object lblDescription: TLabel
      Left = 484
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Description'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDescription: TEdit
      Left = 612
      Top = 94
      Width = 333
      Height = 22
      MaxLength = 128
      TabOrder = 10
    end
  end
end

object frmPurInvoiceLine: TfrmPurInvoiceLine
  Left = 0
  Top = 0
  Caption = 'Fatura Kalemi'
  ClientHeight = 230
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
    Height = 230
    Align = alClient
    TabOrder = 0
    object lblLineNo: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'S'#305'ra No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtLineNo: TEdit
      Left = 132
      Top = 2
      Width = 80
      Height = 22
      TabOrder = 0
    end
    object lblStkInventoryId: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Stok Kart'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtStkInventoryId: TEdit
      Left = 132
      Top = 25
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 1
    end
    object lblQuantity: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Miktar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtQuantity: TEdit
      Left = 132
      Top = 48
      Width = 150
      Height = 22
      TabOrder = 2
    end
    object lblUomCode: TLabel
      Left = 288
      Top = 52
      Width = 104
      Height = 13
      Alignment = taLeftJustify
      AutoSize = False
      Caption = ''
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblUnitPrice: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Birim Fiyat'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtUnitPrice: TEdit
      Left = 132
      Top = 71
      Width = 150
      Height = 22
      TabOrder = 3
    end
    object lblPriceCurrency: TLabel
      Left = 288
      Top = 75
      Width = 104
      Height = 13
      Alignment = taLeftJustify
      AutoSize = False
      Caption = ''
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblDiscountRate: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'skonto (%)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDiscountRate: TEdit
      Left = 132
      Top = 94
      Width = 150
      Height = 22
      TabOrder = 4
    end
    object lblVatRate: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'KDV (%)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbVatRate: TComboBox
      Left = 132
      Top = 117
      Width = 150
      Height = 22
      Style = csDropDownList
      TabOrder = 5
    end
    object lblDescription: TLabel
      Left = 4
      Top = 144
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
      Top = 140
      Width = 260
      Height = 22
      MaxLength = 128
      TabOrder = 6
    end
    object pnlTotals: TPanel
      Left = 408
      Top = 2
      Width = 395
      Height = 140
      BevelOuter = bvLowered
      TabOrder = 7
    end
  end
end

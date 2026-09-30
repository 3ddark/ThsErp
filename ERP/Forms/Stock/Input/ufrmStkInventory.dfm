object frmStkInventory: TfrmStkInventory
  Left = 0
  Top = 0
  Caption = 'Stock Card'
  ClientHeight = 415
  ClientWidth = 1160
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
    Width = 1160
    Height = 415
    Align = alClient
    TabOrder = 0
    object lblCode: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Stock Code'
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
      MaxLength = 32
      TabOrder = 0
    end
    object lblName: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Stock Name'
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
    object lblStkGroupId: TLabel
      Left = 4
      Top = 52
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
    object edtStkGroupId: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 2
    end
    object lblStkProductTypeId: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Product Type'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtStkProductTypeId: TEdit
      Left = 132
      Top = 71
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 3
    end
    object lblSysUomId: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Unit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSysUomId: TEdit
      Left = 132
      Top = 94
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 4
    end
    object lblSellable: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sellable'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkSellable: TCheckBox
      Left = 132
      Top = 119
      Width = 333
      Height = 17
      TabOrder = 5
    end
    object lblBuyingPrice: TLabel
      Left = 4
      Top = 144
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Buying Price'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBuyingPrice: TEdit
      Left = 132
      Top = 140
      Width = 333
      Height = 22
      TabOrder = 6
    end
    object lblBuyingCurrency: TLabel
      Left = 4
      Top = 167
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Buying Currency'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBuyingCurrency: TEdit
      Left = 132
      Top = 163
      Width = 333
      Height = 22
      MaxLength = 3
      ReadOnly = True
      TabOrder = 7
    end
    object lblBuyingDiscount: TLabel
      Left = 4
      Top = 190
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Buying Discount (%)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBuyingDiscount: TEdit
      Left = 132
      Top = 186
      Width = 333
      Height = 22
      TabOrder = 8
    end
    object lblSalesPrice: TLabel
      Left = 4
      Top = 213
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sales Price'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSalesPrice: TEdit
      Left = 132
      Top = 209
      Width = 333
      Height = 22
      TabOrder = 9
    end
    object lblSalesCurrency: TLabel
      Left = 4
      Top = 236
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sales Currency'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSalesCurrency: TEdit
      Left = 132
      Top = 232
      Width = 333
      Height = 22
      MaxLength = 3
      ReadOnly = True
      TabOrder = 10
    end
    object lblSalesDiscount: TLabel
      Left = 4
      Top = 259
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sales Discount (%)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSalesDiscount: TEdit
      Left = 132
      Top = 255
      Width = 333
      Height = 22
      TabOrder = 11
    end
    object lblExportPrice: TLabel
      Left = 4
      Top = 282
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Export Price'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtExportPrice: TEdit
      Left = 132
      Top = 278
      Width = 333
      Height = 22
      TabOrder = 12
    end
    object lblExportCurrency: TLabel
      Left = 484
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Export Currency'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtExportCurrency: TEdit
      Left = 612
      Top = 2
      Width = 333
      Height = 22
      MaxLength = 3
      ReadOnly = True
      TabOrder = 13
    end
    object lblSpecialCode: TLabel
      Left = 484
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Special Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSpecialCode: TEdit
      Left = 612
      Top = 25
      Width = 333
      Height = 22
      MaxLength = 16
      TabOrder = 14
    end
    object lblBrand: TLabel
      Left = 484
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Brand'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBrand: TEdit
      Left = 612
      Top = 48
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 15
    end
    object lblWidth: TLabel
      Left = 484
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Width'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtWidth: TEdit
      Left = 612
      Top = 71
      Width = 333
      Height = 22
      TabOrder = 16
    end
    object lblLength: TLabel
      Left = 484
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Length'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtLength: TEdit
      Left = 612
      Top = 94
      Width = 333
      Height = 22
      TabOrder = 17
    end
    object lblHeight: TLabel
      Left = 484
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Height'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtHeight: TEdit
      Left = 612
      Top = 117
      Width = 333
      Height = 22
      TabOrder = 18
    end
    object lblWeight: TLabel
      Left = 484
      Top = 144
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Weight'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtWeight: TEdit
      Left = 612
      Top = 140
      Width = 333
      Height = 22
      TabOrder = 19
    end
    object lblSupplyDuration: TLabel
      Left = 484
      Top = 167
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Supply Duration (Days)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSupplyDuration: TEdit
      Left = 612
      Top = 163
      Width = 333
      Height = 22
      TabOrder = 20
    end
    object lblMinStockAmount: TLabel
      Left = 484
      Top = 190
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Minimum Stock'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtMinStockAmount: TEdit
      Left = 612
      Top = 186
      Width = 333
      Height = 22
      TabOrder = 21
    end
    object lblSysCountryId: TLabel
      Left = 484
      Top = 213
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Origin Country'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSysCountryId: TEdit
      Left = 612
      Top = 209
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 22
    end
    object lblHsNo: TLabel
      Left = 484
      Top = 236
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'HS Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtHsNo: TEdit
      Left = 612
      Top = 232
      Width = 333
      Height = 22
      MaxLength = 16
      TabOrder = 23
    end
    object lblDiibProductDescription: TLabel
      Left = 484
      Top = 259
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'DIIB Description'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDiibProductDescription: TEdit
      Left = 612
      Top = 255
      Width = 333
      Height = 22
      MaxLength = 64
      TabOrder = 24
    end
    object lblProductOverview: TLabel
      Left = 484
      Top = 282
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Product Overview'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object mmoProductOverview: TMemo
      Left = 612
      Top = 278
      Width = 333
      Height = 66
      ScrollBars = ssVertical
      TabOrder = 25
    end
    object lblImage: TLabel
      Left = 964
      Top = 6
      Width = 184
      Height = 13
      AutoSize = False
      Caption = 'Image'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object pnlImage: TPanel
      Left = 964
      Top = 24
      Width = 184
      Height = 184
      BevelOuter = bvLowered
      TabOrder = 26
      object imgImage: TImage
        Left = 1
        Top = 1
        Width = 182
        Height = 182
        Align = alClient
        Center = True
        Proportional = True
        Stretch = True
      end
    end
    object btnImageLoad: TButton
      Left = 964
      Top = 214
      Width = 90
      Height = 25
      Caption = 'Load...'
      TabOrder = 27
      OnClick = btnImageLoadClick
    end
    object btnImageClear: TButton
      Left = 1058
      Top = 214
      Width = 90
      Height = 25
      Caption = 'Clear'
      TabOrder = 28
      OnClick = btnImageClearClick
    end
  end
end

object frmStkInventory: TfrmStkInventory
  Left = 0
  Top = 0
  Caption = 'Stock Card'
  ClientHeight = 368
  ClientWidth = 940
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
    Width = 940
    Height = 368
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pgcMain: TPageControl
      Left = 0
      Top = 0
      Width = 940
      Height = 368
      ActivePage = tsGeneral
      Align = alClient
      TabOrder = 0
      object tsGeneral: TTabSheet
        Caption = 'General'
        object lblCode: TLabel
          Left = 4
          Top = 10
          Width = 120
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
          Left = 128
          Top = 6
          Width = 230
          Height = 22
          MaxLength = 32
          TabOrder = 0
        end
        object lblName: TLabel
          Left = 4
          Top = 33
          Width = 120
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
          Left = 128
          Top = 29
          Width = 230
          Height = 22
          MaxLength = 128
          TabOrder = 1
        end
        object lblStkGroupId: TLabel
          Left = 4
          Top = 56
          Width = 120
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
          Left = 128
          Top = 52
          Width = 230
          Height = 22
          ReadOnly = True
          TabOrder = 2
        end
        object lblStkProductTypeId: TLabel
          Left = 4
          Top = 79
          Width = 120
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
          Left = 128
          Top = 75
          Width = 230
          Height = 22
          ReadOnly = True
          TabOrder = 3
        end
        object lblSysUomId: TLabel
          Left = 4
          Top = 102
          Width = 120
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
          Left = 128
          Top = 98
          Width = 230
          Height = 22
          ReadOnly = True
          TabOrder = 4
        end
        object lblSellable: TLabel
          Left = 4
          Top = 125
          Width = 120
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
          Left = 128
          Top = 123
          Width = 230
          Height = 17
          TabOrder = 5
        end
        object lblSpecialCode: TLabel
          Left = 4
          Top = 148
          Width = 120
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
          Left = 128
          Top = 144
          Width = 230
          Height = 22
          MaxLength = 16
          TabOrder = 6
        end
        object lblBrand: TLabel
          Left = 4
          Top = 171
          Width = 120
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
          Left = 128
          Top = 167
          Width = 230
          Height = 22
          MaxLength = 32
          TabOrder = 7
        end
        object lblMinStockAmount: TLabel
          Left = 4
          Top = 194
          Width = 120
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
          Left = 128
          Top = 190
          Width = 230
          Height = 22
          TabOrder = 8
        end
        object lblSupplyDuration: TLabel
          Left = 4
          Top = 217
          Width = 120
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
          Left = 128
          Top = 213
          Width = 230
          Height = 22
          TabOrder = 9
        end
        object lblWidth: TLabel
          Left = 366
          Top = 10
          Width = 120
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
          Left = 490
          Top = 6
          Width = 230
          Height = 22
          TabOrder = 10
        end
        object lblLength: TLabel
          Left = 366
          Top = 33
          Width = 120
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
          Left = 490
          Top = 29
          Width = 230
          Height = 22
          TabOrder = 11
        end
        object lblHeight: TLabel
          Left = 366
          Top = 56
          Width = 120
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
          Left = 490
          Top = 52
          Width = 230
          Height = 22
          TabOrder = 12
        end
        object lblWeight: TLabel
          Left = 366
          Top = 79
          Width = 120
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
          Left = 490
          Top = 75
          Width = 230
          Height = 22
          TabOrder = 13
        end
        object lblSysCountryId: TLabel
          Left = 366
          Top = 102
          Width = 120
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
          Left = 490
          Top = 98
          Width = 230
          Height = 22
          ReadOnly = True
          TabOrder = 14
        end
        object lblEinvGtipId: TLabel
          Left = 366
          Top = 125
          Width = 120
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'GT'#304'P'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvGtipId: TEdit
          Left = 490
          Top = 121
          Width = 230
          Height = 22
          ReadOnly = True
          TabOrder = 15
        end
        object lblDiibProductDescription: TLabel
          Left = 366
          Top = 148
          Width = 120
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
          Left = 490
          Top = 144
          Width = 230
          Height = 22
          MaxLength = 512
          TabOrder = 16
        end
        object lblProductOverview: TLabel
          Left = 366
          Top = 171
          Width = 120
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
          Left = 490
          Top = 167
          Width = 230
          Height = 68
          ScrollBars = ssVertical
          TabOrder = 17
        end
        object lblImage: TLabel
          Left = 736
          Top = 8
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
          Left = 736
          Top = 26
          Width = 184
          Height = 176
          BevelOuter = bvLowered
          TabOrder = 18
          object imgImage: TImage
            Left = 1
            Top = 1
            Width = 182
            Height = 174
            Align = alClient
            Center = True
            Proportional = True
            Stretch = True
          end
        end
        object btnImageLoad: TButton
          Left = 736
          Top = 208
          Width = 90
          Height = 25
          Caption = 'Load...'
          TabOrder = 19
          OnClick = btnImageLoadClick
        end
        object btnImageClear: TButton
          Left = 830
          Top = 208
          Width = 90
          Height = 25
          Caption = 'Clear'
          TabOrder = 20
          OnClick = btnImageClearClick
        end
      end
      object tsMonetary: TTabSheet
        Caption = 'Monetary'
        object lblBuyingPrice: TLabel
          Left = 4
          Top = 10
          Width = 120
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
          Left = 128
          Top = 6
          Width = 230
          Height = 22
          TabOrder = 0
        end
        object lblBuyingCurrency: TLabel
          Left = 4
          Top = 33
          Width = 120
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
          Left = 128
          Top = 29
          Width = 230
          Height = 22
          MaxLength = 3
          ReadOnly = True
          TabOrder = 1
        end
        object lblBuyingDiscount: TLabel
          Left = 4
          Top = 56
          Width = 120
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
          Left = 128
          Top = 52
          Width = 230
          Height = 22
          TabOrder = 2
        end
        object lblExportPrice: TLabel
          Left = 4
          Top = 102
          Width = 120
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
          Left = 128
          Top = 98
          Width = 230
          Height = 22
          TabOrder = 3
        end
        object lblExportCurrency: TLabel
          Left = 4
          Top = 125
          Width = 120
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
          Left = 128
          Top = 121
          Width = 230
          Height = 22
          MaxLength = 3
          ReadOnly = True
          TabOrder = 4
        end
        object lblSalesPrice: TLabel
          Left = 366
          Top = 10
          Width = 120
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
          Left = 490
          Top = 6
          Width = 230
          Height = 22
          TabOrder = 5
        end
        object lblSalesCurrency: TLabel
          Left = 366
          Top = 33
          Width = 120
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
          Left = 490
          Top = 29
          Width = 230
          Height = 22
          MaxLength = 3
          ReadOnly = True
          TabOrder = 6
        end
        object lblSalesDiscount: TLabel
          Left = 366
          Top = 56
          Width = 120
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
          Left = 490
          Top = 52
          Width = 230
          Height = 22
          TabOrder = 7
        end
        object lblCurrentQuantity: TLabel
          Left = 366
          Top = 102
          Width = 120
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Current Quantity'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblCurrentQuantityVal: TLabel
          Left = 490
          Top = 102
          Width = 230
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblAverageCost: TLabel
          Left = 366
          Top = 125
          Width = 120
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Average Cost'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblAverageCostVal: TLabel
          Left = 490
          Top = 125
          Width = 230
          Height = 13
          AutoSize = False
          Caption = '-'
        end
      end
      object tsKind: TTabSheet
        Caption = 'Kind Properties'
        object lblKindName: TLabel
          Left = 4
          Top = 10
          Width = 600
          Height = 13
          AutoSize = False
          Caption = '-'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object btnKindEdit: TButton
          Left = 680
          Top = 4
          Width = 240
          Height = 25
          Caption = 'Edit Kind Information...'
          TabOrder = 0
          OnClick = btnKindEditClick
        end
        object grdKindValues: TStringGrid
          Left = 4
          Top = 36
          Width = 600
          Height = 228
          ColCount = 2
          DefaultColWidth = 290
          DefaultRowHeight = 20
          FixedCols = 0
          RowCount = 2
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
          TabOrder = 1
        end
      end
      object tsAccounting: TTabSheet
        Caption = 'Group Properties / Accounting'
        object lblAccountingInfo: TLabel
          Left = 4
          Top = 6
          Width = 916
          Height = 30
          AutoSize = False
          Caption = 'Info'
          WordWrap = True
        end
        object lblOverrideHeader: TLabel
          Left = 188
          Top = 42
          Width = 150
          Height = 13
          AutoSize = False
          Caption = 'Card Specific'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblDefaultHeader: TLabel
          Left = 346
          Top = 42
          Width = 574
          Height = 13
          AutoSize = False
          Caption = 'From Group'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblVatRate: TLabel
          Left = 4
          Top = 66
          Width = 180
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'VAT Rate (%)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object cbbVatRate: TComboBox
          Left = 188
          Top = 62
          Width = 150
          Height = 22
          Style = csDropDownList
          TabOrder = 0
        end
        object lblDefaultVatRate: TLabel
          Left = 346
          Top = 66
          Width = 574
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblRawMaterialStockAccount: TLabel
          Left = 4
          Top = 91
          Width = 180
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Raw Material Stock Account'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtRawMaterialStockAccount: TEdit
          Left = 188
          Top = 87
          Width = 150
          Height = 22
          MaxLength = 16
          ReadOnly = True
          TabOrder = 1
        end
        object lblDefaultRawMaterialStockAccount: TLabel
          Left = 346
          Top = 91
          Width = 574
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblRawMaterialUsageAccount: TLabel
          Left = 4
          Top = 116
          Width = 180
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Raw Material Usage Account'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtRawMaterialUsageAccount: TEdit
          Left = 188
          Top = 112
          Width = 150
          Height = 22
          MaxLength = 16
          ReadOnly = True
          TabOrder = 2
        end
        object lblDefaultRawMaterialUsageAccount: TLabel
          Left = 346
          Top = 116
          Width = 574
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSemiProductAccount: TLabel
          Left = 4
          Top = 141
          Width = 180
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Semi-Product Account'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtSemiProductAccount: TEdit
          Left = 188
          Top = 137
          Width = 150
          Height = 22
          MaxLength = 16
          ReadOnly = True
          TabOrder = 3
        end
        object lblDefaultSemiProductAccount: TLabel
          Left = 346
          Top = 141
          Width = 574
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSalesAccount: TLabel
          Left = 4
          Top = 166
          Width = 180
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Sales VAT Account'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtSalesAccount: TEdit
          Left = 188
          Top = 162
          Width = 150
          Height = 22
          MaxLength = 16
          ReadOnly = True
          TabOrder = 4
        end
        object lblDefaultSalesAccount: TLabel
          Left = 346
          Top = 166
          Width = 574
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSalesReturnAccount: TLabel
          Left = 4
          Top = 191
          Width = 180
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Sales Return VAT Account'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtSalesReturnAccount: TEdit
          Left = 188
          Top = 187
          Width = 150
          Height = 22
          MaxLength = 16
          ReadOnly = True
          TabOrder = 5
        end
        object lblDefaultSalesReturnAccount: TLabel
          Left = 346
          Top = 191
          Width = 574
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblPurchaseAccount: TLabel
          Left = 4
          Top = 216
          Width = 180
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Purchase VAT Account'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtPurchaseAccount: TEdit
          Left = 188
          Top = 212
          Width = 150
          Height = 22
          MaxLength = 16
          ReadOnly = True
          TabOrder = 6
        end
        object lblDefaultPurchaseAccount: TLabel
          Left = 346
          Top = 216
          Width = 574
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblPurchaseReturnAccount: TLabel
          Left = 4
          Top = 241
          Width = 180
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Purchase Return VAT Account'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtPurchaseReturnAccount: TEdit
          Left = 188
          Top = 237
          Width = 150
          Height = 22
          MaxLength = 16
          ReadOnly = True
          TabOrder = 7
        end
        object lblDefaultPurchaseReturnAccount: TLabel
          Left = 346
          Top = 241
          Width = 574
          Height = 13
          AutoSize = False
          Caption = '-'
        end
      end
      object tsSummary: TTabSheet
        Caption = 'Summary'
        object lblSumCurrentQuantity: TLabel
          Left = 4
          Top = 8
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Current Quantity'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumCurrentQuantityVal: TLabel
          Left = 180
          Top = 8
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSumAverageCost: TLabel
          Left = 4
          Top = 29
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Average Cost'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumAverageCostVal: TLabel
          Left = 180
          Top = 29
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSumOpeningQuantity: TLabel
          Left = 4
          Top = 50
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Opening Quantity'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumOpeningQuantityVal: TLabel
          Left = 180
          Top = 50
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSumOpeningPrice: TLabel
          Left = 4
          Top = 71
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Opening Price'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumOpeningPriceVal: TLabel
          Left = 180
          Top = 71
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSumOpeningAmount: TLabel
          Left = 4
          Top = 92
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Opening Amount'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumOpeningAmountVal: TLabel
          Left = 180
          Top = 92
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSumIncomingQuantity: TLabel
          Left = 4
          Top = 113
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Incoming Quantity'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumIncomingQuantityVal: TLabel
          Left = 180
          Top = 113
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSumIncomingAmount: TLabel
          Left = 4
          Top = 134
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Incoming Amount'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumIncomingAmountVal: TLabel
          Left = 180
          Top = 134
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSumOutgoingQuantity: TLabel
          Left = 4
          Top = 155
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Outgoing Quantity'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumOutgoingQuantityVal: TLabel
          Left = 180
          Top = 155
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSumOutgoingAmount: TLabel
          Left = 4
          Top = 176
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Outgoing Amount'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumOutgoingAmountVal: TLabel
          Left = 180
          Top = 176
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSumLastBuyDate: TLabel
          Left = 4
          Top = 197
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Last Buy Date'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumLastBuyDateVal: TLabel
          Left = 180
          Top = 197
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSumLastBuyQuantity: TLabel
          Left = 4
          Top = 218
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Last Buy Quantity'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumLastBuyQuantityVal: TLabel
          Left = 180
          Top = 218
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblSumLastBuyPrice: TLabel
          Left = 4
          Top = 239
          Width = 170
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Last Buy Price'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSumLastBuyPriceVal: TLabel
          Left = 180
          Top = 239
          Width = 160
          Height = 13
          AutoSize = False
          Caption = '-'
        end
        object lblWarehouseStocks: TLabel
          Left = 360
          Top = 8
          Width = 400
          Height = 13
          AutoSize = False
          Caption = 'Warehouse Stock Status'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object grdWarehouseStocks: TStringGrid
          Left = 360
          Top = 26
          Width = 420
          Height = 238
          ColCount = 2
          DefaultColWidth = 200
          DefaultRowHeight = 20
          FixedCols = 0
          RowCount = 2
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
          TabOrder = 0
        end
      end
    end
  end
end

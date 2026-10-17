object frmSlsInvoiceLine: TfrmSlsInvoiceLine
  Left = 0
  Top = 0
  Caption = 'Fatura Kalemi'
  ClientHeight = 385
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
    Height = 385
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
      TabOrder = 6
    end
    object pnlTotals: TPanel
      Left = 408
      Top = 2
      Width = 395
      Height = 152
      BevelOuter = bvLowered
      TabOrder = 7
    end
    object lblEInvSection: TLabel
      Left = 4
      Top = 206
      Width = 400
      Height = 13
      Alignment = taLeftJustify
      AutoSize = False
      Caption = 'e-Belge / '#304'hracat'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEinvGtipId: TLabel
      Left = 4
      Top = 230
      Width = 124
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
      Left = 132
      Top = 226
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 20
    end
    object lblEinvWithholdingId: TLabel
      Left = 4
      Top = 253
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Tevkifat Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEinvWithholdingId: TEdit
      Left = 132
      Top = 249
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 21
    end
    object lblSellerEinvDiibLineId: TLabel
      Left = 4
      Top = 276
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sat'#305'c'#305' D'#304#304'B Sat'#305'r Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSellerEinvDiibLineId: TEdit
      Left = 132
      Top = 272
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 22
    end
    object lblBuyerEinvDiibLineId: TLabel
      Left = 4
      Top = 299
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Al'#305'c'#305' D'#304#304'B Sat'#305'r Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBuyerEinvDiibLineId: TEdit
      Left = 132
      Top = 295
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 23
    end
    object lblEinvPackagingTypeId: TLabel
      Left = 408
      Top = 230
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kap Cinsi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEinvPackagingTypeId: TEdit
      Left = 536
      Top = 226
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 24
    end
    object lblPackageNo: TLabel
      Left = 408
      Top = 253
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kap No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPackageNo: TEdit
      Left = 536
      Top = 249
      Width = 260
      Height = 22
      MaxLength = 32
      TabOrder = 25
    end
    object lblPackageQuantity: TLabel
      Left = 408
      Top = 276
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kap Adedi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPackageQuantity: TEdit
      Left = 536
      Top = 272
      Width = 150
      Height = 22
      TabOrder = 26
    end
    object lblPackageBrand: TLabel
      Left = 408
      Top = 299
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kap Markas'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPackageBrand: TEdit
      Left = 536
      Top = 295
      Width = 260
      Height = 22
      MaxLength = 64
      TabOrder = 27
    end
  end
end

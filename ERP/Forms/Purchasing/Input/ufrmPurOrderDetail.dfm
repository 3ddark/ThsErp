object frmPurOrderDetail: TfrmPurOrderDetail
  Left = 0
  Top = 0
  Caption = 'Sat'#305'n Alma Sipari'#351'i'
  ClientHeight = 640
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
    Height = 236
    Align = alTop
    TabOrder = 0
    object lblOrderNo: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sipari'#351' No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtOrderNo: TEdit
      Left = 132
      Top = 2
      Width = 260
      Height = 22
      MaxLength = 16
      TabOrder = 0
    end
    object lblOrderDate: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sipari'#351' Tarihi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtOrderDate: TEdit
      Left = 132
      Top = 25
      Width = 260
      Height = 22
      TabOrder = 1
    end
    object lblAccAccountId: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Tedarik'#231'i'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccAccountId: TEdit
      Left = 132
      Top = 48
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 2
    end
    object lblSupplierRefNo: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Tedarik'#231'i Ref. No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSupplierRefNo: TEdit
      Left = 132
      Top = 71
      Width = 260
      Height = 22
      MaxLength = 32
      TabOrder = 3
    end
    object lblDeliveryDate: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Teslim Tarihi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDeliveryDate: TEdit
      Left = 132
      Top = 94
      Width = 260
      Height = 22
      TabOrder = 4
    end
    object lblStkWarehouseId: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ambar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtStkWarehouseId: TEdit
      Left = 132
      Top = 117
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 5
    end
    object lblCurrency: TLabel
      Left = 4
      Top = 144
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Para Birimi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCurrency: TEdit
      Left = 132
      Top = 140
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 6
    end
    object lblExchangeRate: TLabel
      Left = 4
      Top = 167
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'D'#246'viz Kuru'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtExchangeRate: TEdit
      Left = 132
      Top = 163
      Width = 260
      Height = 22
      TabOrder = 7
    end
    object lblPaymentTermDays: TLabel
      Left = 4
      Top = 190
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Vade (G'#252'n)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPaymentTermDays: TEdit
      Left = 132
      Top = 186
      Width = 260
      Height = 22
      TabOrder = 8
    end
    object lblStatusText: TLabel
      Left = 408
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Durum'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtStatusText: TEdit
      Left = 536
      Top = 2
      Width = 260
      Height = 22
      ReadOnly = True
      TabStop = False
      TabOrder = 9
    end
    object lblDescription: TLabel
      Left = 408
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
      Left = 536
      Top = 140
      Width = 260
      Height = 22
      MaxLength = 256
      TabOrder = 10
    end
    object pnlTotals: TPanel
      Left = 408
      Top = 25
      Width = 395
      Height = 112
      BevelOuter = bvLowered
      TabOrder = 11
    end
  end
end

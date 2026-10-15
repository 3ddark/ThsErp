object frmSlsOffer: TfrmSlsOffer
  Left = 0
  Top = 0
  Caption = 'Sat'#305#351' Teklifi'
  ClientHeight = 276
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
    Height = 276
    Align = alClient
    TabOrder = 0
    object lblOfferNo: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Teklif No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtOfferNo: TEdit
      Left = 132
      Top = 2
      Width = 260
      Height = 22
      MaxLength = 16
      TabOrder = 0
    end
    object lblOfferDate: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Teklif Tarihi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtOfferDate: TEdit
      Left = 132
      Top = 25
      Width = 260
      Height = 22
      TabOrder = 1
    end
    object lblValidUntil: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ge'#231'erlilik Tarihi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtValidUntil: TEdit
      Left = 132
      Top = 48
      Width = 260
      Height = 22
      TabOrder = 2
    end
    object lblAccAccountId: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'M'#252#351'teri'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccAccountId: TEdit
      Left = 132
      Top = 71
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 3
    end
    object lblCustomerRefNo: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'M'#252#351'teri Ref. No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCustomerRefNo: TEdit
      Left = 132
      Top = 94
      Width = 260
      Height = 22
      MaxLength = 32
      TabOrder = 4
    end
    object lblEmpEmployeeId: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sat'#305#351' Temsilcisi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEmpEmployeeId: TEdit
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
      MaxLength = 3
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
      Caption = 'Kur'
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
    object lblGrossAmount: TLabel
      Left = 408
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Br'#252't Tutar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtGrossAmount: TEdit
      Left = 536
      Top = 25
      Width = 260
      Height = 22
      ReadOnly = True
      TabStop = False
      TabOrder = 10
    end
    object lblDiscountAmount: TLabel
      Left = 408
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'skonto Tutar'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDiscountAmount: TEdit
      Left = 536
      Top = 48
      Width = 260
      Height = 22
      ReadOnly = True
      TabStop = False
      TabOrder = 11
    end
    object lblNetAmount: TLabel
      Left = 408
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Net Tutar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtNetAmount: TEdit
      Left = 536
      Top = 71
      Width = 260
      Height = 22
      ReadOnly = True
      TabStop = False
      TabOrder = 12
    end
    object lblVatAmount: TLabel
      Left = 408
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'KDV Tutar'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtVatAmount: TEdit
      Left = 536
      Top = 94
      Width = 260
      Height = 22
      ReadOnly = True
      TabStop = False
      TabOrder = 13
    end
    object lblTotalAmount: TLabel
      Left = 408
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Genel Toplam'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTotalAmount: TEdit
      Left = 536
      Top = 117
      Width = 260
      Height = 22
      ReadOnly = True
      TabStop = False
      TabOrder = 14
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
      TabOrder = 15
    end
  end
end

object frmSlsOfferDetail: TfrmSlsOfferDetail
  Left = 0
  Top = 0
  Caption = 'Sat'#305#351' Teklifi'
  ClientHeight = 756
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
    Height = 248
    Align = alTop
    TabOrder = 0
    object pgcHeader: TPageControl
      Left = 1
      Top = 1
      Width = 809
      Height = 246
      ActivePage = tsGeneral
      Align = alClient
      TabOrder = 0
      object tsGeneral: TTabSheet
        Caption = 'Genel'
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
        object lblDeliveryDate: TLabel
          Left = 4
          Top = 75
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
          Top = 71
          Width = 260
          Height = 22
          TabOrder = 3
        end
        object lblAccAccountId: TLabel
          Left = 4
          Top = 98
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
        object edtAccountCode: TEdit
          Left = 132
          Top = 94
          Width = 90
          Height = 22
          ReadOnly = True
          TabStop = False
          TabOrder = 4
        end
        object edtAccAccountId: TEdit
          Left = 226
          Top = 94
          Width = 166
          Height = 22
          ReadOnly = True
          TabOrder = 5
        end
        object lblTaxOffice: TLabel
          Left = 4
          Top = 121
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Vergi Dairesi / No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtTaxOffice: TEdit
          Left = 132
          Top = 117
          Width = 150
          Height = 22
          ReadOnly = True
          TabStop = False
          TabOrder = 6
        end
        object edtTaxNo: TEdit
          Left = 286
          Top = 117
          Width = 106
          Height = 22
          ReadOnly = True
          TabStop = False
          TabOrder = 7
        end
        object lblCustomerRefNo: TLabel
          Left = 4
          Top = 144
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
          Top = 140
          Width = 260
          Height = 22
          MaxLength = 32
          TabOrder = 8
        end
        object lblEmpEmployeeId: TLabel
          Left = 4
          Top = 167
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
          Top = 163
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 9
        end
        object lblDescription: TLabel
          Left = 4
          Top = 190
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
          Top = 186
          Width = 260
          Height = 22
          MaxLength = 256
          TabOrder = 10
        end
        object lblSaleType: TLabel
          Left = 408
          Top = 6
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Sat'#305#351' Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object cbbSaleType: TComboBox
          Left = 536
          Top = 2
          Width = 260
          Height = 22
          Style = csDropDownList
          TabOrder = 11
        end
        object lblCurrency: TLabel
          Left = 408
          Top = 29
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
          Left = 536
          Top = 25
          Width = 260
          Height = 22
          MaxLength = 3
          ReadOnly = True
          TabOrder = 12
        end
        object lblExchangeRate: TLabel
          Left = 408
          Top = 52
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
          Left = 536
          Top = 48
          Width = 260
          Height = 22
          TabOrder = 13
        end
        object lblUsdRate: TLabel
          Left = 408
          Top = 75
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'UsdRate'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtUsdRate: TEdit
          Left = 536
          Top = 71
          Width = 260
          Height = 22
          TabOrder = 14
        end
        object lblEurRate: TLabel
          Left = 408
          Top = 98
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'EurRate'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEurRate: TEdit
          Left = 536
          Top = 94
          Width = 260
          Height = 22
          TabOrder = 15
        end
        object lblEinvPaymentMeansId: TLabel
          Left = 408
          Top = 121
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = #214'deme '#350'ekli'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvPaymentMeansId: TEdit
          Left = 536
          Top = 117
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 16
        end
        object lblPaymentTermDays: TLabel
          Left = 408
          Top = 144
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
          Left = 536
          Top = 140
          Width = 260
          Height = 22
          TabOrder = 17
        end
        object lblEinvDeliveryTermId: TLabel
          Left = 408
          Top = 167
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'G'#246'nderim '#350'ekli'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvDeliveryTermId: TEdit
          Left = 536
          Top = 163
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 18
        end
      end
      object tsBillingAddress: TTabSheet
        Caption = 'Fatura Adresi'
        ImageIndex = 1
      end
      object tsShippingAddress: TTabSheet
        Caption = 'Teslimat Adresi'
        ImageIndex = 2
      end
    end
  end
end

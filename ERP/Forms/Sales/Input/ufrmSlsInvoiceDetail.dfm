object frmSlsInvoiceDetail: TfrmSlsInvoiceDetail
  Left = 0
  Top = 0
  Caption = 'Sat'#305#351' Faturas'#305
  ClientHeight = 664
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
    Height = 214
    Align = alTop
    TabOrder = 0
    object pgcHeader: TPageControl
      Left = 1
      Top = 1
      Width = 809
      Height = 212
      ActivePage = tsGeneral
      Align = alClient
      TabOrder = 0
      object tsGeneral: TTabSheet
        Caption = 'Genel'
        object lblInvoiceNo: TLabel
          Left = 4
          Top = 6
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Fatura No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtInvoiceNo: TEdit
          Left = 132
          Top = 2
          Width = 260
          Height = 22
          TabOrder = 0
        end
        object lblInvoiceDate: TLabel
          Left = 4
          Top = 29
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Fatura Tarihi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtInvoiceDate: TEdit
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
          Top = 48
          Width = 260
          Height = 22
          TabOrder = 2
        end
        object lblDueDate: TLabel
          Left = 4
          Top = 75
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Vade Tarihi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtDueDate: TEdit
          Left = 132
          Top = 71
          Width = 260
          Height = 22
          TabOrder = 3
        end
        object lblStkWarehouseId: TLabel
          Left = 4
          Top = 98
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
          Top = 94
          Width = 260
          Height = 22
          TabOrder = 4
        end
        object lblCurrency: TLabel
          Left = 4
          Top = 121
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
          Top = 117
          Width = 260
          Height = 22
          TabOrder = 5
        end
        object lblExchangeRate: TLabel
          Left = 4
          Top = 144
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
          Top = 140
          Width = 260
          Height = 22
          TabOrder = 6
        end
        object lblDescription: TLabel
          Left = 408
          Top = 6
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
          Top = 2
          Width = 260
          Height = 22
          TabOrder = 7
        end
        object pnlTotals: TPanel
          Left = 408
          Top = 25
          Width = 395
          Height = 112
          BevelOuter = bvLowered
          TabOrder = 8
        end
      end
      object tsEInvoice: TTabSheet
        Caption = 'e-Belge / '#304'hracat'
        ImageIndex = 1
        object lblEinvProfileId: TLabel
          Left = 4
          Top = 6
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Senaryo'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvProfileId: TEdit
          Left = 132
          Top = 2
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 0
        end
        object lblEinvInvoiceTypeId: TLabel
          Left = 4
          Top = 29
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Fatura Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvInvoiceTypeId: TEdit
          Left = 132
          Top = 25
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 1
        end
        object lblEinvTaxExemptionId: TLabel
          Left = 4
          Top = 52
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = #304'stisna Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvTaxExemptionId: TEdit
          Left = 132
          Top = 48
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 2
        end
        object lblEinvPaymentMeansId: TLabel
          Left = 4
          Top = 75
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
          Left = 132
          Top = 71
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 3
        end
        object lblEinvUuid: TLabel
          Left = 4
          Top = 98
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'ETTN'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvUuid: TEdit
          Left = 132
          Top = 94
          Width = 260
          Height = 22
          ReadOnly = True
          TabStop = False
          TabOrder = 4
        end
        object lblEinvStatus: TLabel
          Left = 4
          Top = 121
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'e-Belge Durumu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvStatus: TEdit
          Left = 132
          Top = 117
          Width = 260
          Height = 22
          ReadOnly = True
          TabStop = False
          TabOrder = 5
        end
        object lblEinvDeliveryTermId: TLabel
          Left = 408
          Top = 6
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Teslim '#350'art'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvDeliveryTermId: TEdit
          Left = 536
          Top = 2
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 6
        end
        object lblEinvTransportModeId: TLabel
          Left = 408
          Top = 29
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Ta'#351#305'ma '#350'ekli'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvTransportModeId: TEdit
          Left = 536
          Top = 25
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 7
        end
        object lblCustomsDeclarationNo: TLabel
          Left = 408
          Top = 52
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'G'#199'B Tescil No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtCustomsDeclarationNo: TEdit
          Left = 536
          Top = 48
          Width = 260
          Height = 22
          MaxLength = 32
          TabOrder = 8
        end
        object lblGtbRefNo: TLabel
          Left = 408
          Top = 75
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'GTB Referans No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtGtbRefNo: TEdit
          Left = 536
          Top = 71
          Width = 260
          Height = 22
          MaxLength = 32
          TabOrder = 9
        end
        object lblActualExportDate: TLabel
          Left = 408
          Top = 98
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Fiili '#304'hracat Tarihi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtActualExportDate: TEdit
          Left = 536
          Top = 94
          Width = 260
          Height = 22
          TabOrder = 10
        end
      end
    end
  end
end

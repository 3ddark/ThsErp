object frmPurInvoiceDetail: TfrmPurInvoiceDetail
  Left = 0
  Top = 0
  Caption = 'Al'#305#351' Faturas'#305
  ClientHeight = 620
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
    Height = 167
    Align = alTop
    TabOrder = 0
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
      MaxLength = 32
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
    object lblCurrency: TLabel
      Left = 4
      Top = 98
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
      Top = 94
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 4
    end
    object lblExchangeRate: TLabel
      Left = 4
      Top = 121
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
      Top = 117
      Width = 260
      Height = 22
      TabOrder = 5
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
      MaxLength = 256
      TabOrder = 6
    end
    object pnlTotals: TPanel
      Left = 408
      Top = 25
      Width = 395
      Height = 112
      BevelOuter = bvLowered
      TabOrder = 7
    end
  end
end

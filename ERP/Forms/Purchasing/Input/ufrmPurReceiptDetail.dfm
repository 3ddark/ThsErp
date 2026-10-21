object frmPurReceiptDetail: TfrmPurReceiptDetail
  Left = 0
  Top = 0
  Caption = 'Mal Kabul'
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
    Height = 190
    Align = alTop
    TabOrder = 0
    object lblReceiptNo: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Mal Kabul No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtReceiptNo: TEdit
      Left = 132
      Top = 2
      Width = 260
      Height = 22
      MaxLength = 16
      TabOrder = 0
    end
    object lblReceiptDate: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Mal Kabul Tarihi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtReceiptDate: TEdit
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
    object lblStkWarehouseId: TLabel
      Left = 4
      Top = 75
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
      Top = 71
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 3
    end
    object lblWaybillNo: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'rsaliye No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtWaybillNo: TEdit
      Left = 132
      Top = 94
      Width = 260
      Height = 22
      MaxLength = 32
      TabOrder = 4
    end
    object lblPurOrderId: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sipari'#351
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPurOrderId: TEdit
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
      TabOrder = 7
    end
    object pnlTotals: TPanel
      Left = 408
      Top = 25
      Width = 395
      Height = 30
      BevelOuter = bvLowered
      TabOrder = 8
    end
  end
end

object frmSysDecimalPlace: TfrmSysDecimalPlace
  Left = 0
  Top = 0
  Caption = 'Ondalik Hane Kayit'
  ClientHeight = 395
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 395
    Align = alClient
    TabOrder = 0
    object lblQuantity: TLabel
      Left = 84
      Top = 12
      Width = 44
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Miktar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblPrice: TLabel
      Left = 105
      Top = 42
      Width = 23
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Fiyat'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblTotal: TLabel
      Left = 105
      Top = 72
      Width = 23
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Toplam'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblStockQuantity: TLabel
      Left = 39
      Top = 102
      Width = 89
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Stok Miktari'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblExchangeRate: TLabel
      Left = 30
      Top = 132
      Width = 98
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Doviz Kuru'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtQuantity: TSpinEdit
      Left = 134
      Top = 8
      Width = 75
      Height = 25
      MaxValue = 99
      MinValue = 0
      TabOrder = 0
      Value = 2
    end
    object edtPrice: TSpinEdit
      Left = 134
      Top = 38
      Width = 75
      Height = 25
      MaxValue = 99
      MinValue = 0
      TabOrder = 1
      Value = 2
    end
    object edtTotal: TSpinEdit
      Left = 134
      Top = 68
      Width = 75
      Height = 25
      MaxValue = 99
      MinValue = 0
      TabOrder = 2
      Value = 2
    end
    object edtStockQuantity: TSpinEdit
      Left = 134
      Top = 98
      Width = 75
      Height = 25
      MaxValue = 99
      MinValue = 0
      TabOrder = 3
      Value = 4
    end
    object edtExchangeRate: TSpinEdit
      Left = 134
      Top = 128
      Width = 75
      Height = 25
      MaxValue = 99
      MinValue = 0
      TabOrder = 4
      Value = 4
    end
  end
end

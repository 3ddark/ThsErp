object frmSysDecimalPlace: TfrmSysDecimalPlace
  Left = 0
  Top = 0
  Caption = 'frmSysDecimalPlace'
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
    object lblquantity: TLabel
      Left = 84
      Top = 12
      Width = 44
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Quantity'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblprice: TLabel
      Left = 105
      Top = 42
      Width = 23
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Price'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lbltotal: TLabel
      Left = 105
      Top = 72
      Width = 23
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Total'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblstock_quantity: TLabel
      Left = 39
      Top = 102
      Width = 89
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Stock Quantity'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblexchange_rate: TLabel
      Left = 30
      Top = 132
      Width = 98
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Exchange Rate'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtquantity: TSpinEdit
      Left = 134
      Top = 8
      Width = 75
      Height = 25
      MaxValue = 99
      MinValue = 0
      TabOrder = 0
      Value = 2
    end
    object edtprice: TSpinEdit
      Left = 134
      Top = 38
      Width = 75
      Height = 25
      MaxValue = 99
      MinValue = 0
      TabOrder = 1
      Value = 2
    end
    object edttotal: TSpinEdit
      Left = 134
      Top = 68
      Width = 75
      Height = 25
      MaxValue = 99
      MinValue = 0
      TabOrder = 2
      Value = 2
    end
    object edtstock_quantity: TSpinEdit
      Left = 134
      Top = 98
      Width = 75
      Height = 25
      MaxValue = 99
      MinValue = 0
      TabOrder = 3
      Value = 4
    end
    object edtexchange_rate: TSpinEdit
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

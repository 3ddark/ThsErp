object frmStkGroup: TfrmStkGroup
  Left = 0
  Top = 0
  Caption = 'Stock Group'
  ClientHeight = 185
  ClientWidth = 480
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
    Width = 480
    Height = 185
    Align = alClient
    TabOrder = 0
    object lblName: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Group Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtName: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 0
    end
    object lblVatRate: TLabel
      Left = 4
      Top = 29
      Width = 124
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
    object edtVatRate: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      TabOrder = 1
    end
    object lblRawMaterialStockAccount: TLabel
      Left = 4
      Top = 52
      Width = 124
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
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      MaxLength = 16
      ReadOnly = True
      TabOrder = 2
    end
    object lblRawMaterialUsageAccount: TLabel
      Left = 4
      Top = 75
      Width = 124
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
      Left = 132
      Top = 71
      Width = 333
      Height = 22
      MaxLength = 16
      ReadOnly = True
      TabOrder = 3
    end
    object lblSemiProductAccount: TLabel
      Left = 4
      Top = 98
      Width = 124
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
      Left = 132
      Top = 94
      Width = 333
      Height = 22
      MaxLength = 16
      ReadOnly = True
      TabOrder = 4
    end
  end
end

object frmSysUom: TfrmSysUom
  Left = 0
  Top = 0
  Caption = 'System Unit of Measurement'
  ClientHeight = 199
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 199
    Align = alClient
    TabOrder = 0
    object lblMultiplier: TLabel
      Left = 79
      Top = 115
      Width = 49
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Multipler'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblDecimal: TLabel
      Left = 82
      Top = 72
      Width = 46
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Decimal'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblMeasureTypeId: TLabel
      Left = 47
      Top = 92
      Width = 81
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Measure Type'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblDescription: TLabel
      Left = 63
      Top = 52
      Width = 65
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Description'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblUnitEInv: TLabel
      Left = 47
      Top = 29
      Width = 81
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Unit e-Invoice'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblUnit: TLabel
      Left = 104
      Top = 6
      Width = 24
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Unit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtMultiplier: TEdit
      Left = 132
      Top = 111
      Width = 333
      Height = 23
      TabOrder = 5
    end
    object chkDecimal: TCheckBox
      Left = 132
      Top = 71
      Width = 333
      Height = 17
      TabOrder = 3
    end
    object edtMeasureTypeId: TEdit
      Left = 132
      Top = 88
      Width = 333
      Height = 23
      TabOrder = 4
    end
    object edtDescription: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 23
      TabOrder = 2
    end
    object edtUnitEInv: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 23
      TabOrder = 1
    end
    object edtUnit: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 23
      TabOrder = 0
    end
  end
end

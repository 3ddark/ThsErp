object frmSysUom: TfrmSysUom
  Left = 0
  Top = 0
  Caption = 'frmSysUom'
  ClientHeight = 220
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 14
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 220
    Align = alClient
    TabOrder = 0
    object lblUnit: TLabel
      Left = 105
      Top = 6
      Width = 23
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Unit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblUnitEInv: TLabel
      Left = 48
      Top = 29
      Width = 80
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Unit e-Invoice'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblDescriptionEN: TLabel
      Left = 12
      Top = 52
      Width = 116
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Description (English)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblDescriptionTR: TLabel
      Left = 12
      Top = 76
      Width = 116
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Description (T'#252'rk'#231'e)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblDecimal: TLabel
      Left = 83
      Top = 100
      Width = 45
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Decimal'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblMeasureTypeId: TLabel
      Left = 48
      Top = 120
      Width = 80
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Measure Type'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblMultiplier: TLabel
      Left = 75
      Top = 144
      Width = 53
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Multiplier'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtUnit: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      TabOrder = 0
    end
    object edtUnitEInv: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      TabOrder = 1
    end
    object edtDescriptionEN: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      TabOrder = 2
    end
    object edtDescriptionTR: TEdit
      Left = 132
      Top = 72
      Width = 333
      Height = 22
      TabOrder = 3
    end
    object chkDecimal: TCheckBox
      Left = 132
      Top = 98
      Width = 333
      Height = 17
      TabOrder = 4
    end
    object edtMeasureTypeId: TEdit
      Left = 132
      Top = 116
      Width = 333
      Height = 22
      TabOrder = 5
    end
    object edtMultiplier: TEdit
      Left = 132
      Top = 140
      Width = 333
      Height = 22
      TabOrder = 6
    end
  end
end

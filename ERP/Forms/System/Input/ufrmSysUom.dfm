object frmSysUom: TfrmSysUom
  Left = 0
  Top = 0
  Caption = 'frmSysUom'
  ClientHeight = 244
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
    Height = 244
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 220
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
      Top = 27
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
    object lblDecimal: TLabel
      Left = 83
      Top = 119
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
      Top = 139
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
      Top = 163
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
      Top = 23
      Width = 333
      Height = 22
      TabOrder = 1
    end
    object chkDecimal: TCheckBox
      Left = 132
      Top = 117
      Width = 333
      Height = 17
      TabOrder = 3
    end
    object edtMeasureTypeId: TEdit
      Left = 132
      Top = 135
      Width = 333
      Height = 22
      TabOrder = 4
    end
    object edtMultiplier: TEdit
      Left = 132
      Top = 159
      Width = 333
      Height = 22
      TabOrder = 5
    end
    object scrlbxTranslations: TScrollBox
      Left = 8
      Top = 44
      Width = 480
      Height = 72
      HorzScrollBar.Visible = False
      TabOrder = 2
    end
  end
end

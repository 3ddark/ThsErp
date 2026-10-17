object frmEInvDiibLine: TfrmEInvDiibLine
  Left = 0
  Top = 0
  Caption = 'D'#304#304'B Sat'#305'r'#305
  ClientHeight = 276
  ClientWidth = 567
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
    Width = 567
    Height = 276
    Align = alClient
    TabOrder = 0
    object lblEinvDiibId: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'D'#304#304'B No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEinvDiibId: TEdit
      Left = 132
      Top = 2
      Width = 420
      Height = 22
      ReadOnly = True
      TabOrder = 0
    end
    object lblLineCode: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'D'#304#304'B Sat'#305'r Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtLineCode: TEdit
      Left = 132
      Top = 25
      Width = 420
      Height = 22
      MaxLength = 32
      TabOrder = 1
    end
    object lblLineKind: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Sat'#305'r T'#252'r'#252
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbLineKind: TComboBox
      Left = 132
      Top = 48
      Width = 420
      Height = 22
      Style = csDropDownList
      TabOrder = 2
    end
    object lblStkInventoryId: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Stok Kart'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtStkInventoryId: TEdit
      Left = 132
      Top = 71
      Width = 420
      Height = 22
      ReadOnly = True
      TabOrder = 3
    end
    object lblEinvGtipId: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'GT'#304'P'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEinvGtipId: TEdit
      Left = 132
      Top = 94
      Width = 420
      Height = 22
      ReadOnly = True
      TabOrder = 4
    end
    object lblProductDescription: TLabel
      Left = 4
      Top = 121
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'D'#304#304'B '#220'r'#252'n Tan'#305'm'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtProductDescription: TEdit
      Left = 132
      Top = 117
      Width = 420
      Height = 22
      MaxLength = 512
      TabOrder = 5
    end
    object lblQuantity: TLabel
      Left = 4
      Top = 144
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Miktar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtQuantity: TEdit
      Left = 132
      Top = 140
      Width = 420
      Height = 22
      TabOrder = 6
    end
    object lblSysUomId: TLabel
      Left = 4
      Top = 167
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Birim'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSysUomId: TEdit
      Left = 132
      Top = 163
      Width = 420
      Height = 22
      ReadOnly = True
      TabOrder = 7
    end
    object lblIsActive: TLabel
      Left = 4
      Top = 190
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Aktif'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkIsActive: TCheckBox
      Left = 132
      Top = 189
      Width = 420
      Height = 17
      TabOrder = 8
    end
  end
end

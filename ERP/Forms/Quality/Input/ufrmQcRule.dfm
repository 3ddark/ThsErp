object frmQcRule: TfrmQcRule
  Left = 0
  Top = 0
  Caption = 'Kalite Kontrol Kural'#305
  ClientHeight = 161
  ClientWidth = 520
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
    Width = 520
    Height = 161
    Align = alClient
    TabOrder = 0
    object lblStkGroupId: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Stok Grubu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtStkGroupId: TEdit
      Left = 132
      Top = 2
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 0
    end
    object lblStkInventoryId: TLabel
      Left = 4
      Top = 29
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
      Top = 25
      Width = 260
      Height = 22
      ReadOnly = True
      TabOrder = 1
    end
    object chkIsRequired: TCheckBox
      Left = 132
      Top = 50
      Width = 260
      Height = 17
      Caption = 'Kalite kontrol gerekli'
      TabOrder = 2
    end
    object lblInspectionCriteria: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kontrol Kriterleri'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtInspectionCriteria: TEdit
      Left = 132
      Top = 71
      Width = 360
      Height = 22
      MaxLength = 256
      TabOrder = 3
    end
  end
end

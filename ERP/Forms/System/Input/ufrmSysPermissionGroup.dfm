object frmSysPermissionGroup: TfrmSysPermissionGroup
  Left = 0
  Top = 0
  Caption = 'frmSysPermissionGroup'
  ClientHeight = 150
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
    Height = 150
    Align = alClient
    TabOrder = 0
    object lblPermissionGroupKey: TLabel
      Left = 127
      Top = 8
      Width = 21
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Key'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblPermissionGroupName_en_US: TLabel
      Left = 27
      Top = 32
      Width = 121
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Group Name (English)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblPermissionGroupName_tr_TR: TLabel
      Left = 27
      Top = 56
      Width = 121
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Group Name (T'#252'rk'#231'e)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtPermissionGroupKey: TEdit
      Left = 150
      Top = 4
      Width = 333
      Height = 22
      TabOrder = 0
    end
    object edtPermissionGroupName_en_US: TEdit
      Left = 150
      Top = 28
      Width = 333
      Height = 22
      TabOrder = 1
    end
    object edtPermissionGroupName_tr_TR: TEdit
      Left = 150
      Top = 52
      Width = 333
      Height = 22
      TabOrder = 2
    end
  end
end

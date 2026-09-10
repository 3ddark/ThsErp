object frmSysPermissionGroup: TfrmSysPermissionGroup
  Left = 0
  Top = 0
  Caption = 'frmSysPermissionGroup'
  ClientHeight = 160
  ClientWidth = 497
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
    Width = 497
    Height = 160
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 500
    ExplicitHeight = 150
    object lblPermissionGroupKey: TLabel
      Left = 127
      Top = 6
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
    object edtPermissionGroupKey: TEdit
      Left = 150
      Top = 2
      Width = 333
      Height = 22
      TabOrder = 0
    end
    object scrlbxTranslations: TScrollBox
      Left = 8
      Top = 24
      Width = 480
      Height = 72
      HorzScrollBar.Visible = False
      TabOrder = 1
    end
  end
end

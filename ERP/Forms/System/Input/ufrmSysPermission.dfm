object frmSysPermission: TfrmSysPermission
  Left = 0
  Top = 0
  Caption = 'Permission'
  ClientHeight = 204
  ClientWidth = 500
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
    Width = 500
    Height = 204
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 197
    object lblCode: TLabel
      Left = 57
      Top = 6
      Width = 93
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblKey: TLabel
      Left = 64
      Top = 27
      Width = 86
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Key'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblGroupId: TLabel
      Left = 51
      Top = 119
      Width = 99
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Group'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCode: TEdit
      Left = 150
      Top = 2
      Width = 333
      Height = 22
      TabOrder = 0
    end
    object edtKey: TEdit
      Left = 150
      Top = 23
      Width = 333
      Height = 22
      TabOrder = 1
    end
    object edtGroupId: TEdit
      Left = 150
      Top = 115
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 3
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

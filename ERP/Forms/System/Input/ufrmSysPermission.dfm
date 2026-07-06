object frmSysPermission: TfrmSysPermission
  Left = 0
  Top = 0
  Caption = 'Permission'
  ClientHeight = 197
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 197
    Align = alClient
    TabOrder = 0
    object lblCode: TLabel
      Left = 12
      Top = 11
      Width = 94
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblName: TLabel
      Left = 9
      Top = 41
      Width = 97
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblGroupId: TLabel
      Left = 7
      Top = 71
      Width = 99
      Height = 13
      Alignment = taRightJustify
      Caption = 'Permission Group'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCode: TEdit
      Left = 108
      Top = 7
      Width = 120
      Height = 23
      TabOrder = 0
    end
    object edtName: TEdit
      Left = 108
      Top = 37
      Width = 385
      Height = 23
      TabOrder = 1
    end
    object edtGroupId: TEdit
      Left = 108
      Top = 67
      Width = 250
      Height = 23
      ReadOnly = True
      TabOrder = 2
    end
  end
end

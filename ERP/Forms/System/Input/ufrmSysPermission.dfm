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
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 14
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 197
    Align = alClient
    TabOrder = 0
    object lblCode: TLabel
      Left = 57
      Top = 11
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
      Top = 35
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
    object lblNameEN: TLabel
      Left = 29
      Top = 59
      Width = 121
      Height = 13
      Alignment = taRightJustify
      Caption = 'Group Name (English)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblNameTR: TLabel
      Left = 29
      Top = 83
      Width = 121
      Height = 13
      Alignment = taRightJustify
      Caption = 'Group Name (T'#252'rk'#231'e)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblGroupId: TLabel
      Left = 51
      Top = 107
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
      Top = 7
      Width = 333
      Height = 22
      TabOrder = 0
    end
    object edtKey: TEdit
      Left = 150
      Top = 31
      Width = 333
      Height = 22
      TabOrder = 1
    end
    object edtNameEN: TEdit
      Left = 150
      Top = 55
      Width = 333
      Height = 22
      TabOrder = 2
    end
    object edtNameTR: TEdit
      Left = 150
      Top = 79
      Width = 333
      Height = 22
      TabOrder = 3
    end
    object edtGroupId: TEdit
      Left = 150
      Top = 103
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 4
    end
  end
end

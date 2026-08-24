object frmAccAccountLookup: TfrmAccAccountLookup
  Left = 0
  Top = 0
  Caption = 'frmAccAccountLookup'
  ClientHeight = 197
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
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
    ExplicitWidth = 498
    ExplicitHeight = 195
    object lblroot_code: TLabel
      Left = 32
      Top = 11
      Width = 64
      Height = 13
      Alignment = taRightJustify
      Caption = 'Root Code'
      Font.Style = [fsBold]
    end
    object edtroot_code: TEdit
      Left = 80
      Top = 7
      Width = 120
      Height = 23
      TabOrder = 0
    end
    object lblintermediate_code: TLabel
      Left = 4
      Top = 41
      Width = 92
      Height = 13
      Alignment = taRightJustify
      Caption = 'Intermediate'
      Font.Style = [fsBold]
    end
    object cbbintermediate_code: TComboBox
      Left = 80
      Top = 37
      Width = 250
      Height = 23
      Style = csDropDownList
      TabOrder = 1
    end
    object lblfinal_code: TLabel
      Left = 46
      Top = 71
      Width = 50
      Height = 13
      Alignment = taRightJustify
      Caption = 'Final Code'
      Font.Style = [fsBold]
    end
    object edtfinal_code: TEdit
      Left = 80
      Top = 67
      Width = 120
      Height = 23
      TabOrder = 2
    end
    object lblaccount_name: TLabel
      Left = 24
      Top = 101
      Width = 72
      Height = 13
      Alignment = taRightJustify
      Caption = 'Account Name'
      Font.Style = [fsBold]
    end
    object edtaccount_name: TEdit
      Left = 80
      Top = 97
      Width = 385
      Height = 23
      ReadOnly = True
      TabOrder = 3
    end
  end
end

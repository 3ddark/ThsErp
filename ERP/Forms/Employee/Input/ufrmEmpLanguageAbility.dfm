object frmEmpLanguageAbility: TfrmEmpLanguageAbility
  Left = 0
  Top = 0
  Caption = 'Employee Language'
  ClientHeight = 185
  ClientWidth = 480
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
    Width = 480
    Height = 185
    Align = alClient
    TabOrder = 0
    object lblEmpEmployeeId: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Employee'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEmpEmployeeId: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 0
    end
    object lblEmpLanguageId: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Language'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEmpLanguageId: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 1
    end
    object lblReadLevel: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Reading'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbReadLevel: TComboBox
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      Style = csDropDownList
      TabOrder = 2
    end
    object lblWriteLevel: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Writing'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbWriteLevel: TComboBox
      Left = 132
      Top = 71
      Width = 333
      Height = 22
      Style = csDropDownList
      TabOrder = 3
    end
    object lblSpeakLevel: TLabel
      Left = 4
      Top = 98
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Speaking'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbSpeakLevel: TComboBox
      Left = 132
      Top = 94
      Width = 333
      Height = 22
      Style = csDropDownList
      TabOrder = 4
    end
  end
end

object frmEmpDriverLicence: TfrmEmpDriverLicence
  Left = 0
  Top = 0
  Caption = 'Employee Driver License'
  ClientHeight = 116
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
    Height = 116
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
    object lblEmpDriverLicenseTypeId: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'License Class'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEmpDriverLicenseTypeId: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 1
    end
  end
end

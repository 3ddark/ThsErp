object frmEmpDriverLicenceType: TfrmEmpDriverLicenceType
  Left = 0
  Top = 0
  Caption = 'Driver License Type'
  ClientHeight = 93
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
    Height = 93
    Align = alClient
    TabOrder = 0
    object lblLicenseName: TLabel
      Left = 4
      Top = 6
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
    object edtLicenseName: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 0
    end
  end
end

object frmAccSetAccountType: TfrmAccSetAccountType
  Left = 0
  Top = 0
  Caption = 'frmAccSetAccountType'
  ClientHeight = 87
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
    Height = 87
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 85
    object lblname: TLabel
      Left = 56
      Top = 11
      Width = 34
      Height = 13
      Alignment = taRightJustify
      Caption = 'Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtname: TEdit
      Left = 80
      Top = 7
      Width = 385
      Height = 23
      TabOrder = 0
    end
  end
end

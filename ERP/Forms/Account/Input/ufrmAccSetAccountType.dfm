object frmAccSetAccountType: TfrmAccSetAccountType
  Left = 0
  Top = 0
  Caption = 'Account Type'
  ClientHeight = 169
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
    Height = 169
    Align = alClient
    TabOrder = 0
    object lblAccountTypeKey: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Key'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccountTypeKey: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 0
    end
    object scrlbxTranslations: TScrollBox
      Left = 8
      Top = 26
      Width = 462
      Height = 72
      HorzScrollBar.Visible = False
      TabOrder = 1
    end
  end
end

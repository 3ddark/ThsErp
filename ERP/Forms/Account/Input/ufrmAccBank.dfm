object frmAccBank: TfrmAccBank
  Left = 0
  Top = 0
  Caption = 'Bank'
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
    object lblBankName: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Bank Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBankName: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      MaxLength = 128
      TabOrder = 0
    end
    object lblSwiftCode: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Swift Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSwiftCode: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      MaxLength = 16
      TabOrder = 1
    end
  end
end

object frmAccTransferCode: TfrmAccTransferCode
  Left = 0
  Top = 0
  Caption = 'Transfer Code'
  ClientHeight = 139
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
    Height = 139
    Align = alClient
    TabOrder = 0
    object lblTransferCode: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Transfer Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtTransferCode: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      MaxLength = 32
      TabOrder = 0
    end
    object lblDescription: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Description'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDescription: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      MaxLength = 128
      TabOrder = 1
    end
    object lblAccount: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Account'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccount: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      MaxLength = 16
      ReadOnly = True
      TabOrder = 2
    end
  end
end

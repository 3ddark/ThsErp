object frmAccBank: TfrmAccBank
  Left = 0
  Top = 0
  Caption = 'frmAccBank'
  ClientHeight = 137
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
    Height = 137
    Align = alClient
    TabOrder = 0
    object lblBankName: TLabel
      Left = 72
      Top = 11
      Width = 56
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Banka Ad'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblSwiftCode: TLabel
      Left = 61
      Top = 38
      Width = 67
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'SWIFT Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtBankName: TEdit
      Left = 132
      Top = 7
      Width = 333
      Height = 22
      TabOrder = 0
    end
    object edtSwiftCode: TEdit
      Left = 132
      Top = 34
      Width = 333
      Height = 22
      TabOrder = 1
    end
  end
end

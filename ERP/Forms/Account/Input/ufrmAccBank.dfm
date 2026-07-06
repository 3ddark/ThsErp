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
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 137
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 135
    object lblbanka_adi: TLabel
      Left = 62
      Top = 11
      Width = 66
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Banka Ad'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblswift_kodu: TLabel
      Left = 53
      Top = 38
      Width = 75
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'SWIFT Kodu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtbanka_adi: TEdit
      Left = 132
      Top = 7
      Width = 333
      Height = 23
      TabOrder = 0
    end
    object edtswift_kodu: TEdit
      Left = 132
      Top = 34
      Width = 333
      Height = 23
      TabOrder = 1
    end
  end
end

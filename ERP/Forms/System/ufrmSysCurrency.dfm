object frmSysCurrency: TfrmSysCurrency
  Left = 0
  Top = 0
  Caption = 'Para Birimi Kayit'
  ClientHeight = 157
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
    Height = 157
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 174
    object lblCurrency: TLabel
      Left = 77
      Top = 6
      Width = 51
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Para Birimi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblSymbol: TLabel
      Left = 87
      Top = 29
      Width = 41
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Simge'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblDescription: TLabel
      Left = 63
      Top = 52
      Width = 65
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Aciklama'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtCurrency: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 23
      TabOrder = 0
    end
    object edtSymbol: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 23
      TabOrder = 1
    end
    object edtDescription: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 23
      TabOrder = 2
    end
  end
end

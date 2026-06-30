object frmSysCurrency: TfrmSysCurrency
  Left = 0
  Top = 0
  Caption = 'frmSysCurrency'
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
    object lblcurrency: TLabel
      Left = 77
      Top = 6
      Width = 51
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Currency'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblsymbol: TLabel
      Left = 87
      Top = 29
      Width = 41
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Symbol'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lbldescription: TLabel
      Left = 63
      Top = 52
      Width = 65
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Description'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtcurrency: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 23
      TabOrder = 0
    end
    object edtsymbol: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 23
      TabOrder = 1
    end
    object edtdescription: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 23
      TabOrder = 2
    end
  end
end

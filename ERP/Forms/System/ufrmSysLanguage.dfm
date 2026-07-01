object frmSysLanguage: TfrmSysLanguage
  Left = 0
  Top = 0
  Caption = 'frmSysLanguage'
  ClientHeight = 197
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 197
    Align = alClient
    TabOrder = 0
    object lbllng_code: TLabel
      Left = 64
      Top = 12
      Width = 64
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Language Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lbldescription: TLabel
      Left = 49
      Top = 37
      Width = 79
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
    object edtlng_code: TEdit
      Left = 134
      Top = 8
      Width = 333
      Height = 23
      TabOrder = 0
    end
    object edtdescription: TEdit
      Left = 134
      Top = 33
      Width = 333
      Height = 23
      TabOrder = 1
    end
  end
end

object frmSysLanguage: TfrmSysLanguage
  Left = 0
  Top = 0
  Caption = ''System Language'
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
    object lblLngCode: TLabel
      Left = 38
      Top = 12
      Width = 90
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
    object lblDescription: TLabel
      Left = 63
      Top = 37
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
    object edtKod: TEdit
      Left = 134
      Top = 8
      Width = 333
      Height = 23
      TabOrder = 0
    end
    object edtAciklama: TEdit
      Left = 134
      Top = 33
      Width = 333
      Height = 23
      TabOrder = 1
    end
  end
end

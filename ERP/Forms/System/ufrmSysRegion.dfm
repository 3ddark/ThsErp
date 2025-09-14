object frmSysRegion: TfrmSysRegion
  Left = 0
  Top = 0
  Caption = 'frmSysRegion'
  ClientHeight = 104
  ClientWidth = 463
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 463
    Height = 104
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 144
    ExplicitTop = 112
    ExplicitWidth = 185
    ExplicitHeight = 41
    object lblregion_name: TLabel
      Left = 11
      Top = 7
      Width = 77
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Region Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtregion_name: TEdit
      Left = 92
      Top = 3
      Width = 333
      Height = 23
      TabOrder = 0
    end
  end
end

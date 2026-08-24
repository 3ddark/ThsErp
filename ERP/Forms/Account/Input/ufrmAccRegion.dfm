object frmAccRegion: TfrmAccRegion
  Left = 0
  Top = 0
  Caption = 'frmAccRegion'
  ClientHeight = 87
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 87
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 85
    object lblbolge: TLabel
      Left = 51
      Top = 11
      Width = 77
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Region'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtbolge: TEdit
      Left = 132
      Top = 7
      Width = 333
      Height = 23
      TabOrder = 0
    end
  end
end

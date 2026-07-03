object frmAccGroup: TfrmAccGroup
  Left = 0
  Top = 0
  Caption = 'frmAccGroup'
  ClientHeight = 87
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
    Height = 87
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 85
    object lblgrup: TLabel
      Left = 63
      Top = 11
      Width = 65
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Group'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtgrup: TEdit
      Left = 132
      Top = 7
      Width = 333
      Height = 23
      TabOrder = 0
    end
  end
end

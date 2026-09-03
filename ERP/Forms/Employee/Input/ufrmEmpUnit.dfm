object frmEmpUnit: TfrmEmpUnit
  Left = 0
  Top = 0
  Caption = 'Birim'
  ClientHeight = 150
  ClientWidth = 450
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
    Width = 450
    Height = 150
    Align = alClient
    TabOrder = 0
    object lblUnitName: TLabel
      Left = 48
      Top = 30
      Width = 62
      Height = 15
      Alignment = taRightJustify
      Caption = 'Birim Ad'#196#177
    end
    object lblSectionId: TLabel
      Left = 56
      Top = 65
      Width = 54
      Height = 15
      Alignment = taRightJustify
      Caption = 'B'#195#182'l'#195#188'm'
    end
    object edtUnitName: TEdit
      Left = 120
      Top = 27
      Width = 280
      Height = 23
      TabOrder = 0
    end
    object edtSectionId: TEdit
      Left = 120
      Top = 62
      Width = 280
      Height = 23
      TabOrder = 1
    end
  end
end

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
      Left = 20
      Top = 30
      Width = 90
      Height = 15
      Alignment = taRightJustify
      Caption = 'Birim Adı'
    end
    object edtUnitName: TEdit
      Left = 120
      Top = 27
      Width = 280
      Height = 23
      TabOrder = 0
    end
    object lblSectionId: TLabel
      Left = 20
      Top = 65
      Width = 90
      Height = 15
      Alignment = taRightJustify
      Caption = 'Bölüm'
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

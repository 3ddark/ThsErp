object frmEmpTransportation: TfrmEmpTransportation
  Left = 0
  Top = 0
  Caption = 'Servis / Ulaşım'
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
    object lblCarNo: TLabel
      Left = 20
      Top = 30
      Width = 90
      Height = 15
      Alignment = taRightJustify
      Caption = 'Araç No'
    end
    object seCarNo: TSpinEdit
      Left = 120
      Top = 27
      Width = 150
      Height = 23
      MaxValue = 9999
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object lblCarName: TLabel
      Left = 20
      Top = 65
      Width = 90
      Height = 15
      Alignment = taRightJustify
      Caption = 'Araç Adı'
    end
    object edtCarName: TEdit
      Left = 120
      Top = 62
      Width = 280
      Height = 23
      TabOrder = 1
    end
  end
end

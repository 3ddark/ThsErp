object frmEmpDriverLicenceType: TfrmEmpDriverLicenceType
  Left = 0
  Top = 0
  Caption = 'Sürücü Belgesi Tipi'
  ClientHeight = 120
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
    Height = 120
    Align = alClient
    TabOrder = 0
    object lblLicenseName: TLabel
      Left = 20
      Top = 30
      Width = 90
      Height = 15
      Alignment = taRightJustify
      Caption = 'Ehliyet Sınıfı'
    end
    object edtLicenseName: TEdit
      Left = 120
      Top = 27
      Width = 280
      Height = 23
      TabOrder = 0
    end
  end
end

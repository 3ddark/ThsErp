object frmSysMonth: TfrmSysMonth
  Left = 0
  Top = 0
  Caption = 'frmSysMonth'
  ClientHeight = 127
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
    Height = 127
    Align = alClient
    TabOrder = 0
    object lblmonth_name: TLabel
      Left = 80
      Top = 12
      Width = 48
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Month Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtmonth_name: TEdit
      Left = 134
      Top = 8
      Width = 333
      Height = 23
      TabOrder = 0
    end
  end
end

object frmSysCity: TfrmSysCity
  Left = 0
  Top = 0
  Caption = 'frmSysCity'
  ClientHeight = 166
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
    Height = 166
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 232
    object lblcity_name: TLabel
      Left = 38
      Top = 7
      Width = 58
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'City Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblcar_plate_code: TLabel
      Left = 10
      Top = 31
      Width = 86
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Car Plate Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblcountry_id: TLabel
      Left = 52
      Top = 55
      Width = 44
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Country'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object lblregion_id: TLabel
      Left = 55
      Top = 79
      Width = 41
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'Region'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
    end
    object edtcity_name: TEdit
      Left = 100
      Top = 3
      Width = 333
      Height = 23
      TabOrder = 0
    end
    object edtcar_plate_code: TEdit
      Left = 100
      Top = 27
      Width = 333
      Height = 23
      TabOrder = 1
    end
    object edtcountry_id: TEdit
      Left = 100
      Top = 51
      Width = 333
      Height = 23
      TabOrder = 2
    end
    object edtregion_id: TEdit
      Left = 100
      Top = 75
      Width = 333
      Height = 23
      TabOrder = 3
    end
  end
end

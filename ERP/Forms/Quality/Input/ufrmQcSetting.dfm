object frmQcSetting: TfrmQcSetting
  Left = 0
  Top = 0
  Caption = 'Kalite Kontrol Ayarlar'#305
  ClientHeight = 161
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 14
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 520
    Height = 161
    Align = alClient
    TabOrder = 0
    object lblCompanyTitle: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Firma'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCompanyTitle: TEdit
      Left = 132
      Top = 2
      Width = 360
      Height = 22
      ReadOnly = True
      TabStop = False
      TabOrder = 0
    end
    object chkIsEnabled: TCheckBox
      Left = 132
      Top = 27
      Width = 360
      Height = 17
      Caption = 'Giri'#351' kalite kontrol mod'#252'l'#252' a'#231#305'k'
      TabOrder = 1
    end
    object lblRejectStkWarehouseId: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Red (Karantina) Ambar'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtRejectStkWarehouseId: TEdit
      Left = 132
      Top = 48
      Width = 360
      Height = 22
      ReadOnly = True
      TabOrder = 2
    end
    object lblDescription: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'A'#231#305'klama'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtDescription: TEdit
      Left = 132
      Top = 71
      Width = 360
      Height = 22
      MaxLength = 256
      TabOrder = 3
    end
  end
end

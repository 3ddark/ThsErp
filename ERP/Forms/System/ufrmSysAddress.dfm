object frmSysAddress: TfrmSysAddress
  Left = 0
  Top = 0
  Caption = 'frmSysAddress'
  ClientHeight = 467
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
    Height = 467
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 498
    ExplicitHeight = 465
    object lblcity_id: TLabel
      Left = 31
      Top = 11
      Width = 55
      Height = 13
      Alignment = taRightJustify
      Caption = 'City'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtcity_id: TEdit
      Left = 80
      Top = 7
      Width = 250
      Height = 23
      ReadOnly = True
      TabOrder = 0
    end
    object btncity_sec: TButton
      Left = 336
      Top = 3
      Width = 75
      Height = 25
      Caption = 'Select'
      TabOrder = 1
    end
    object lbldistrict: TLabel
      Left = 20
      Top = 41
      Width = 66
      Height = 13
      Alignment = taRightJustify
      Caption = 'District'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtdistrict: TEdit
      Left = 80
      Top = 37
      Width = 385
      Height = 23
      TabOrder = 2
    end
    object lblneighborhood: TLabel
      Left = -4
      Top = 71
      Width = 90
      Height = 13
      Alignment = taRightJustify
      Caption = 'Neighborhood'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtneighborhood: TEdit
      Left = 80
      Top = 67
      Width = 385
      Height = 23
      TabOrder = 3
    end
    object lblquarter: TLabel
      Left = 24
      Top = 101
      Width = 62
      Height = 13
      Alignment = taRightJustify
      Caption = 'Quarter'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtquarter: TEdit
      Left = 80
      Top = 97
      Width = 385
      Height = 23
      TabOrder = 4
    end
    object lblroad: TLabel
      Left = 36
      Top = 131
      Width = 50
      Height = 13
      Alignment = taRightJustify
      Caption = 'Road'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtroad: TEdit
      Left = 80
      Top = 127
      Width = 385
      Height = 23
      TabOrder = 5
    end
    object lblstreet: TLabel
      Left = 26
      Top = 161
      Width = 60
      Height = 13
      Alignment = taRightJustify
      Caption = 'Street'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtstreet: TEdit
      Left = 80
      Top = 157
      Width = 385
      Height = 23
      TabOrder = 6
    end
    object lblbuilding_name: TLabel
      Left = -24
      Top = 191
      Width = 110
      Height = 13
      Alignment = taRightJustify
      Caption = 'Building Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtbuilding_name: TEdit
      Left = 80
      Top = 187
      Width = 385
      Height = 23
      TabOrder = 7
    end
    object lbldoor_number: TLabel
      Left = -14
      Top = 221
      Width = 100
      Height = 13
      Alignment = taRightJustify
      Caption = 'Door Number'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtdoor_number: TEdit
      Left = 80
      Top = 217
      Width = 150
      Height = 23
      TabOrder = 8
    end
    object lblzip_code: TLabel
      Left = 6
      Top = 251
      Width = 74
      Height = 13
      Alignment = taRightJustify
      Caption = 'Zip Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtzip_code: TEdit
      Left = 80
      Top = 247
      Width = 150
      Height = 23
      TabOrder = 9
    end
    object lblweb: TLabel
      Left = 44
      Top = 281
      Width = 36
      Height = 13
      Alignment = taRightJustify
      Caption = 'Web'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtweb: TEdit
      Left = 80
      Top = 277
      Width = 385
      Height = 23
      TabOrder = 10
    end
    object lblemail: TLabel
      Left = 34
      Top = 311
      Width = 46
      Height = 13
      Alignment = taRightJustify
      Caption = 'Email'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
    end
    object edtemail: TEdit
      Left = 80
      Top = 307
      Width = 385
      Height = 23
      TabOrder = 11
    end
  end
end

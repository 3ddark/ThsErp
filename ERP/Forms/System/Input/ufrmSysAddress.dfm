object frmSysAddress: TfrmSysAddress
  Left = 0
  Top = 0
  Caption = 'Address'
  ClientHeight = 467
  ClientWidth = 500
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
    Width = 500
    Height = 467
    Align = alClient
    TabOrder = 0
    object lblCityId: TLabel
      Left = 72
      Top = 11
      Width = 22
      Height = 13
      Alignment = taRightJustify
      Caption = 'City'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDistrict: TLabel
      Left = 53
      Top = 41
      Width = 41
      Height = 13
      Alignment = taRightJustify
      Caption = 'District'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblNeighborhood: TLabel
      Left = 16
      Top = 71
      Width = 78
      Height = 13
      Alignment = taRightJustify
      Caption = 'Neighborhood'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblQuarter: TLabel
      Left = 50
      Top = 101
      Width = 44
      Height = 13
      Alignment = taRightJustify
      Caption = 'Quarter'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblRoad: TLabel
      Left = 65
      Top = 131
      Width = 29
      Height = 13
      Alignment = taRightJustify
      Caption = 'Road'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblStreet: TLabel
      Left = 58
      Top = 161
      Width = 36
      Height = 13
      Alignment = taRightJustify
      Caption = 'Street'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblBuildingName: TLabel
      Left = 15
      Top = 191
      Width = 79
      Height = 13
      Alignment = taRightJustify
      Caption = 'Building Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDoorNumber: TLabel
      Left = 20
      Top = 221
      Width = 74
      Height = 13
      Alignment = taRightJustify
      Caption = 'Door Number'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblZipCode: TLabel
      Left = 40
      Top = 251
      Width = 48
      Height = 13
      Alignment = taRightJustify
      Caption = 'Zip Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblWeb: TLabel
      Left = 63
      Top = 281
      Width = 25
      Height = 13
      Alignment = taRightJustify
      Caption = 'Web'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEmail: TLabel
      Left = 58
      Top = 311
      Width = 30
      Height = 13
      Alignment = taRightJustify
      Caption = 'Email'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtCityId: TEdit
      Left = 96
      Top = 7
      Width = 250
      Height = 22
      ReadOnly = True
      TabOrder = 0
    end
    object edtDistrict: TEdit
      Left = 96
      Top = 37
      Width = 385
      Height = 22
      TabOrder = 1
    end
    object edtNeighborhood: TEdit
      Left = 96
      Top = 67
      Width = 385
      Height = 22
      TabOrder = 2
    end
    object edtQuarter: TEdit
      Left = 96
      Top = 97
      Width = 385
      Height = 22
      TabOrder = 3
    end
    object edtRoad: TEdit
      Left = 96
      Top = 127
      Width = 385
      Height = 22
      TabOrder = 4
    end
    object edtStreet: TEdit
      Left = 96
      Top = 157
      Width = 385
      Height = 22
      TabOrder = 5
    end
    object edtBuildingName: TEdit
      Left = 96
      Top = 187
      Width = 385
      Height = 22
      TabOrder = 6
    end
    object edtDoorNumber: TEdit
      Left = 96
      Top = 217
      Width = 150
      Height = 22
      TabOrder = 7
    end
    object edtZipCode: TEdit
      Left = 96
      Top = 247
      Width = 150
      Height = 22
      TabOrder = 8
    end
    object edtWeb: TEdit
      Left = 96
      Top = 277
      Width = 385
      Height = 22
      TabOrder = 9
    end
    object edtEmail: TEdit
      Left = 96
      Top = 307
      Width = 385
      Height = 22
      TabOrder = 10
    end
  end
end

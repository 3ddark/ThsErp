object frmEmpPersonAddress: TfrmEmpPersonAddress
  Left = 0
  Top = 0
  Caption = 'Personel Adresi'
  ClientHeight = 280
  ClientWidth = 480
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
    Width = 480
    Height = 280
    Align = alClient
    TabOrder = 0
    object lblPersonId: TLabel
      Left = 95
      Top = 30
      Width = 45
      Height = 15
      Alignment = taRightJustify
      Caption = 'Personel'
    end
    object lblAddressId: TLabel
      Left = 110
      Top = 65
      Width = 30
      Height = 15
      Alignment = taRightJustify
      Caption = 'Adres'
    end
    object lblAddressType: TLabel
      Left = 87
      Top = 100
      Width = 53
      Height = 15
      Alignment = taRightJustify
      Caption = 'Adres Tipi'
    end
    object lblIsPrimary: TLabel
      Left = 71
      Top = 135
      Width = 69
      Height = 15
      Alignment = taRightJustify
      Caption = 'Birincil Adres'
    end
    object lblValidFrom: TLabel
      Left = 36
      Top = 170
      Width = 104
      Height = 15
      Alignment = taRightJustify
      Caption = 'Ge'#231'erlilik Ba'#351'lang'#305'c'#305
    end
    object lblValidTo: TLabel
      Left = 64
      Top = 205
      Width = 76
      Height = 15
      Alignment = taRightJustify
      Caption = 'Ge'#231'erlilik Biti'#351'i'
    end
    object edtPersonId: TEdit
      Left = 150
      Top = 27
      Width = 280
      Height = 23
      TabOrder = 0
    end
    object edtAddressId: TEdit
      Left = 150
      Top = 62
      Width = 280
      Height = 23
      TabOrder = 1
    end
    object cbbAddressType: TComboBox
      Left = 150
      Top = 97
      Width = 280
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 2
      Text = 'HOME'
      Items.Strings = (
        'HOME'
        'WORK'
        'MAILING'
        'LEGAL'
        'OTHER')
    end
    object chkIsPrimary: TCheckBox
      Left = 150
      Top = 134
      Width = 150
      Height = 17
      TabOrder = 3
    end
    object dtpValidFrom: TDateTimePicker
      Left = 150
      Top = 167
      Width = 150
      Height = 23
      Date = 45000.000000000000000000
      Time = 45000.000000000000000000
      TabOrder = 4
    end
    object dtpValidTo: TDateTimePicker
      Left = 150
      Top = 202
      Width = 150
      Height = 23
      Date = 45000.000000000000000000
      Time = 45000.000000000000000000
      TabOrder = 5
    end
  end
end

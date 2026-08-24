object frmEmpPerson: TfrmEmpPerson
  Left = 0
  Top = 0
  Caption = 'Personel'
  ClientHeight = 628
  ClientWidth = 613
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
    Width = 613
    Height = 628
    Align = alClient
    TabOrder = 0
    object lblName: TLabel
      Left = 126
      Top = 15
      Width = 18
      Height = 15
      Alignment = taRightJustify
      Caption = 'Ad'#305
    end
    object lblSurname: TLabel
      Left = 109
      Top = 45
      Width = 35
      Height = 15
      Alignment = taRightJustify
      Caption = 'Soyad'#305
    end
    object lblPhone1: TLabel
      Left = 96
      Top = 75
      Width = 48
      Height = 15
      Alignment = taRightJustify
      Caption = 'Telefon 1'
    end
    object lblPhone2: TLabel
      Left = 96
      Top = 105
      Width = 48
      Height = 15
      Alignment = taRightJustify
      Caption = 'Telefon 2'
    end
    object lblPersonTypeId: TLabel
      Left = 76
      Top = 135
      Width = 68
      Height = 15
      Alignment = taRightJustify
      Caption = 'Personel Tipi'
    end
    object lblUnitId: TLabel
      Left = 116
      Top = 165
      Width = 28
      Height = 15
      Alignment = taRightJustify
      Caption = 'Birim'
    end
    object lblTaskId: TLabel
      Left = 113
      Top = 195
      Width = 31
      Height = 15
      Alignment = taRightJustify
      Caption = 'G'#246'rev'
    end
    object lblBirth: TLabel
      Left = 72
      Top = 225
      Width = 72
      Height = 15
      Alignment = taRightJustify
      Caption = 'Do'#287'um Tarihi'
    end
    object lblBlood: TLabel
      Left = 88
      Top = 255
      Width = 56
      Height = 15
      Alignment = taRightJustify
      Caption = 'Kan Grubu'
    end
    object lblGender: TLabel
      Left = 102
      Top = 285
      Width = 42
      Height = 15
      Alignment = taRightJustify
      Caption = 'Cinsiyet'
    end
    object lblMilitaryStatus: TLabel
      Left = 56
      Top = 315
      Width = 88
      Height = 15
      Alignment = taRightJustify
      Caption = 'Askerlik Durumu'
    end
    object lblMaritalStatus: TLabel
      Left = 64
      Top = 345
      Width = 80
      Height = 15
      Alignment = taRightJustify
      Caption = 'Medeni Durum'
    end
    object lblChild: TLabel
      Left = 78
      Top = 375
      Width = 66
      Height = 15
      Alignment = taRightJustify
      Caption = #199'ocuk Say'#305's'#305
    end
    object lblRelatedName: TLabel
      Left = 95
      Top = 405
      Width = 49
      Height = 15
      Alignment = taRightJustify
      Caption = 'Yak'#305'n Ad'#305
    end
    object lblRelatedPhone: TLabel
      Left = 98
      Top = 435
      Width = 46
      Height = 15
      Alignment = taRightJustify
      Caption = 'Yak'#305'n Tel'
    end
    object lblShoe: TLabel
      Left = 77
      Top = 465
      Width = 67
      Height = 15
      Alignment = taRightJustify
      Caption = 'Ayakkab'#305' No'
    end
    object lblDress: TLabel
      Left = 111
      Top = 495
      Width = 33
      Height = 15
      Alignment = taRightJustify
      Caption = 'Beden'
    end
    object lblNotes: TLabel
      Left = 111
      Top = 525
      Width = 33
      Height = 15
      Alignment = taRightJustify
      Caption = 'Notlar'
    end
    object lblTransportationId: TLabel
      Left = 318
      Top = 381
      Width = 87
      Height = 15
      Caption = 'TransportationId'
      Visible = False
    end
    object lblSpecialNotes: TLabel
      Left = 356
      Top = 465
      Width = 66
      Height = 15
      Caption = 'Special Note'
      Visible = False
    end
    object lblSalary: TLabel
      Left = 345
      Top = 315
      Width = 31
      Height = 15
      Caption = 'Salary'
      Visible = False
    end
    object lblNumberOfBonus: TLabel
      Left = 345
      Top = 345
      Width = 94
      Height = 15
      Caption = 'Number of Bonus'
      Visible = False
    end
    object lblBonus: TLabel
      Left = 409
      Top = 256
      Width = 33
      Height = 15
      Caption = 'Bonus'
      Visible = False
    end
    object lblIdentification: TLabel
      Left = 359
      Top = 285
      Width = 70
      Height = 15
      Caption = 'Identification'
      Visible = False
    end
    object lblActive: TLabel
      Left = 119
      Top = 565
      Width = 25
      Height = 15
      Alignment = taRightJustify
      Caption = 'Aktif'
    end
    object edtName: TEdit
      Left = 154
      Top = 12
      Width = 382
      Height = 23
      TabOrder = 0
    end
    object edtSurname: TEdit
      Left = 154
      Top = 42
      Width = 382
      Height = 23
      TabOrder = 1
    end
    object edtPhone1: TEdit
      Left = 154
      Top = 72
      Width = 382
      Height = 23
      TabOrder = 2
    end
    object edtPhone2: TEdit
      Left = 154
      Top = 102
      Width = 382
      Height = 23
      TabOrder = 3
    end
    object edtPersonTypeId: TEdit
      Left = 154
      Top = 132
      Width = 382
      Height = 23
      TabOrder = 4
    end
    object edtUnitId: TEdit
      Left = 154
      Top = 162
      Width = 382
      Height = 23
      TabOrder = 5
    end
    object edtTaskId: TEdit
      Left = 154
      Top = 192
      Width = 382
      Height = 23
      TabOrder = 6
    end
    object dtpBirth: TDateTimePicker
      Left = 154
      Top = 222
      Width = 150
      Height = 23
      Date = 45000.000000000000000000
      Time = 45000.000000000000000000
      TabOrder = 7
    end
    object edtBlood: TEdit
      Left = 154
      Top = 252
      Width = 150
      Height = 23
      TabOrder = 8
    end
    object cbbGender: TComboBox
      Left = 154
      Top = 282
      Width = 150
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 9
      Text = 'Erkek'
      Items.Strings = (
        'Erkek'
        'Kad'#305'n')
    end
    object cbbMilitaryStatus: TComboBox
      Left = 154
      Top = 312
      Width = 150
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 10
      Text = 'Yapt'#305
      Items.Strings = (
        'Yapt'#305
        'Muaf'
        'Yapmad'#305)
    end
    object cbbMaritalStatus: TComboBox
      Left = 154
      Top = 342
      Width = 150
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 11
      Text = 'Bekar'
      Items.Strings = (
        'Bekar'
        'Evli')
    end
    object seChild: TSpinEdit
      Left = 154
      Top = 372
      Width = 150
      Height = 24
      MaxValue = 20
      MinValue = 0
      TabOrder = 12
      Value = 0
    end
    object edtRelatedName: TEdit
      Left = 154
      Top = 402
      Width = 382
      Height = 23
      TabOrder = 13
    end
    object edtRelatedPhone: TEdit
      Left = 154
      Top = 432
      Width = 382
      Height = 23
      TabOrder = 14
    end
    object seShoe: TSpinEdit
      Left = 154
      Top = 462
      Width = 150
      Height = 24
      MaxValue = 60
      MinValue = 0
      TabOrder = 15
      Value = 0
    end
    object edtDress: TEdit
      Left = 154
      Top = 492
      Width = 150
      Height = 23
      TabOrder = 16
    end
    object mmoNotes: TMemo
      Left = 154
      Top = 522
      Width = 382
      Height = 40
      TabOrder = 17
    end
    object edtTransportationId: TEdit
      Left = 411
      Top = 373
      Width = 93
      Height = 23
      TabOrder = 18
      Visible = False
    end
    object mmoSpecialNotes: TMemo
      Left = 432
      Top = 461
      Width = 81
      Height = 64
      TabOrder = 19
      Visible = False
    end
    object edtSalary: TEdit
      Left = 456
      Top = 312
      Width = 48
      Height = 23
      TabOrder = 20
      Visible = False
    end
    object seNumberOfBonus: TSpinEdit
      Left = 456
      Top = 341
      Width = 91
      Height = 24
      MaxValue = 0
      MinValue = 0
      TabOrder = 21
      Value = 0
      Visible = False
    end
    object edtIdentification: TEdit
      Left = 424
      Top = 282
      Width = 80
      Height = 23
      TabOrder = 22
      Visible = False
    end
    object chkActive: TCheckBox
      Left = 154
      Top = 564
      Width = 97
      Height = 17
      TabOrder = 24
    end
    object edtBonus: TEdit
      Left = 448
      Top = 252
      Width = 56
      Height = 23
      TabOrder = 23
      Visible = False
    end
  end
end

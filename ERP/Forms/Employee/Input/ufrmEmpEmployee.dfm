object frmEmpEmployee: TfrmEmpEmployee
  Left = 0
  Top = 0
  Caption = 'Employee'
  ClientHeight = 505
  ClientWidth = 720
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
    Width = 720
    Height = 505
    Align = alClient
    TabOrder = 0
    object lblName: TLabel
      Left = 4
      Top = 8
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ad'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtName: TEdit
      Left = 128
      Top = 4
      Width = 220
      Height = 22
      TabOrder = 0
    end
    object lblSurname: TLabel
      Left = 4
      Top = 33
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Soyad'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSurname: TEdit
      Left = 128
      Top = 29
      Width = 220
      Height = 22
      TabOrder = 1
    end
    object lblPhone1: TLabel
      Left = 4
      Top = 58
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Telefon 1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPhone1: TEdit
      Left = 128
      Top = 54
      Width = 220
      Height = 22
      TabOrder = 2
    end
    object lblPhone2: TLabel
      Left = 4
      Top = 83
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Telefon 2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtPhone2: TEdit
      Left = 128
      Top = 79
      Width = 220
      Height = 22
      TabOrder = 3
    end
    object lblEmpPersonTypeId: TLabel
      Left = 4
      Top = 108
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Personel Tipi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEmpPersonTypeId: TEdit
      Left = 128
      Top = 104
      Width = 220
      Height = 22
      ReadOnly = True
      TabOrder = 4
    end
    object lblEmpUnitId: TLabel
      Left = 4
      Top = 133
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Birim'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEmpUnitId: TEdit
      Left = 128
      Top = 129
      Width = 220
      Height = 22
      ReadOnly = True
      TabOrder = 5
    end
    object lblEmpTaskId: TLabel
      Left = 4
      Top = 158
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'G'#246'rev'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEmpTaskId: TEdit
      Left = 128
      Top = 154
      Width = 220
      Height = 22
      ReadOnly = True
      TabOrder = 6
    end
    object lblBirthDate: TLabel
      Left = 4
      Top = 183
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Do'#287'um Tarihi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBirthDate: TEdit
      Left = 128
      Top = 179
      Width = 220
      Height = 22
      TabOrder = 7
    end
    object lblBloodType: TLabel
      Left = 4
      Top = 208
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kan Grubu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbBloodType: TComboBox
      Left = 128
      Top = 204
      Width = 220
      Height = 22
      Style = csDropDownList
      TabOrder = 8
    end
    object lblGender: TLabel
      Left = 4
      Top = 233
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Cinsiyet'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbGender: TComboBox
      Left = 128
      Top = 229
      Width = 220
      Height = 22
      Style = csDropDownList
      TabOrder = 9
    end
    object lblMilitaryStatus: TLabel
      Left = 4
      Top = 258
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Askerlik'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbMilitaryStatus: TComboBox
      Left = 128
      Top = 254
      Width = 220
      Height = 22
      Style = csDropDownList
      TabOrder = 10
    end
    object lblMaritalStatus: TLabel
      Left = 4
      Top = 283
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Medeni Durum'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbMaritalStatus: TComboBox
      Left = 128
      Top = 279
      Width = 220
      Height = 22
      Style = csDropDownList
      TabOrder = 11
    end
    object lblChild: TLabel
      Left = 4
      Top = 308
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #199'ocuk Say'#305's'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbChild: TComboBox
      Left = 128
      Top = 304
      Width = 220
      Height = 22
      Style = csDropDownList
      TabOrder = 12
    end
    object lblRelativeName: TLabel
      Left = 356
      Top = 8
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Yak'#305'n Ad'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtRelativeName: TEdit
      Left = 480
      Top = 4
      Width = 220
      Height = 22
      TabOrder = 13
    end
    object lblRelativePhone: TLabel
      Left = 356
      Top = 33
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Yak'#305'n Telefonu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtRelativePhone: TEdit
      Left = 480
      Top = 29
      Width = 220
      Height = 22
      TabOrder = 14
    end
    object lblShoeSize: TLabel
      Left = 356
      Top = 58
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Ayakkab'#305' No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtShoeSize: TEdit
      Left = 480
      Top = 54
      Width = 220
      Height = 22
      TabOrder = 15
    end
    object lblClothingSize: TLabel
      Left = 356
      Top = 83
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Beden'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbClothingSize: TComboBox
      Left = 480
      Top = 79
      Width = 220
      Height = 22
      Style = csDropDownList
      TabOrder = 16
    end
    object lblEmpTransportationId: TLabel
      Left = 356
      Top = 108
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Servis'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEmpTransportationId: TEdit
      Left = 480
      Top = 104
      Width = 220
      Height = 22
      ReadOnly = True
      TabOrder = 17
    end
    object lblSalaryAmount: TLabel
      Left = 356
      Top = 133
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Maa'#351
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSalaryAmount: TEdit
      Left = 480
      Top = 129
      Width = 220
      Height = 22
      TabOrder = 18
    end
    object lblBonusCount: TLabel
      Left = 356
      Top = 158
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'kramiye Say'#305's'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cbbBonusCount: TComboBox
      Left = 480
      Top = 154
      Width = 220
      Height = 22
      Style = csDropDownList
      TabOrder = 19
    end
    object lblBonusAmount: TLabel
      Left = 356
      Top = 183
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #304'kramiye Tutar'#305
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBonusAmount: TEdit
      Left = 480
      Top = 179
      Width = 220
      Height = 22
      TabOrder = 20
    end
    object lblIdDocumentNo: TLabel
      Left = 356
      Top = 208
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kimlik No'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtIdDocumentNo: TEdit
      Left = 480
      Top = 204
      Width = 220
      Height = 22
      TabOrder = 21
    end
    object lblActive: TLabel
      Left = 356
      Top = 233
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Aktif'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkActive: TCheckBox
      Left = 480
      Top = 231
      Width = 100
      Height = 17
      TabOrder = 22
    end
    object lblNotes: TLabel
      Left = 4
      Top = 337
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Notlar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object mmoNotes: TMemo
      Left = 128
      Top = 333
      Width = 572
      Height = 48
      ScrollBars = ssVertical
      TabOrder = 23
    end
    object lblSpecialNotes: TLabel
      Left = 4
      Top = 393
      Width = 120
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #214'zel Notlar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object mmoSpecialNotes: TMemo
      Left = 128
      Top = 389
      Width = 572
      Height = 48
      ScrollBars = ssVertical
      TabOrder = 24
    end
  end
end

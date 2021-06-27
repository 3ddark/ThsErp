inherited frmPrsPersonel: TfrmPrsPersonel
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Employee Card'
  ClientHeight = 479
  ClientWidth = 635
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 641
  ExplicitHeight = 508
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 631
    Height = 427
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 631
    ExplicitHeight = 413
    inherited pgcMain: TPageControl
      Width = 629
      Height = 425
      OnChange = pgcMainChange
      ExplicitWidth = 629
      ExplicitHeight = 411
      inherited tsMain: TTabSheet
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 621
        ExplicitHeight = 397
        object lblis_active: TLabel
          Left = 80
          Top = 10
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Active?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_name: TLabel
          Left = 33
          Top = 32
          Width = 91
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Employee Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_surname: TLabel
          Left = 320
          Top = 32
          Width = 108
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Employee Surname'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_type_id: TLabel
          Left = 37
          Top = 54
          Width = 87
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Employee Type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_section_id: TLabel
          Left = 80
          Top = 76
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Section'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_unit_id: TLabel
          Left = 100
          Top = 98
          Width = 24
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Unit'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_task_id: TLabel
          Left = 95
          Top = 120
          Width = 29
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Task'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_transport_id: TLabel
          Left = 357
          Top = 54
          Width = 75
          Height = 13
          Alignment = taRightJustify
          Caption = 'Transport No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblgeneral_note: TLabel
          Left = 66
          Top = 142
          Width = 58
          Height = 13
          Alignment = taRightJustify
          Caption = 'Genel Not'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object imgPersonelResim: TImage
          Left = 433
          Top = 73
          Width = 180
          Height = 180
          Stretch = True
        end
        object chkis_active: TCheckBox
          Left = 130
          Top = 7
          Width = 184
          Height = 21
          TabOrder = 0
        end
        object edtemp_name: TEdit
          Left = 130
          Top = 29
          Width = 180
          Height = 21
          TabOrder = 1
        end
        object edtemp_surname: TEdit
          Left = 434
          Top = 29
          Width = 180
          Height = 21
          TabOrder = 2
        end
        object cbbemp_type_id: TComboBox
          Left = 130
          Top = 51
          Width = 180
          Height = 21
          TabOrder = 3
        end
        object cbbemp_transport_id: TComboBox
          Left = 433
          Top = 51
          Width = 180
          Height = 21
          TabOrder = 4
        end
        object mmogeneral_note: TMemo
          Left = 130
          Top = 139
          Width = 298
          Height = 144
          MaxLength = 256
          ScrollBars = ssVertical
          TabOrder = 8
        end
        object edtemp_section_id: TEdit
          Left = 130
          Top = 73
          Width = 180
          Height = 21
          TabOrder = 5
        end
        object edtemp_unit_id: TEdit
          Left = 130
          Top = 95
          Width = 180
          Height = 21
          TabOrder = 6
        end
        object edtemp_task_id: TEdit
          Left = 130
          Top = 117
          Width = 180
          Height = 21
          TabOrder = 7
        end
      end
      object tsDetail: TTabSheet
        Caption = 'tsDetail'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object lblpostal_box: TLabel
          Left = 65
          Top = 230
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Postal Box'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblbuilding_name: TLabel
          Left = 44
          Top = 186
          Width = 82
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Building Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblstreet: TLabel
          Left = 91
          Top = 164
          Width = 35
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Street'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblroad: TLabel
          Left = 95
          Top = 142
          Width = 31
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Road'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldistrict: TLabel
          Left = 85
          Top = 120
          Width = 41
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'District'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltown: TLabel
          Left = 94
          Top = 98
          Width = 32
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Town'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcity_id: TLabel
          Left = 104
          Top = 76
          Width = 22
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'City'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcountry_id: TLabel
          Left = 82
          Top = 54
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
        object lblpostal_code: TLabel
          Left = 57
          Top = 252
          Width = 69
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Postal Code'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldoor_no: TLabel
          Left = 78
          Top = 208
          Width = 48
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Door No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edttown: TEdit
          Left = 130
          Top = 95
          Width = 180
          Height = 21
          TabOrder = 2
        end
        object edtdistrict: TEdit
          Left = 130
          Top = 117
          Width = 180
          Height = 21
          TabOrder = 3
        end
        object edtroad: TEdit
          Left = 130
          Top = 139
          Width = 180
          Height = 21
          TabOrder = 4
        end
        object edtstreet: TEdit
          Left = 130
          Top = 161
          Width = 180
          Height = 21
          TabOrder = 5
        end
        object edtbuilding_name: TEdit
          Left = 130
          Top = 183
          Width = 180
          Height = 21
          TabOrder = 6
        end
        object edtdoor_no: TEdit
          Left = 130
          Top = 205
          Width = 180
          Height = 21
          TabOrder = 7
        end
        object edtpostal_box: TEdit
          Left = 130
          Top = 227
          Width = 180
          Height = 21
          TabOrder = 8
        end
        object edtpostal_code: TEdit
          Left = 130
          Top = 249
          Width = 180
          Height = 21
          TabOrder = 9
        end
        object edtcountry_id: TEdit
          Left = 130
          Top = 51
          Width = 180
          Height = 21
          TabOrder = 0
        end
        object edtcity_id: TEdit
          Left = 130
          Top = 73
          Width = 180
          Height = 21
          TabOrder = 1
        end
      end
      object tsAbility: TTabSheet
        Caption = 'tsAbility'
        ImageIndex = 2
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object strngrdDriverLicenseAbility: TStringGrid
          Left = 20
          Top = 59
          Width = 191
          Height = 118
          ColCount = 3
          DefaultColWidth = 24
          DefaultRowHeight = 18
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          ColWidths = (
            24
            24
            24)
          RowHeights = (
            18
            18
            18
            18
            18)
        end
        object strngrdSrcAbility: TStringGrid
          Left = 278
          Top = 59
          Width = 114
          Height = 118
          ColCount = 3
          DefaultColWidth = 24
          DefaultRowHeight = 18
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          ColWidths = (
            24
            24
            24)
          RowHeights = (
            18
            18
            18
            18
            18)
        end
        object strngrdLangAbility: TStringGrid
          Left = 20
          Top = 218
          Width = 372
          Height = 134
          ColCount = 3
          DefaultColWidth = 24
          DefaultRowHeight = 18
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          ColWidths = (
            24
            24
            24)
          RowHeights = (
            18
            18
            18
            18
            18)
        end
        object btnDriverLicenseAdd: TButton
          Left = 20
          Top = 178
          Width = 20
          Height = 25
          TabOrder = 3
          OnClick = btnDriverLicenseAddClick
        end
        object btnDriverLicenseEdit: TButton
          Left = 46
          Top = 178
          Width = 20
          Height = 25
          TabOrder = 4
        end
        object btnDriverLicenseRemove: TButton
          Left = 72
          Top = 178
          Width = 20
          Height = 25
          TabOrder = 5
        end
        object Button1: TButton
          Left = 278
          Top = 178
          Width = 20
          Height = 25
          TabOrder = 6
          OnClick = btnDriverLicenseAddClick
        end
        object Button2: TButton
          Left = 304
          Top = 178
          Width = 20
          Height = 25
          TabOrder = 7
        end
        object Button3: TButton
          Left = 330
          Top = 178
          Width = 20
          Height = 25
          TabOrder = 8
        end
        object Button4: TButton
          Left = 20
          Top = 354
          Width = 20
          Height = 25
          TabOrder = 9
          OnClick = btnDriverLicenseAddClick
        end
        object Button5: TButton
          Left = 46
          Top = 354
          Width = 20
          Height = 25
          TabOrder = 10
        end
        object Button6: TButton
          Left = 72
          Top = 354
          Width = 20
          Height = 25
          TabOrder = 11
        end
      end
      object tsSpecial: TTabSheet
        Caption = 'tsSpecial'
        ImageIndex = 2
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object lblsalary: TLabel
          Left = 93
          Top = 224
          Width = 36
          Height = 13
          Alignment = taRightJustify
          Caption = 'Salary'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblspecial_note: TLabel
          Left = 55
          Top = 268
          Width = 74
          Height = 13
          Alignment = taRightJustify
          Caption = 'Special Note'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblbonus: TLabel
          Left = 93
          Top = 246
          Width = 36
          Height = 13
          Alignment = taRightJustify
          Caption = 'Bonus'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblbonus_amount: TLabel
          Left = 351
          Top = 246
          Width = 82
          Height = 13
          Alignment = taRightJustify
          Caption = 'Bonus Amount'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblphone1: TLabel
          Left = 81
          Top = 54
          Width = 48
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Phone 1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblphone2: TLabel
          Left = 81
          Top = 76
          Width = 48
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Phone 2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblclose_phone: TLabel
          Left = 57
          Top = 142
          Width = 72
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Close Phone'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblclose_name: TLabel
          Left = 61
          Top = 120
          Width = 68
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Close Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemail: TLabel
          Left = 93
          Top = 98
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'E-Mail'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblshoe_no: TLabel
          Left = 78
          Top = 164
          Width = 50
          Height = 13
          Alignment = taRightJustify
          Caption = 'Shoe No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lbldress_size: TLabel
          Left = 67
          Top = 186
          Width = 61
          Height = 13
          Alignment = taRightJustify
          Caption = 'Dress Size'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblemp_goverment_id: TLabel
          Left = 353
          Top = 54
          Width = 79
          Height = 13
          Alignment = taRightJustify
          Caption = 'Goverment ID'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblbirth_date: TLabel
          Left = 374
          Top = 76
          Width = 58
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Birth Date'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblblood: TLabel
          Left = 399
          Top = 98
          Width = 33
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Blood'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_gender_id: TLabel
          Left = 390
          Top = 120
          Width = 42
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Gender'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_marital_kind_id: TLabel
          Left = 364
          Top = 142
          Width = 68
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Marital Kind'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblemp_military_kind_id: TLabel
          Left = 362
          Top = 186
          Width = 70
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Military Kind'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblchild: TLabel
          Left = 403
          Top = 164
          Width = 29
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Child'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtphone1: TEdit
          Left = 130
          Top = 51
          Width = 180
          Height = 21
          TabOrder = 0
        end
        object edtphone2: TEdit
          Left = 130
          Top = 73
          Width = 180
          Height = 21
          TabOrder = 2
        end
        object edtemail: TEdit
          Left = 130
          Top = 95
          Width = 180
          Height = 21
          TabOrder = 4
        end
        object edtclose_name: TEdit
          Left = 130
          Top = 117
          Width = 180
          Height = 21
          TabOrder = 6
        end
        object edtclose_phone: TEdit
          Left = 130
          Top = 139
          Width = 180
          Height = 21
          TabOrder = 8
        end
        object edtshoe_no: TEdit
          Left = 131
          Top = 161
          Width = 180
          Height = 21
          MaxLength = 2
          TabOrder = 10
        end
        object edtdress_size: TEdit
          Left = 131
          Top = 183
          Width = 180
          Height = 21
          MaxLength = 4
          TabOrder = 12
        end
        object edtemp_goverment_id: TEdit
          Left = 434
          Top = 51
          Width = 180
          Height = 21
          MaxLength = 11
          TabOrder = 1
        end
        object edtbirth_date: TEdit
          Left = 434
          Top = 73
          Width = 180
          Height = 21
          TabOrder = 3
        end
        object cbbblood: TComboBox
          Left = 434
          Top = 95
          Width = 180
          Height = 21
          TabOrder = 5
        end
        object cbbemp_gender_id: TComboBox
          Left = 434
          Top = 117
          Width = 180
          Height = 21
          TabOrder = 7
          OnChange = cbbemp_gender_idChange
        end
        object cbbemp_marital_kind_id: TComboBox
          Left = 434
          Top = 139
          Width = 180
          Height = 21
          TabOrder = 9
          OnChange = cbbemp_marital_kind_idChange
        end
        object edtchild: TEdit
          Left = 434
          Top = 161
          Width = 180
          Height = 21
          TabOrder = 11
        end
        object cbbemp_military_kind_id: TComboBox
          Left = 434
          Top = 183
          Width = 180
          Height = 21
          TabOrder = 13
        end
        object edtsalary: TEdit
          Left = 130
          Top = 221
          Width = 180
          Height = 21
          MaxLength = 10
          TabOrder = 14
        end
        object edtbonus: TEdit
          Left = 130
          Top = 243
          Width = 180
          Height = 21
          MaxLength = 16
          TabOrder = 15
        end
        object edtbonus_amount: TEdit
          Left = 434
          Top = 243
          Width = 180
          Height = 21
          MaxLength = 16
          TabOrder = 16
        end
        object mmospecial_note: TMemo
          Left = 130
          Top = 265
          Width = 484
          Height = 112
          MaxLength = 256
          ScrollBars = ssVertical
          TabOrder = 17
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 431
    Width = 631
    ExplicitTop = 417
    ExplicitWidth = 631
    inherited btnAccept: TButton
      Left = 422
      ExplicitLeft = 422
    end
    inherited btnClose: TButton
      Left = 526
      ExplicitLeft = 526
    end
  end
  inherited stbBase: TStatusBar
    Top = 461
    Width = 635
    ExplicitTop = 461
    ExplicitWidth = 635
  end
  inherited pmLabels: TPopupMenu
    Left = 280
    Top = 456
  end
end

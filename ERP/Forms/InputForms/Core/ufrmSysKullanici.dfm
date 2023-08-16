inherited frmSysKullanici: TfrmSysKullanici
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'System User'
  ClientHeight = 261
  ClientWidth = 366
  ParentFont = True
  ExplicitWidth = 382
  ExplicitHeight = 300
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 366
    Height = 211
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 376
    ExplicitHeight = 230
    inherited pgcMain: TPageControl
      Width = 368
      Height = 214
      ExplicitWidth = 368
      ExplicitHeight = 214
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 360
        ExplicitHeight = 184
        object lbluser_name: TLabel
          Left = 47
          Top = 10
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'User Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbluser_pass: TLabel
          Left = 25
          Top = 32
          Width = 83
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'User Password'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_active: TLabel
          Left = 66
          Top = 57
          Width = 42
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Active?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_manager: TLabel
          Left = 52
          Top = 77
          Width = 56
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Manager?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_super_user: TLabel
          Left = 40
          Top = 97
          Width = 68
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Super User?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblip_address: TLabel
          Left = 47
          Top = 122
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'IP Address'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblmac_address: TLabel
          Left = 36
          Top = 144
          Width = 72
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mac Address'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblperson_id: TLabel
          Left = 54
          Top = 166
          Width = 54
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Full Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtuser_name: TEdit
          Left = 114
          Top = 7
          Width = 239
          Height = 23
          TabOrder = 0
        end
        object edtuser_pass: TEdit
          Left = 114
          Top = 29
          Width = 239
          Height = 23
          PasswordChar = '*'
          TabOrder = 1
        end
        object chkis_active: TCheckBox
          Left = 114
          Top = 56
          Width = 239
          Height = 17
          TabOrder = 2
        end
        object chkis_manager: TCheckBox
          Left = 114
          Top = 76
          Width = 239
          Height = 17
          TabOrder = 3
        end
        object chkis_super_user: TCheckBox
          Left = 114
          Top = 96
          Width = 239
          Height = 17
          TabOrder = 4
        end
        object edtip_address: TEdit
          Left = 114
          Top = 119
          Width = 239
          Height = 23
          TabOrder = 5
        end
        object edtmac_address: TEdit
          Left = 114
          Top = 141
          Width = 239
          Height = 23
          TabOrder = 6
        end
        object edtperson_id: TEdit
          Left = 114
          Top = 163
          Width = 239
          Height = 23
          TabOrder = 7
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 213
    Width = 362
    ExplicitTop = 232
    ExplicitWidth = 372
    inherited btnAccept: TButton
      Left = 166
      ExplicitLeft = 166
    end
    inherited btnClose: TButton
      Left = 270
      ExplicitLeft = 270
    end
  end
  inherited stbBase: TStatusBar
    Top = 243
    Width = 366
    ExplicitTop = 262
    ExplicitWidth = 376
  end
end

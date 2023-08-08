inherited frmSysErisimHakki: TfrmSysErisimHakki
  Left = 501
  Top = 443
  Caption = 'Accesss Right'
  ClientHeight = 232
  ClientWidth = 359
  ParentFont = True
  ExplicitWidth = 375
  ExplicitHeight = 271
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 359
    Height = 182
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 375
    ExplicitHeight = 214
    inherited pgcMain: TPageControl
      Width = 361
      Height = 186
      ExplicitWidth = 361
      ExplicitHeight = 186
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 353
        ExplicitHeight = 156
        object lbluser_id: TLabel
          Left = 55
          Top = 7
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
        object lblresource_id: TLabel
          Left = 28
          Top = 29
          Width = 88
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Resource Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_read: TLabel
          Left = 81
          Top = 53
          Width = 35
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Read?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_add: TLabel
          Left = 88
          Top = 76
          Width = 28
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Add?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_update: TLabel
          Left = 69
          Top = 99
          Width = 47
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Update?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_delete: TLabel
          Left = 73
          Top = 122
          Width = 43
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Delete?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_special: TLabel
          Left = 70
          Top = 145
          Width = 46
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Special?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtuser_id: TEdit
          Left = 122
          Top = 3
          Width = 224
          Height = 23
          TabOrder = 0
        end
        object edtresource_id: TEdit
          Left = 122
          Top = 25
          Width = 224
          Height = 23
          TabOrder = 1
        end
        object chkis_read: TCheckBox
          Left = 122
          Top = 52
          Width = 223
          Height = 17
          TabOrder = 2
        end
        object chkis_add: TCheckBox
          Left = 122
          Top = 75
          Width = 223
          Height = 17
          TabOrder = 3
        end
        object chkis_update: TCheckBox
          Left = 122
          Top = 98
          Width = 223
          Height = 17
          TabOrder = 4
        end
        object chkis_delete: TCheckBox
          Left = 122
          Top = 121
          Width = 223
          Height = 17
          TabOrder = 5
        end
        object chkis_special: TCheckBox
          Left = 122
          Top = 144
          Width = 223
          Height = 17
          TabOrder = 6
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 184
    Width = 355
    ExplicitTop = 216
    ExplicitWidth = 371
    inherited btnAccept: TButton
      Left = 165
      ExplicitLeft = 165
    end
    inherited btnClose: TButton
      Left = 269
      ExplicitLeft = 269
    end
  end
  inherited stbBase: TStatusBar
    Top = 214
    Width = 359
    ExplicitTop = 246
    ExplicitWidth = 375
  end
end

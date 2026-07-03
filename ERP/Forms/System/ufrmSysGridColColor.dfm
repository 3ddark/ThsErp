inherited frmSysGridColColor: TfrmSysGridColColor
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sutun Renk Ayarlari'
  ClientHeight = 249
  ClientWidth = 377
  ParentFont = True
  ExplicitWidth = 383
  ExplicitHeight = 278
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 373
    Height = 183
    Color = clWindow
    ExplicitWidth = 373
    ExplicitHeight = 183
    inherited pgcMain: TPageControl
      Width = 371
      Height = 181
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 371
      ExplicitHeight = 181
      inherited tsMain: TTabSheet
        ExplicitWidth = 363
        ExplicitHeight = 153
        object lblColumnName: TLabel
          Left = 39
          Top = 30
          Width = 77
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kolon Adi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblMaxColor: TLabel
          Left = 60
          Top = 122
          Width = 56
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Maks Renk'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblMaxValue: TLabel
          Left = 58
          Top = 99
          Width = 58
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Maks Deger'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblMinColor: TLabel
          Left = 64
          Top = 76
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Min Renk'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblMinValue: TLabel
          Left = 62
          Top = 53
          Width = 54
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Min Deger'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblTableName: TLabel
          Left = 50
          Top = 7
          Width = 66
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tablo Adi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbTableName: TComboBox
          Left = 122
          Top = 4
          Width = 240
          Height = 21
          TabOrder = 0
          OnChange = cbbTableNameChange
        end
        object cbbColumnName: TComboBox
          Left = 122
          Top = 27
          Width = 240
          Height = 21
          TabOrder = 1
        end
        object edtMinValue: TEdit
          Left = 122
          Top = 50
          Width = 240
          Height = 21
          TabOrder = 2
        end
        object edtMinColor: TEdit
          Left = 122
          Top = 73
          Width = 240
          Height = 21
          TabOrder = 3
          OnDblClick = edtMinColorDblClick
        end
        object edtMaxValue: TEdit
          Left = 122
          Top = 96
          Width = 240
          Height = 21
          TabOrder = 4
        end
        object edtMaxColor: TEdit
          Left = 122
          Top = 119
          Width = 240
          Height = 21
          TabOrder = 5
          OnDblClick = edtMaxColorDblClick
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 187
    Width = 373
    ExplicitTop = 187
    ExplicitWidth = 373
    inherited btnAccept: TButton
      Left = 164
      ExplicitLeft = 164
    end
    inherited btnClose: TButton
      Left = 268
      ExplicitLeft = 268
    end
  end
  inherited stbBase: TStatusBar
    Top = 231
    Width = 377
    ExplicitTop = 231
    ExplicitWidth = 377
  end
end

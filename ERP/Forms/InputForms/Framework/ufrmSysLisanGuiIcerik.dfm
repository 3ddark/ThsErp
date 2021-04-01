inherited frmSysLisanGuiIcerik: TfrmSysLisanGuiIcerik
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem Lisan GUI '#304#231'erik'
  ClientHeight = 263
  ClientWidth = 441
  ParentFont = True
  ExplicitWidth = 447
  ExplicitHeight = 292
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 437
    Height = 197
    Color = clWindow
    ExplicitWidth = 437
    ExplicitHeight = 197
    inherited pgcMain: TPageControl
      Width = 435
      Height = 195
      ExplicitWidth = 435
      ExplicitHeight = 195
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 427
        ExplicitHeight = 167
        object lbllisan: TLabel
          Left = 103
          Top = 7
          Width = 29
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Lisan'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkod: TLabel
          Left = 111
          Top = 29
          Width = 21
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kod'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldeger: TLabel
          Left = 98
          Top = 51
          Width = 34
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'De'#287'er'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblicerik_tipi: TLabel
          Left = 76
          Top = 73
          Width = 56
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304#231'erik Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbltablo_adi: TLabel
          Left = 80
          Top = 95
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tablo Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblform_adi: TLabel
          Left = 82
          Top = 117
          Width = 50
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Form Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_fabrika_ayari: TLabel
          Left = 57
          Top = 141
          Width = 75
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Fabrika Ayar'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbblisan: TComboBox
          Left = 138
          Top = 4
          Width = 279
          Height = 21
          TabOrder = 0
        end
        object edtkod: TEdit
          Left = 138
          Top = 26
          Width = 279
          Height = 21
          TabOrder = 1
        end
        object edtdeger: TEdit
          Left = 138
          Top = 48
          Width = 279
          Height = 21
          TabOrder = 2
        end
        object edticerik_tipi: TEdit
          Left = 138
          Top = 70
          Width = 279
          Height = 21
          TabOrder = 3
        end
        object cbbtablo_adi: TComboBox
          Left = 138
          Top = 92
          Width = 279
          Height = 21
          TabOrder = 4
        end
        object edtform_adi: TEdit
          Left = 138
          Top = 114
          Width = 279
          Height = 21
          TabOrder = 5
        end
        object chkis_fabrika_ayari: TCheckBox
          Left = 138
          Top = 140
          Width = 279
          Height = 17
          TabOrder = 6
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 201
    Width = 437
    ExplicitTop = 201
    ExplicitWidth = 437
    inherited btnAccept: TButton
      Left = 228
      ExplicitLeft = 228
    end
    inherited btnClose: TButton
      Left = 332
      ExplicitLeft = 332
    end
  end
  inherited stbBase: TStatusBar
    Top = 245
    Width = 441
    ExplicitTop = 245
    ExplicitWidth = 441
  end
end

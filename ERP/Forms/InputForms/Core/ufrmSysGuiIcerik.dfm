inherited frmSysGuiIcerik: TfrmSysGuiIcerik
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem GUI '#304#231'erik'
  ClientHeight = 221
  ClientWidth = 433
  ParentFont = True
  ExplicitWidth = 449
  ExplicitHeight = 260
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 433
    Height = 171
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 433
    ExplicitHeight = 171
    inherited pgcMain: TPageControl
      Width = 433
      Height = 171
      ExplicitWidth = 433
      ExplicitHeight = 171
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 425
        ExplicitHeight = 141
        object lblkod: TLabel
          Left = 111
          Top = 5
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
          Top = 27
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
          Top = 49
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
          Top = 71
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
          Top = 93
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
        object lblis_fabrika: TLabel
          Left = 50
          Top = 117
          Width = 82
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Fabrika De'#287'eri'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtkod: TEdit
          Left = 138
          Top = 2
          Width = 279
          Height = 23
          TabOrder = 0
        end
        object edtdeger: TEdit
          Left = 138
          Top = 24
          Width = 279
          Height = 23
          TabOrder = 1
        end
        object edticerik_tipi: TEdit
          Left = 138
          Top = 46
          Width = 279
          Height = 23
          TabOrder = 2
        end
        object cbbtablo_adi: TComboBox
          Left = 138
          Top = 68
          Width = 279
          Height = 23
          TabOrder = 3
        end
        object edtform_adi: TEdit
          Left = 138
          Top = 90
          Width = 279
          Height = 23
          TabOrder = 4
        end
        object chkis_fabrika: TCheckBox
          Left = 138
          Top = 116
          Width = 279
          Height = 17
          TabOrder = 5
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 173
    Width = 429
    ExplicitTop = 173
    ExplicitWidth = 429
    inherited btnAccept: TButton
      Left = 223
      ExplicitLeft = 223
    end
    inherited btnClose: TButton
      Left = 327
      ExplicitLeft = 327
    end
  end
  inherited stbBase: TStatusBar
    Top = 203
    Width = 433
    ExplicitTop = 203
    ExplicitWidth = 433
  end
end

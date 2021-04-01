inherited frmSysGridFiltreSiralama: TfrmSysGridFiltreSiralama
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem Grid Filtre S'#305'ralama'
  ClientHeight = 166
  ClientWidth = 386
  ParentFont = True
  ExplicitWidth = 392
  ExplicitHeight = 195
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 382
    Height = 114
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 382
    ExplicitHeight = 114
    inherited pgcMain: TPageControl
      Width = 380
      Height = 112
      ExplicitWidth = 380
      ExplicitHeight = 112
      inherited tsMain: TTabSheet
        ExplicitWidth = 372
        ExplicitHeight = 84
        object lbltablo_adi: TLabel
          Left = 27
          Top = 5
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
        object lbldeger: TLabel
          Left = 45
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
        object lblis_siralama: TLabel
          Left = 29
          Top = 49
          Width = 50
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'S'#305'ralama'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbtablo_adi: TComboBox
          Left = 82
          Top = 2
          Width = 287
          Height = 21
          TabOrder = 0
        end
        object edtdeger: TEdit
          Left = 82
          Top = 24
          Width = 287
          Height = 21
          TabOrder = 1
        end
        object chkis_siralama: TCheckBox
          Left = 82
          Top = 48
          Width = 287
          Height = 17
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 118
    Width = 382
    ExplicitTop = 118
    ExplicitWidth = 382
    inherited btnAccept: TButton
      Left = 173
      ExplicitLeft = 173
    end
    inherited btnClose: TButton
      Left = 277
      ExplicitLeft = 277
    end
  end
  inherited stbBase: TStatusBar
    Top = 148
    Width = 386
    ExplicitTop = 148
    ExplicitWidth = 386
  end
end

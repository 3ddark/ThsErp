inherited frmSysGridFilterSort: TfrmSysGridFilterSort
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem Grid Filtre ve S'#305'ralama'
  ClientHeight = 139
  ClientWidth = 380
  ParentFont = True
  ExplicitWidth = 396
  ExplicitHeight = 178
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 380
    Height = 89
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 380
    ExplicitHeight = 89
    inherited pgcMain: TPageControl
      Width = 380
      Height = 89
      ExplicitWidth = 382
      ExplicitHeight = 89
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 372
        ExplicitHeight = 59
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
        object lblicerik: TLabel
          Left = 46
          Top = 27
          Width = 33
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #304#231'erik'
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
          Height = 23
          TabOrder = 0
        end
        object edticerik: TEdit
          Left = 82
          Top = 24
          Width = 287
          Height = 23
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
    Top = 91
    Width = 376
    ExplicitTop = 91
    ExplicitWidth = 376
    inherited btnAccept: TButton
      Left = 170
      ExplicitLeft = 170
    end
    inherited btnClose: TButton
      Left = 274
      ExplicitLeft = 274
    end
  end
  inherited stbBase: TStatusBar
    Top = 121
    Width = 380
    ExplicitTop = 121
    ExplicitWidth = 380
  end
end

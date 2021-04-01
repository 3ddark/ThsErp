inherited frmSysUlke: TfrmSysUlke
  Caption = 'Sistem '#220'lke'
  ClientHeight = 211
  ClientWidth = 392
  ExplicitWidth = 398
  ExplicitHeight = 240
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 388
    Height = 145
    ExplicitWidth = 388
    ExplicitHeight = 145
    inherited pgcMain: TPageControl
      Width = 386
      Height = 143
      ExplicitWidth = 386
      ExplicitHeight = 143
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 378
        ExplicitHeight = 115
        object lblulke_kodu: TLabel
          Left = 72
          Top = 7
          Width = 56
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'lke Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblulke_adi: TLabel
          Left = 82
          Top = 27
          Width = 46
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'lke Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbliso_yil: TLabel
          Left = 115
          Top = 49
          Width = 13
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Y'#305'l'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbliso_cctld_kod: TLabel
          Left = 62
          Top = 71
          Width = 66
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'CCTLD Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_ab_uyesi: TLabel
          Left = 79
          Top = 91
          Width = 49
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'AB '#220'yesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtulke_kodu: TEdit
          Left = 134
          Top = 2
          Width = 234
          Height = 21
          TabOrder = 0
        end
        object edtulke_adi: TEdit
          Left = 134
          Top = 24
          Width = 234
          Height = 21
          TabOrder = 1
        end
        object edtiso_yil: TEdit
          Left = 134
          Top = 46
          Width = 234
          Height = 21
          TabOrder = 2
        end
        object edtiso_cctld_kod: TEdit
          Left = 134
          Top = 68
          Width = 234
          Height = 21
          TabOrder = 3
        end
        object chkis_ab_uyesi: TCheckBox
          Left = 134
          Top = 90
          Width = 234
          Height = 17
          Color = clWindow
          ParentColor = False
          TabOrder = 4
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 149
    Width = 388
    ExplicitTop = 149
    ExplicitWidth = 388
    inherited btnAccept: TButton
      Left = 283
      ExplicitLeft = 283
    end
    inherited btnClose: TButton
      Left = 179
      ExplicitLeft = 179
    end
  end
  inherited stbBase: TStatusBar
    Top = 193
    Width = 392
    ExplicitTop = 193
    ExplicitWidth = 392
  end
end

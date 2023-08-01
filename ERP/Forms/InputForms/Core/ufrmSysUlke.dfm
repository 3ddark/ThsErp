inherited frmSysUlke: TfrmSysUlke
  Caption = 'System Country'
  ClientHeight = 203
  ClientWidth = 388
  ExplicitWidth = 404
  ExplicitHeight = 242
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 388
    Height = 153
    ExplicitWidth = 392
    ExplicitHeight = 161
    inherited pgcMain: TPageControl
      Width = 390
      Height = 157
      ExplicitWidth = 392
      ExplicitHeight = 161
      inherited tsMain: TTabSheet
        ExplicitWidth = 382
        ExplicitHeight = 129
        object lblcode: TLabel
          Left = 100
          Top = 7
          Width = 28
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Code'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcountry: TLabel
          Left = 83
          Top = 27
          Width = 45
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Country'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbliso_year: TLabel
          Left = 102
          Top = 49
          Width = 26
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Year'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbliso_cctld: TLabel
          Left = 62
          Top = 71
          Width = 66
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'CCTLD Code'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_eu_member: TLabel
          Left = 64
          Top = 91
          Width = 64
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'EU Member'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtcode: TEdit
          Left = 134
          Top = 2
          Width = 234
          Height = 21
          TabOrder = 0
        end
        object edtcountry: TEdit
          Left = 134
          Top = 24
          Width = 234
          Height = 21
          TabOrder = 1
        end
        object edtiso_year: TEdit
          Left = 134
          Top = 46
          Width = 234
          Height = 21
          TabOrder = 2
        end
        object edtiso_cctld: TEdit
          Left = 134
          Top = 68
          Width = 234
          Height = 21
          TabOrder = 3
        end
        object chkis_eu_member: TCheckBox
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
    Top = 155
    Width = 384
    ExplicitTop = 163
    ExplicitWidth = 388
    inherited btnAccept: TButton
      Left = 286
      TabOrder = 3
      ExplicitLeft = 286
    end
    inherited btnClose: TButton
      Left = 182
      TabOrder = 2
      ExplicitLeft = 182
    end
  end
  inherited stbBase: TStatusBar
    Top = 185
    Width = 388
    ExplicitTop = 193
    ExplicitWidth = 392
  end
end

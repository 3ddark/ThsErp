inherited frmSysCity: TfrmSysCity
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'System City'
  ClientHeight = 154
  ClientWidth = 370
  ParentFont = True
  ExplicitWidth = 386
  ExplicitHeight = 193
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 370
    Height = 104
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 374
    ExplicitHeight = 112
    inherited pgcMain: TPageControl
      Width = 372
      Height = 108
      ExplicitWidth = 372
      ExplicitHeight = 108
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 364
        ExplicitHeight = 78
        object lblcountry_id: TLabel
          Left = 63
          Top = 6
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
        object lblcity: TLabel
          Left = 86
          Top = 30
          Width = 22
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'City'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcar_plate: TLabel
          Left = 26
          Top = 54
          Width = 82
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Car Plate Code'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtcity: TEdit
          Left = 114
          Top = 26
          Width = 239
          Height = 23
          TabOrder = 1
        end
        object edtcar_plate: TEdit
          Left = 114
          Top = 50
          Width = 239
          Height = 23
          TabOrder = 2
        end
        object edtcountry_id: TEdit
          Left = 114
          Top = 2
          Width = 239
          Height = 23
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 106
    Width = 366
    ExplicitTop = 114
    ExplicitWidth = 370
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
    Top = 136
    Width = 370
    ExplicitTop = 144
    ExplicitWidth = 374
  end
end

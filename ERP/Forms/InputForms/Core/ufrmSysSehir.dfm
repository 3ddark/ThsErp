inherited frmSysSehir: TfrmSysSehir
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'System City'
  ClientHeight = 150
  ClientWidth = 368
  ParentFont = True
  ExplicitWidth = 374
  ExplicitHeight = 179
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 368
    Height = 100
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 368
    ExplicitHeight = 100
    inherited pgcMain: TPageControl
      Width = 368
      Height = 100
      ExplicitWidth = 368
      ExplicitHeight = 100
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 360
        ExplicitHeight = 70
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
    Top = 102
    Width = 364
    ExplicitTop = 102
    ExplicitWidth = 364
    inherited btnAccept: TButton
      Left = 158
      ExplicitLeft = 158
    end
    inherited btnClose: TButton
      Left = 262
      ExplicitLeft = 262
    end
  end
  inherited stbBase: TStatusBar
    Top = 132
    Width = 368
    ExplicitTop = 132
    ExplicitWidth = 368
  end
end

inherited frmSysMukellefTipi: TfrmSysMukellefTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'M'#252'kellef Tipi'
  ClientHeight = 142
  ClientWidth = 368
  ParentFont = True
  ExplicitWidth = 374
  ExplicitHeight = 171
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 364
    Height = 76
    Color = clWindow
    ExplicitWidth = 364
    ExplicitHeight = 88
    inherited pgcMain: TPageControl
      Width = 362
      Height = 74
      ExplicitWidth = 362
      ExplicitHeight = 86
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 354
        ExplicitHeight = 58
        object lblmukellef_tipi: TLabel
          Left = 37
          Top = 5
          Width = 71
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'M'#252'kellef Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_varsayilan: TLabel
          Left = 43
          Top = 25
          Width = 65
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Varsay'#305'lan?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtmukellef_tipi: TEdit
          Left = 110
          Top = 2
          Width = 224
          Height = 21
          TabOrder = 0
        end
        object chkis_varsayilan: TCheckBox
          Left = 110
          Top = 24
          Width = 224
          Height = 17
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 80
    Width = 364
    ExplicitTop = 92
    ExplicitWidth = 364
    inherited btnAccept: TButton
      Left = 155
      ExplicitLeft = 155
    end
    inherited btnClose: TButton
      Left = 259
      ExplicitLeft = 259
    end
  end
  inherited stbBase: TStatusBar
    Top = 124
    Width = 368
    ExplicitTop = 136
    ExplicitWidth = 368
  end
end

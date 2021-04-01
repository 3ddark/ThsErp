inherited frmSetStkUrunTipi: TfrmSetStkUrunTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = #220'r'#252'n Tipi'
  ClientHeight = 174
  ClientWidth = 356
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 362
  ExplicitHeight = 203
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 352
    Height = 122
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 352
    ExplicitHeight = 73
    inherited pgcMain: TPageControl
      Width = 350
      Height = 120
      ExplicitWidth = 350
      ExplicitHeight = 71
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 342
        ExplicitHeight = 43
        object lblurun_tipi: TLabel
          Left = 83
          Top = 6
          Width = 53
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #220'r'#252'n Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_hammadde: TLabel
          Left = 73
          Top = 28
          Width = 63
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Hammadde'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_yari_mamul: TLabel
          Left = 73
          Top = 48
          Width = 63
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yar'#305' Mam'#252'l'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_mamul: TLabel
          Left = 99
          Top = 68
          Width = 37
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mam'#252'l'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edturun_tipi: TEdit
          Left = 140
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object chkis_hammadde: TCheckBox
          Left = 140
          Top = 27
          Width = 200
          Height = 17
          TabOrder = 1
        end
        object chkis_yari_mamul: TCheckBox
          Left = 140
          Top = 47
          Width = 200
          Height = 17
          TabOrder = 2
        end
        object chkis_mamul: TCheckBox
          Left = 140
          Top = 67
          Width = 200
          Height = 17
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 126
    Width = 352
    ExplicitTop = 77
    ExplicitWidth = 352
    inherited btnAccept: TButton
      Left = 143
      ExplicitLeft = 143
      ExplicitHeight = 22
    end
    inherited btnDelete: TButton
      ExplicitLeft = 20
      ExplicitHeight = 22
    end
    inherited btnClose: TButton
      Left = 247
      ExplicitLeft = 247
      ExplicitHeight = 22
    end
  end
  inherited stbBase: TStatusBar
    Top = 156
    Width = 356
    ExplicitTop = 107
    ExplicitWidth = 356
  end
end

inherited frmStkStokGrubuTuru: TfrmStkStokGrubuTuru
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Stok Grubu T'#252'r'#252
  ClientHeight = 121
  ClientWidth = 344
  Font.Charset = TURKISH_CHARSET
  ExplicitWidth = 350
  ExplicitHeight = 150
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 55
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 55
    inherited pgcMain: TPageControl
      Width = 338
      Height = 53
      ExplicitWidth = 338
      ExplicitHeight = 53
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 330
        ExplicitHeight = 25
        object lblstok_grubu_tur: TLabel
          Left = 18
          Top = 6
          Width = 92
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Stok Grubu T'#252'r'#252
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtstok_grubu_tur: TEdit
          Left = 113
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 59
    Width = 340
    ExplicitTop = 59
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      ExplicitLeft = 131
    end
    inherited btnClose: TButton
      Left = 235
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 103
    Width = 344
    ExplicitTop = 103
    ExplicitWidth = 344
  end
end

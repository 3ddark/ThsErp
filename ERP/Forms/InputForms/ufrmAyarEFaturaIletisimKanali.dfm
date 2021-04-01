inherited frmAyarEFaturaIletisimKanali: TfrmAyarEFaturaIletisimKanali
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ayar E-Fatura '#304'letisim Kanal'#305
  ClientHeight = 150
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 179
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 98
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 98
    inherited pgcMain: TPageControl
      Width = 338
      Height = 96
      ExplicitWidth = 338
      ExplicitHeight = 96
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 68
        object lblAciklama: TLabel
          Left = 36
          Top = 28
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'A'#231#305'klama'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblKod: TLabel
          Left = 65
          Top = 6
          Width = 23
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kod'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtAciklama: TEdit
          Left = 92
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtKod: TEdit
          Left = 92
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 102
    Width = 340
    ExplicitTop = 102
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
    Top = 132
    Width = 344
    ExplicitTop = 132
    ExplicitWidth = 344
  end
end

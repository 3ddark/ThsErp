inherited frmSetEinvPaketTipi: TfrmSetEinvPaketTipi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Paket Tipi'
  ClientHeight = 195
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 360
  ExplicitHeight = 234
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 344
    Height = 145
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 342
    ExplicitHeight = 137
    inherited pgcMain: TPageControl
      Width = 344
      Height = 145
      ExplicitWidth = 342
      ExplicitHeight = 137
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 117
        object lblpaket_adi: TLabel
          Left = 59
          Top = 49
          Width = 56
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Paket Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkod: TLabel
          Left = 92
          Top = 27
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
        object lblaciklama: TLabel
          Left = 63
          Top = 71
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
        object edtkod: TEdit
          Left = 119
          Top = 24
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtpaket_adi: TEdit
          Left = 119
          Top = 46
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtaciklama: TEdit
          Left = 119
          Top = 68
          Width = 200
          Height = 21
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 147
    Width = 340
    ExplicitTop = 139
    ExplicitWidth = 338
    inherited btnAccept: TButton
      Left = 134
      ExplicitLeft = 132
    end
    inherited btnClose: TButton
      Left = 238
      ExplicitLeft = 236
    end
  end
  inherited stbBase: TStatusBar
    Top = 177
    Width = 344
    ExplicitTop = 169
    ExplicitWidth = 342
  end
end

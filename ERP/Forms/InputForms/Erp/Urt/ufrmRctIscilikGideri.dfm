inherited frmRctIscilikGideri: TfrmRctIscilikGideri
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'I'#351#231'ilik Gideri'
  ClientHeight = 212
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 350
  ExplicitHeight = 241
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 160
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 146
    inherited pgcMain: TPageControl
      Width = 338
      Height = 158
      ExplicitWidth = 338
      ExplicitHeight = 144
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 130
        object lblgider_kodu: TLabel
          Left = 38
          Top = 5
          Width = 64
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Gider Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgider_adi: TLabel
          Left = 49
          Top = 27
          Width = 53
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Gider Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblfiyat: TLabel
          Left = 74
          Top = 49
          Width = 28
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Fiyat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblolcu_birimi_id: TLabel
          Left = 41
          Top = 71
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblgider_tipi_id: TLabel
          Left = 46
          Top = 93
          Width = 56
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Gider Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtgider_kodu: TEdit
          Left = 106
          Top = 2
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtgider_adi: TEdit
          Left = 106
          Top = 24
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtfiyat: TEdit
          Left = 106
          Top = 46
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object cbbolcu_birimi_id: TComboBox
          Left = 106
          Top = 68
          Width = 200
          Height = 21
          TabOrder = 3
          Text = 'cbbolcu_birimi_id'
        end
        object cbbgider_tipi_id: TComboBox
          Left = 106
          Top = 90
          Width = 200
          Height = 21
          TabOrder = 4
          Text = 'ComboBox1'
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 164
    Width = 340
    ExplicitTop = 150
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
    Top = 194
    Width = 344
    ExplicitTop = 194
    ExplicitWidth = 344
  end
end

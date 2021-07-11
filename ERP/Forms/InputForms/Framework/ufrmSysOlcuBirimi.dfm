inherited frmSysOlcuBirimi: TfrmSysOlcuBirimi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem '#214'l'#231#252' Birimi'
  ClientHeight = 226
  ClientWidth = 344
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 350
  ExplicitHeight = 255
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 174
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 155
    inherited pgcMain: TPageControl
      Width = 338
      Height = 172
      ExplicitWidth = 338
      ExplicitHeight = 153
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 125
        object lblolcu_birimi: TLabel
          Left = 54
          Top = 6
          Width = 59
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblolcu_birimi_einv: TLabel
          Left = 22
          Top = 28
          Width = 91
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi E-Fat'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblaciklama: TLabel
          Left = 61
          Top = 50
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'A'#231#305'klama'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_ondalik: TLabel
          Left = 65
          Top = 72
          Width = 48
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ondal'#305'k?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblolcu_birimi_tipi_id: TLabel
          Left = 31
          Top = 98
          Width = 82
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #214'l'#231#252' Birimi Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblcarpan: TLabel
          Left = 73
          Top = 120
          Width = 40
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #199'arpan'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtolcu_birimi: TEdit
          Left = 117
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtolcu_birimi_einv: TEdit
          Left = 117
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtaciklama: TEdit
          Left = 117
          Top = 47
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object chkis_ondalik: TCheckBox
          Left = 117
          Top = 72
          Width = 200
          Height = 17
          TabOrder = 3
        end
        object edtolcu_birimi_tipi_id: TEdit
          Left = 117
          Top = 95
          Width = 200
          Height = 21
          TabOrder = 4
        end
        object edtcarpan: TEdit
          Left = 117
          Top = 117
          Width = 200
          Height = 21
          TabOrder = 5
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 178
    Width = 340
    ExplicitTop = 159
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      TabOrder = 2
      ExplicitLeft = 131
    end
    inherited btnClose: TButton
      Left = 235
      TabOrder = 3
      ExplicitLeft = 235
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 208
    Width = 344
    ExplicitTop = 189
    ExplicitWidth = 344
  end
end

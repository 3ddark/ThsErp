inherited frmUtdDokuman: TfrmUtdDokuman
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'UTD Dok'#252'man'
  ClientHeight = 188
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 217
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 136
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 122
    inherited pgcMain: TPageControl
      Width = 338
      Height = 134
      ExplicitWidth = 338
      ExplicitHeight = 120
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 92
        object lblsiparis_no: TLabel
          Left = 90
          Top = 5
          Width = 59
          Height = 13
          Alignment = taRightJustify
          Caption = 'Sipari'#351' No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lbldokuman_tipi_id: TLabel
          Left = 70
          Top = 27
          Width = 79
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Dok'#252'man Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lbldosya_adi_val: TLabel
          Left = 195
          Top = 51
          Width = 104
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Se'#231'ilen Dosya Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtsiparis_no: TEdit
          Left = 154
          Top = 2
          Width = 145
          Height = 21
          TabOrder = 0
        end
        object cbbdokuman_tipi_id: TComboBox
          Left = 154
          Top = 24
          Width = 145
          Height = 21
          Style = csDropDownList
          TabOrder = 1
        end
        object btndosya_sec: TButton
          Left = 300
          Top = 24
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 2
          OnClick = btndosya_secClick
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 140
    Width = 340
    ExplicitTop = 126
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      Caption = 'KAYDET'
      ExplicitLeft = 131
    end
    inherited btnClose: TButton
      Left = 235
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 170
    Width = 344
    ExplicitTop = 170
    ExplicitWidth = 344
  end
  inherited AppEvntsBase: TApplicationEvents
    Left = 376
    Top = 40
  end
  inherited dlgPntBase: TPrintDialog
    Left = 464
    Top = 40
  end
  inherited pmLabels: TPopupMenu
    Left = 400
    Top = 88
  end
  object dlgDosyaSec: TOpenTextFileDialog
    Left = 471
    Top = 107
  end
end

inherited frmSetPrsGecisSistemiKarti: TfrmSetPrsGecisSistemiKarti
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel PDKS Kart'
  ClientHeight = 191
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 220
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 125
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 125
    inherited pgcMain: TPageControl
      Width = 338
      Height = 123
      ExplicitWidth = 338
      ExplicitHeight = 123
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 330
        ExplicitHeight = 95
        object lblis_aktif: TLabel
          Left = 70
          Top = 72
          Width = 34
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Aktif?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkart_id: TLabel
          Left = 63
          Top = 6
          Width = 41
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kart ID'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkart_no: TLabel
          Left = 60
          Top = 50
          Width = 44
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Kart No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblpersonel_no: TLabel
          Left = 34
          Top = 28
          Width = 70
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Personel No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbbkart_no: TComboBox
          Left = 108
          Top = 47
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object chkis_aktif: TCheckBox
          Left = 108
          Top = 72
          Width = 200
          Height = 17
          TabOrder = 1
        end
        object edtkart_id: TEdit
          Left = 108
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object edtpersonel_no: TEdit
          Left = 108
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 129
    Width = 340
    ExplicitTop = 129
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
    Top = 173
    Width = 344
    ExplicitTop = 173
    ExplicitWidth = 344
  end
end

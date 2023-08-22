inherited frmPrsLisanBilgisi: TfrmPrsLisanBilgisi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Lisan Bilgisi'
  ClientHeight = 209
  ClientWidth = 421
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 435
  ExplicitHeight = 245
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 421
    Height = 159
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 419
    ExplicitHeight = 156
    inherited pgcMain: TPageControl
      Width = 421
      Height = 159
      ExplicitWidth = 419
      ExplicitHeight = 156
      inherited tsMain: TTabSheet
        ExplicitWidth = 413
        ExplicitHeight = 131
        object lbllisan_id: TLabel
          Left = 105
          Top = 6
          Width = 31
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Lisan'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblokuma_seviyesi_id: TLabel
          Left = 45
          Top = 28
          Width = 91
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Okuma Seviyesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblyazma_seviyesi_id: TLabel
          Left = 47
          Top = 50
          Width = 89
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yazma Seviyesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblkonusma_seviyesi_id: TLabel
          Left = 33
          Top = 72
          Width = 103
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Konu'#351'ma Seviyesi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblpersonel_id: TLabel
          Left = 86
          Top = 94
          Width = 50
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Personel'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object cbblisan_id: TComboBox
          Left = 140
          Top = 3
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 0
        end
        object cbbokuma_seviyesi_id: TComboBox
          Left = 140
          Top = 25
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 1
        end
        object cbbyazma_seviyesi_id: TComboBox
          Left = 140
          Top = 47
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 2
        end
        object cbbkonusma_seviyesi_id: TComboBox
          Left = 140
          Top = 69
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 3
        end
        object cbbpersonel_id: TComboBox
          Left = 140
          Top = 91
          Width = 200
          Height = 21
          AutoCloseUp = True
          TabOrder = 4
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 161
    Width = 417
    ExplicitTop = 158
    ExplicitWidth = 415
    inherited btnAccept: TButton
      Left = 211
      ExplicitLeft = 209
    end
    inherited btnClose: TButton
      Left = 315
      ExplicitLeft = 313
    end
  end
  inherited stbBase: TStatusBar
    Top = 191
    Width = 421
    ExplicitTop = 188
    ExplicitWidth = 419
  end
end

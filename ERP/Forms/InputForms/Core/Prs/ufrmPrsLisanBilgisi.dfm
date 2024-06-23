inherited frmPrsLisanBilgisi: TfrmPrsLisanBilgisi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Personel Lisan Bilgisi'
  ClientHeight = 200
  ClientWidth = 378
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 394
  ExplicitHeight = 239
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 378
    Height = 150
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 378
    ExplicitHeight = 150
    inherited pgcMain: TPageControl
      Width = 378
      Height = 150
      ExplicitWidth = 378
      ExplicitHeight = 150
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 370
        ExplicitHeight = 121
        object lbllisan_id: TLabel
          Left = 106
          Top = 6
          Width = 30
          Height = 14
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
          Left = 48
          Top = 28
          Width = 88
          Height = 14
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
          Left = 52
          Top = 50
          Width = 84
          Height = 14
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
          Left = 35
          Top = 72
          Width = 101
          Height = 14
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
          Height = 14
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
          Style = csDropDownList
          TabOrder = 0
        end
        object cbbokuma_seviyesi_id: TComboBox
          Left = 140
          Top = 25
          Width = 200
          Height = 21
          AutoCloseUp = True
          Style = csDropDownList
          TabOrder = 1
        end
        object cbbyazma_seviyesi_id: TComboBox
          Left = 140
          Top = 47
          Width = 200
          Height = 21
          AutoCloseUp = True
          Style = csDropDownList
          TabOrder = 2
        end
        object cbbkonusma_seviyesi_id: TComboBox
          Left = 140
          Top = 69
          Width = 200
          Height = 21
          AutoCloseUp = True
          Style = csDropDownList
          TabOrder = 3
        end
        object edtpersonel_id: TEdit
          Left = 140
          Top = 91
          Width = 200
          Height = 21
          TabOrder = 4
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 152
    Width = 374
    ExplicitTop = 152
    ExplicitWidth = 374
    inherited btnAccept: TButton
      Left = 168
      ExplicitLeft = 168
    end
    inherited btnClose: TButton
      Left = 272
      ExplicitLeft = 272
    end
  end
  inherited stbBase: TStatusBar
    Top = 182
    Width = 378
    ExplicitTop = 182
    ExplicitWidth = 378
  end
end

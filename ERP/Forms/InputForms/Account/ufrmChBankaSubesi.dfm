inherited frmChBankaSubesi: TfrmChBankaSubesi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Banka '#350'ubeleri'
  ClientHeight = 176
  ClientWidth = 336
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 352
  ExplicitHeight = 215
  TextHeight = 14
  inherited pnlMain: TPanel
    Width = 336
    Height = 126
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 334
    ExplicitHeight = 107
    inherited pgcMain: TPageControl
      Width = 336
      Height = 126
      ExplicitWidth = 334
      ExplicitHeight = 107
      inherited tsMain: TTabSheet
        ExplicitTop = 25
        ExplicitWidth = 328
        ExplicitHeight = 97
        object lblbanka_id: TLabel
          Left = 65
          Top = 6
          Width = 33
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Banka'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsube_kodu: TLabel
          Left = 39
          Top = 28
          Width = 59
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #350'ube Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsube_adi: TLabel
          Left = 49
          Top = 50
          Width = 49
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #350'ube Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblsehir_id: TLabel
          Left = 69
          Top = 72
          Width = 29
          Height = 14
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #350'ehir'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtsube_kodu: TEdit
          Left = 102
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtsube_adi: TEdit
          Left = 102
          Top = 47
          Width = 200
          Height = 21
          TabOrder = 2
        end
        object edtbanka_id: TEdit
          Left = 102
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtsehir_id: TEdit
          Left = 102
          Top = 69
          Width = 200
          Height = 21
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 128
    Width = 332
    ExplicitTop = 109
    ExplicitWidth = 330
    inherited btnAccept: TButton
      Left = 126
      ExplicitLeft = 124
    end
    inherited btnClose: TButton
      Left = 230
      ExplicitLeft = 228
    end
  end
  inherited stbBase: TStatusBar
    Top = 158
    Width = 336
    ExplicitTop = 139
    ExplicitWidth = 334
  end
end

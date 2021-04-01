inherited frmChBankaSubesi: TfrmChBankaSubesi
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Banka '#350'ubeleri'
  ClientHeight = 192
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  Position = poDesktopCenter
  ExplicitWidth = 350
  ExplicitHeight = 221
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 140
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 340
    ExplicitHeight = 140
    inherited pgcMain: TPageControl
      Width = 338
      Height = 138
      ExplicitWidth = 338
      ExplicitHeight = 138
      inherited tsMain: TTabSheet
        ExplicitWidth = 330
        ExplicitHeight = 110
        object lblbanka_id: TLabel
          Left = 61
          Top = 6
          Width = 37
          Height = 13
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
          Left = 35
          Top = 28
          Width = 63
          Height = 13
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
          Left = 46
          Top = 50
          Width = 52
          Height = 13
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
        object lblsube_il_id: TLabel
          Left = 57
          Top = 72
          Width = 41
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #350'ube '#304'l'
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
        object edtsube_il_id: TEdit
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
    Top = 144
    Width = 340
    ExplicitTop = 144
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      TabOrder = 2
      ExplicitLeft = 131
    end
    inherited btnClose: TButton
      Left = 235
      ExplicitLeft = 235
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 174
    Width = 344
    ExplicitTop = 174
    ExplicitWidth = 344
  end
end

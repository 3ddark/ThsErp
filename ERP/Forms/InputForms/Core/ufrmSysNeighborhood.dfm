inherited frmSysMahalle: TfrmSysMahalle
  ActiveControl = btnClose
  Caption = 'Sys Mahalle'
  ClientHeight = 153
  ClientWidth = 344
  ExplicitWidth = 360
  ExplicitHeight = 192
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 344
    Height = 103
    ExplicitWidth = 340
    ExplicitHeight = 93
    inherited pgcMain: TPageControl
      Width = 344
      Height = 103
      ExplicitWidth = 338
      ExplicitHeight = 91
      inherited tsMain: TTabSheet
        ExplicitWidth = 336
        ExplicitHeight = 75
        object lblmahalle_adi: TLabel
          Left = 37
          Top = 6
          Width = 65
          Height = 13
          Alignment = taRightJustify
          Caption = 'Mahalle Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblposta_kodu: TLabel
          Left = 39
          Top = 28
          Width = 63
          Height = 13
          Alignment = taRightJustify
          Caption = 'Posta Kodu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblsemt_id: TLabel
          Left = 51
          Top = 50
          Width = 51
          Height = 13
          Alignment = taRightJustify
          Caption = 'Semt Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtmahalle_adi: TEdit
          Left = 106
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtposta_kodu: TEdit
          Left = 106
          Top = 25
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtsemt_id: TEdit
          Left = 106
          Top = 47
          Width = 200
          Height = 21
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 105
    Width = 340
    ExplicitTop = 97
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
    Top = 135
    Width = 344
    ExplicitTop = 127
    ExplicitWidth = 344
  end
end

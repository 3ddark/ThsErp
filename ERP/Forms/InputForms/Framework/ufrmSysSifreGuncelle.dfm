inherited frmSysSifreGuncelle: TfrmSysSifreGuncelle
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Kullan'#305'c'#305' '#350'ifre G'#252'ncelleme'
  ClientHeight = 174
  ClientWidth = 409
  ParentFont = True
  ExplicitWidth = 425
  ExplicitHeight = 213
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 405
    Height = 108
    Color = clWindow
    ExplicitWidth = 405
    ExplicitHeight = 108
    inherited pgcMain: TPageControl
      Width = 403
      Height = 106
      ExplicitWidth = 403
      ExplicitHeight = 106
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 395
        ExplicitHeight = 78
        object lblold_password: TLabel
          Left = 98
          Top = 10
          Width = 42
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = #350'ifreniz'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblnew_password: TLabel
          Left = 87
          Top = 32
          Width = 53
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yeni '#350'ifre'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblnew_password2: TLabel
          Left = 39
          Top = 54
          Width = 101
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yeni '#350'ifre(Tekrar)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtold_password: TEdit
          Left = 146
          Top = 7
          Width = 239
          Height = 21
          PasswordChar = '*'
          TabOrder = 0
        end
        object edtnew_password: TEdit
          Left = 146
          Top = 29
          Width = 239
          Height = 21
          MaxLength = 32
          TabOrder = 1
        end
        object edtnew_password2: TEdit
          Left = 146
          Top = 51
          Width = 239
          Height = 21
          MaxLength = 32
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 112
    Width = 405
    ExplicitTop = 112
    ExplicitWidth = 405
    inherited btnAccept: TButton
      Left = 196
      ExplicitLeft = 196
    end
    inherited btnClose: TButton
      Left = 300
      ExplicitLeft = 300
    end
  end
  inherited stbBase: TStatusBar
    Top = 156
    Width = 409
    ExplicitTop = 156
    ExplicitWidth = 409
  end
end

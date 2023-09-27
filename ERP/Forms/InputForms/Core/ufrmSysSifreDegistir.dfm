inherited frmSysChangePassword: TfrmSysChangePassword
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = #350'ifreyi G'#252'ncelle'
  ClientHeight = 158
  ClientWidth = 401
  ParentFont = True
  ExplicitWidth = 415
  ExplicitHeight = 194
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 401
    Height = 108
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 399
    ExplicitHeight = 105
    inherited pgcMain: TPageControl
      Width = 401
      Height = 108
      ExplicitWidth = 401
      ExplicitHeight = 108
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 393
        ExplicitHeight = 78
        object lblmevcut_sifre: TLabel
          Left = 53
          Top = 11
          Width = 87
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Mevcut '#350'ifreniz'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblyeni_sifre: TLabel
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
        object lblyeni_sifre2: TLabel
          Left = 46
          Top = 54
          Width = 94
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Yeni '#350'ifre Tekrar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtmevcut_sifre: TEdit
          Left = 146
          Top = 7
          Width = 239
          Height = 23
          PasswordChar = '*'
          TabOrder = 0
        end
        object edtyeni_sifre: TEdit
          Left = 146
          Top = 29
          Width = 239
          Height = 23
          MaxLength = 32
          TabOrder = 1
        end
        object edtyeni_sifre2: TEdit
          Left = 146
          Top = 51
          Width = 239
          Height = 23
          MaxLength = 32
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 110
    Width = 397
    ExplicitTop = 107
    ExplicitWidth = 395
    inherited btnAccept: TButton
      Left = 191
      ExplicitLeft = 189
    end
    inherited btnClose: TButton
      Left = 295
      ExplicitLeft = 293
    end
  end
  inherited stbBase: TStatusBar
    Top = 140
    Width = 401
    ExplicitTop = 137
    ExplicitWidth = 399
  end
end

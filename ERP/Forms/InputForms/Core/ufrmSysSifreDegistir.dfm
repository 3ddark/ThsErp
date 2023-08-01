inherited frmSysChangePassword: TfrmSysChangePassword
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Update User Password'
  ClientHeight = 158
  ClientWidth = 401
  ParentFont = True
  ExplicitWidth = 417
  ExplicitHeight = 197
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 401
    Height = 108
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 401
    ExplicitHeight = 108
    inherited pgcMain: TPageControl
      Width = 401
      Height = 108
      ExplicitWidth = 401
      ExplicitHeight = 108
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 393
        ExplicitHeight = 78
        object lblold_password: TLabel
          Left = 86
          Top = 10
          Width = 54
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Password'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblnew_password: TLabel
          Left = 60
          Top = 32
          Width = 80
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'New Password'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblnew_password2: TLabel
          Left = 25
          Top = 54
          Width = 115
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'New Password Again'
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
          Height = 23
          PasswordChar = '*'
          TabOrder = 0
        end
        object edtnew_password: TEdit
          Left = 146
          Top = 29
          Width = 239
          Height = 23
          MaxLength = 32
          TabOrder = 1
        end
        object edtnew_password2: TEdit
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
    ExplicitTop = 110
    ExplicitWidth = 397
    inherited btnAccept: TButton
      Left = 191
      ExplicitLeft = 191
    end
    inherited btnClose: TButton
      Left = 295
      ExplicitLeft = 295
    end
  end
  inherited stbBase: TStatusBar
    Top = 140
    Width = 401
    ExplicitTop = 140
    ExplicitWidth = 401
  end
end

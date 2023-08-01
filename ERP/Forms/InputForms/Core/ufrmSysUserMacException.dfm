inherited frmSysUserMacException: TfrmSysUserMacException
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Mac Address Exception User'
  ClientHeight = 146
  ClientWidth = 374
  ParentFont = True
  Position = poDesktopCenter
  ExplicitWidth = 380
  ExplicitHeight = 175
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 370
    Height = 80
    Color = clWindow
    ExplicitWidth = 370
    ExplicitHeight = 80
    inherited pgcMain: TPageControl
      Width = 368
      Height = 78
      ExplicitWidth = 368
      ExplicitHeight = 78
      inherited tsMain: TTabSheet
        ExplicitWidth = 360
        ExplicitHeight = 50
        object lbluser_name_id: TLabel
          Left = 61
          Top = 6
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'User Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblip_address: TLabel
          Left = 61
          Top = 28
          Width = 61
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ip Address'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtuser_name_id: TEdit
          Left = 126
          Top = 3
          Width = 224
          Height = 21
          TabOrder = 0
        end
        object edtip_address: TEdit
          Left = 126
          Top = 25
          Width = 224
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 84
    Width = 370
    ExplicitTop = 84
    ExplicitWidth = 370
    inherited btnAccept: TButton
      Left = 161
      ExplicitLeft = 161
    end
    inherited btnClose: TButton
      Left = 265
      ExplicitLeft = 265
    end
  end
  inherited stbBase: TStatusBar
    Top = 128
    Width = 374
    ExplicitTop = 128
    ExplicitWidth = 374
  end
end

inherited frmSysAy: TfrmSysAy
  Left = 501
  Top = 443
  Caption = 'System Month'
  ClientHeight = 111
  ClientWidth = 340
  Font.Charset = TURKISH_CHARSET
  ExplicitWidth = 356
  ExplicitHeight = 150
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 61
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 344
    ExplicitHeight = 61
    inherited pgcMain: TPageControl
      Width = 342
      Height = 65
      ExplicitWidth = 344
      ExplicitHeight = 61
      inherited tsMain: TTabSheet
        ExplicitWidth = 334
        ExplicitHeight = 37
        object lblmonth: TLabel
          Left = 76
          Top = 5
          Width = 36
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Month'
          Font.Charset = TURKISH_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtmonth: TEdit
          Left = 114
          Top = 2
          Width = 200
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 63
    Width = 336
    ExplicitTop = 63
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 134
      ExplicitLeft = 134
    end
    inherited btnClose: TButton
      Left = 238
      ExplicitLeft = 238
    end
  end
  inherited stbBase: TStatusBar
    Top = 93
    Width = 340
    ExplicitTop = 93
    ExplicitWidth = 344
  end
end

inherited frmSysKaliteFormNo: TfrmSysKaliteFormNo
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Sistem Kalite Form No'
  ClientHeight = 165
  ClientWidth = 344
  ParentFont = True
  ExplicitWidth = 350
  ExplicitHeight = 194
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 99
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 99
    inherited pgcMain: TPageControl
      Width = 338
      Height = 97
      ExplicitWidth = 338
      ExplicitHeight = 97
      inherited tsMain: TTabSheet
        ExplicitLeft = 4
        ExplicitTop = 24
        ExplicitWidth = 330
        ExplicitHeight = 69
        object lbltablo_adi: TLabel
          Left = 49
          Top = 5
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Tablo Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblform_no: TLabel
          Left = 55
          Top = 27
          Width = 46
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Form No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblform_tipi_id: TLabel
          Left = 49
          Top = 49
          Width = 52
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Form Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edttablo_adi: TEdit
          Left = 105
          Top = 2
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object edtform_no: TEdit
          Left = 105
          Top = 24
          Width = 200
          Height = 21
          TabOrder = 1
        end
        object edtform_tipi_id: TEdit
          Left = 105
          Top = 46
          Width = 200
          Height = 21
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 103
    Width = 340
    ExplicitTop = 103
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
    Top = 147
    Width = 344
    ExplicitTop = 147
    ExplicitWidth = 344
  end
end

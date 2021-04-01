inherited frmBbkFuarKatilim: TfrmBbkFuarKatilim
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Bilgi Bankas'#305' Fuar Kay'#305't'
  ClientHeight = 151
  ClientWidth = 344
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 350
  ExplicitHeight = 180
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 340
    Height = 93
    Color = clWindow
    ExplicitWidth = 340
    ExplicitHeight = 66
    inherited pgcMain: TPageControl
      Width = 338
      Height = 91
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 338
      ExplicitHeight = 64
      inherited tsMain: TTabSheet
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 330
        ExplicitHeight = 36
        object lblkayit_id: TLabel
          Left = 97
          Top = 6
          Width = 29
          Height = 13
          Alignment = taRightJustify
          Caption = 'Kay'#305't'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblfuar_id: TLabel
          Left = 72
          Top = 30
          Width = 54
          Height = 13
          Alignment = taRightJustify
          Caption = 'Kay'#305't Tipi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtkayit_id: TEdit
          Left = 126
          Top = 3
          Width = 145
          Height = 21
          TabOrder = 0
        end
        object edtfuar_id: TEdit
          Left = 126
          Top = 30
          Width = 145
          Height = 21
          TabOrder = 1
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 97
    Width = 340
    ExplicitTop = 70
    ExplicitWidth = 340
    inherited btnAccept: TButton
      Left = 131
      Caption = 'KAYDET'
      ExplicitLeft = 131
    end
    inherited btnDelete: TButton
      Caption = 'S'#304'L'
    end
    inherited btnClose: TButton
      Left = 235
      Caption = 'KAPAT'
      ExplicitLeft = 235
    end
  end
  inherited stbBase: TStatusBar
    Top = 141
    Width = 344
    Height = 10
    ExplicitTop = 147
    ExplicitWidth = 342
    ExplicitHeight = 10
  end
  inherited AppEvntsBase: TApplicationEvents
    Left = 376
    Top = 40
  end
  inherited dlgPntBase: TPrintDialog
    Left = 464
    Top = 40
  end
  inherited pmLabels: TPopupMenu
    Left = 400
    Top = 88
  end
end

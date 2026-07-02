inherited frmAccHesapPlani: TfrmAccHesapPlani
  Caption = 'Hesap Plani'
  ClientWidth = 500
  ClientHeight = 166
  ExplicitClientWidth = 500
  ExplicitClientHeight = 166
  TextHeight = 14
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 166
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 500
    ExplicitHeight = 166
    object lblcode: TLabel
      Left = 70
      Top = 6
      Width = 24
      Height = 14
      Alignment = taRightJustify
      Caption = 'Kod'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtcode: TEdit
      Left = 132
      Top = 2
      Width = 200
      Height = 21
      TabOrder = 0
    end
    object lblname: TLabel
      Left = 84
      Top = 29
      Width = 16
      Height = 14
      Alignment = taRightJustify
      Caption = 'Ad'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtname: TEdit
      Left = 132
      Top = 25
      Width = 200
      Height = 21
      TabOrder = 1
    end
    object lbllevel: TLabel
      Left = 80
      Top = 52
      Width = 28
      Height = 14
      Alignment = taRightJustify
      Caption = 'Seviye'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtlevel: TSpinEdit
      Left = 132
      Top = 48
      Width = 60
      Height = 21
      MaxValue = 9999
      MinValue = 0
      TabOrder = 2
      Value = 0
    end
  end
end

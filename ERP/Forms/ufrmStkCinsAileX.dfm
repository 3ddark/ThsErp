object frmStkCinsAileX: TfrmStkCinsAileX
  Left = 0
  Top = 0
  Caption = 'frmStkCinsAileX'
  ClientHeight = 66
  ClientWidth = 315
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pgcMain: TPageControl
    Left = 0
    Top = 0
    Width = 315
    Height = 66
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    TabStop = False
    object tsMain: TTabSheet
      Caption = 'Genel'
      object lblaile: TLabel
        Left = 66
        Top = 6
        Width = 22
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Aile'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtaile: TEdit
        Left = 92
        Top = 3
        Width = 200
        Height = 23
        TabOrder = 0
      end
    end
  end
end

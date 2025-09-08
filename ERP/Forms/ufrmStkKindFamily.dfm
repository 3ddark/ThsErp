object frmStkKindFamily: TfrmStkKindFamily
  Left = 0
  Top = 0
  Caption = 'frmStkKindFamily'
  ClientHeight = 189
  ClientWidth = 463
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
    Width = 463
    Height = 189
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    TabStop = False
    ExplicitWidth = 315
    ExplicitHeight = 66
    object tsMain: TTabSheet
      Caption = 'Genel'
      object lblaile: TLabel
        Left = 52
        Top = 7
        Width = 36
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Family'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lbldescription: TLabel
        Left = 21
        Top = 36
        Width = 65
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Description'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object lblactive: TLabel
        Left = 51
        Top = 128
        Width = 37
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Active'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtfamily: TEdit
        Left = 92
        Top = 3
        Width = 333
        Height = 23
        TabOrder = 0
      end
    end
  end
  object mmodescription: TMemo
    Left = 96
    Top = 58
    Width = 333
    Height = 89
    Lines.Strings = (
      'mmodescription')
    TabOrder = 1
  end
  object chkactive: TCheckBox
    Left = 96
    Top = 153
    Width = 97
    Height = 17
    Caption = 'chkactive'
    TabOrder = 2
  end
end

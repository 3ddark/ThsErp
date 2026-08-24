object frmStkProductType: TfrmStkProductType
  Left = 0
  Top = 0
  Caption = 'frmStkProductType'
  ClientHeight = 232
  ClientWidth = 463
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pgcMain: TPageControl
    Left = 0
    Top = 0
    Width = 463
    Height = 232
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    TabStop = False
    ExplicitWidth = 459
    ExplicitHeight = 222
    object tsMain: TTabSheet
      Caption = 'Genel'
      object lblProductName
        Left = 37
        Top = 10
        Width = 84
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Product Type Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtProductName
        Left = 127
        Top = 6
        Width = 300
        Height = 23
        TabOrder = 0
      end
      object lbldescription
        Left = 45
        Top = 40
        Width = 76
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Description'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtDescription
        Left = 127
        Top = 36
        Width = 300
        Height = 23
        TabOrder = 1
      end
      object lblactive
        Left = 54
        Top = 75
        Width = 67
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Active'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object chkActive
        Left = 127
        Top = 72
        Width = 97
        Height = 17
        TabOrder = 2
      end
    end
  end
end

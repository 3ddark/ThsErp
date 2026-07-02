object frmStkGroup: TfrmStkGroup
  Left = 0
  Top = 0
  Caption = 'frmStkGroup'
  ClientHeight = 280
  ClientWidth = 500
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
    Width = 500
    Height = 280
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    TabStop = False
    ExplicitWidth = 496
    ExplicitHeight = 270
    object tsMain: TTabSheet
      Caption = 'Genel'
     object lblGroupName
        Left = 56
        Top = 10
        Width = 68
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Group Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtGroupName
        Left = 130
        Top = 6
        Width = 340
        Height = 23
        TabOrder = 0
      end
      object lblVatRate
        Left = 58
        Top = 40
        Width = 66
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'VAT Rate (%)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtVatRate
        Left = 130
        Top = 36
        Width = 80
        Height = 24
        MaxLength = 5
        MinValue = 0
        MaxValue = 200
        TabOrder = 1
        Value = 18.000000000000000000
      end
      object lblRawMaterialStockAccount
        Left = 6
        Top = 75
        Width = 118
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'RM Stock Account'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtRawMaterialStockAccount
        Left = 130
        Top = 71
        Width = 200
        Height = 23
        TabOrder = 2
      end
      object lblRawMaterialUsageAccount
        Left = 6
        Top = 105
        Width = 118
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'RM Usage Account'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtRawMaterialUsageAccount
        Left = 130
        Top = 101
        Width = 200
        Height = 23
        TabOrder = 3
      end
      object lblSemiProductAccount
        Left = 6
        Top = 135
        Width = 118
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Semi Product Acct'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtSemiProductAccount
        Left = 130
        Top = 131
        Width = 200
        Height = 23
        TabOrder = 4
      end
    end
  end
end

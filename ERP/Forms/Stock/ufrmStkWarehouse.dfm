object frmStkWarehouse: TfrmStkWarehouse
  Left = 0
  Top = 0
  Caption = 'frmStkWarehouse'
  ClientHeight = 260
  ClientWidth = 480
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
    Width = 480
    Height = 260
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    TabStop = False
    ExplicitWidth = 476
    ExplicitHeight = 250
    object tsMain: TTabSheet
      Caption = 'Genel'
      object lblWarehouseName
        Left = 31
        Top = 10
        Width = 91
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Warehouse Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtWarehouseName
        Left = 128
        Top = 6
        Width = 310
        Height = 23
        TabOrder = 0
      end
      object lblDefaultRawMaterial
        Left = 5
        Top = 45
        Width = 117
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Default Raw Material'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object chkDefaultRawMaterial
        Left = 128
        Top = 42
        Width = 97
        Height = 17
        TabOrder = 1
      end
      object lblDefaultProduction
        Left = 5
        Top = 70
        Width = 117
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Default Production'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object chkDefaultProduction
        Left = 128
        Top = 67
        Width = 97
        Height = 17
        TabOrder = 2
      end
      object lblDefaultSales
        Left = 5
        Top = 95
        Width = 117
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Default Sales'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object chkDefaultSales
        Left = 128
        Top = 92
        Width = 97
        Height = 17
        TabOrder = 3
      end
    end
  end
end

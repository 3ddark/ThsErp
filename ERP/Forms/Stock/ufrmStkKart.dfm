object frmStkKart: TfrmStkKart
  Left = 0
  Top = 0
  Caption = 'frmStkKart'
  ClientHeight = 520
  ClientWidth = 640
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
    Width = 640
    Height = 520
    ActivePage = tsGenel
    Align = alClient
    TabOrder = 0
    TabStop = False
    object tsGenel
      Caption = 'General'
      object lblstok_kodu
        Left = 37
        Top = 10
        Width = 68
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Stock Code'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtStokKodu
        Left = 111
        Top = 6
        Width = 200
        Height = 23
        TabOrder = 0
      end
      object lblstok_adi
        Left = 40
        Top = 40
        Width = 65
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Stock Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtStokAdi
        Left = 111
        Top = 36
        Width = 480
        Height = 23
        TabOrder = 1
      end
      object lblis_satilabilir
        Left = 39
        Top = 70
        Width = 66
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Sellable'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object chkIsSatilabilir
        Left = 111
        Top = 67
        Width = 97
        Height = 17
        TabOrder = 2
      end
    end
    object tsParasal
      Caption = 'Monetary'
      object pnlParasalHeader
        Left = 4
        Top = 4
        Width = 632
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 628
      end
      object lblalis_fiyat
        Left = 29
        Top = 38
        Width = 76
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Buying Price'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtAlisFiyat
        Left = 111
        Top = 34
        Width = 120
        Height = 23
        TabOrder = 1
      end
      object lblalis_para
        Left = 38
        Top = 68
        Width = 67
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Buying Curr'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtAlisPara
        Left = 111
        Top = 64
        Width = 120
        Height = 23
        TabOrder = 2
      end
      object lblsatis_fiyat
        Left = 257
        Top = 38
        Width = 98
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Sales Price'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtSatisFiyat
        Left = 359
        Top = 34
        Width = 120
        Height = 23
        TabOrder = 3
      end
      object lblsatis_para
        Left = 268
        Top = 68
        Width = 87
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Sales Curr'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtSatisPara
        Left = 359
        Top = 64
        Width = 120
        Height = 23
        TabOrder = 4
      end
      object lblihrac_fiyat
        Left = 29
        Top = 98
        Width = 76
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Export Price'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtIhracFiyat
        Left = 111
        Top = 94
        Width = 120
        Height = 23
        TabOrder = 5
      end
      object lblihrac_para
        Left = 38
        Top = 128
        Width = 67
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Export Curr'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtIhracPara
        Left = 111
        Top = 124
        Width = 120
        Height = 23
        TabOrder = 6
      end
      object lblalis_iskonto
        Left = 257
        Top = 98
        Width = 98
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Buying Disc %'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtAlisIskonto
        Left = 359
        Top = 94
        Width = 60
        Height = 24
        MaxLength = 5
        MinValue = 0
        MaxValue = 100
        TabOrder = 7
        Value = 0.000000000000000000
      end
      object lblsatis_iskonto
        Left = 257
        Top = 128
        Width = 98
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Sales Disc %'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtSatisIskonto
        Left = 359
        Top = 124
        Width = 60
        Height = 24
        MaxLength = 5
        MinValue = 0
        MaxValue = 100
        TabOrder = 8
        Value = 0.000000000000000000
      end
    end
    object tsGrupOzellikleri
      Caption = 'Group Props'
      object pnlGrupHeader
        Left = 4
        Top = 4
        Width = 632
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 628
      end
      object lblen
        Left = 17
        Top = 38
        Width = 88
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Width'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtEn
        Left = 111
        Top = 34
        Width = 80
        Height = 23
        TabOrder = 1
      end
      object lblboy
        Left = 207
        Top = 38
        Width = 68
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Length'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtBoy
        Left = 281
        Top = 34
        Width = 80
        Height = 23
        TabOrder = 2
      end
      object lbllabel_agirlik
        Left = 207
        Top = 68
        Width = 68
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Weight'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtAgirlik
        Left = 281
        Top = 64
        Width = 80
        Height = 23
        TabOrder = 3
      end
      object lbltemin_suresi
        Left = 207
        Top = 98
        Width = 68
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Supply Days'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtTeminSuresi
        Left = 281
        Top = 94
        Width = 60
        Height = 24
        MaxLength = 5
        MinValue = 0
        MaxValue = 365
        TabOrder = 4
        Value = 0.000000000000000000
      end
      object lblozel_kod
        Left = 17
        Top = 128
        Width = 88
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Special Code'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtOzelKod
        Left = 111
        Top = 124
        Width = 200
        Height = 23
        TabOrder = 5
      end
      object lblmarka
        Left = 17
        Top = 158
        Width = 88
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Brand'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtMarka
        Left = 111
        Top = 154
        Width = 200
        Height = 23
        TabOrder = 6
      end
    end
    object tsCinsOzelligi
      Caption = 'Kind Props'
      object pnlCinsHeader
        Left = 4
        Top = 4
        Width = 632
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 628
      end
      object lblmensei_id
        Left = 17
        Top = 38
        Width = 88
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Origin ID'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtMenseiID
        Left = 111
        Top = 34
        Width = 200
        Height = 23
        TabOrder = 1
      end
      object lblgtip_no
        Left = 17
        Top = 68
        Width = 88
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'HS Code'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtGtipNo
        Left = 111
        Top = 64
        Width = 200
        Height = 23
        TabOrder = 2
      end
      object lbldiib_urun_tanimi
        Left = 17
        Top = 98
        Width = 88
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'DIIB Description'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtDiibUrunTanimi
        Left = 111
        Top = 94
        Width = 480
        Height = 23
        TabOrder = 3
      end
    end
    object tsOzetler
      Caption = 'Summary'
      object pnlOzetHeader
        Left = 4
        Top = 4
        Width = 632
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 628
      end
      object lblen_az_stok_seviyesi
        Left = 17
        Top = 38
        Width = 88
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Min Stock Level'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtEnAzStokSeviyesi
        Left = 111
        Top = 34
        Width = 200
        Height = 23
        TabOrder = 1
      end
      object lbldetay
        Left = 17
        Top = 68
        Width = 88
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Overview'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object mmoTanim
        Left = 111
        Top = 64
        Width = 480
        Height = 120
        TabOrder = 2
      end
    end
  end
end

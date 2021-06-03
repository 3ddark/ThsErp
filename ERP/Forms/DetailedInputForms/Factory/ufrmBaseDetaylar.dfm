inherited frmBaseDetaylar: TfrmBaseDetaylar
  BorderIcons = [biSystemMenu, biMinimize, biMaximize]
  BorderStyle = bsSizeable
  Caption = 'frmBaseDetaylar'
  ClientHeight = 615
  ClientWidth = 1076
  ExplicitWidth = 1092
  ExplicitHeight = 654
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 1072
    Height = 563
    ExplicitWidth = 1072
    ExplicitHeight = 563
    object splLeft: TSplitter [0]
      Left = 104
      Top = 125
      Height = 437
      Beveled = True
      Color = clBtnFace
      ParentColor = False
      ExplicitLeft = 101
      ExplicitTop = 34
      ExplicitHeight = 213
    end
    object splHeader: TSplitter [1]
      Left = 1
      Top = 122
      Width = 1070
      Height = 3
      Cursor = crVSplit
      Align = alTop
      Beveled = True
      Color = clBtnFace
      ParentColor = False
      ExplicitTop = 34
      ExplicitWidth = 600
    end
    inherited pgcMain: TPageControl
      Left = 107
      Top = 125
      Width = 964
      Height = 437
      TabOrder = 2
      ExplicitLeft = 107
      ExplicitTop = 125
      ExplicitWidth = 964
      ExplicitHeight = 437
      inherited tsMain: TTabSheet
        ExplicitWidth = 956
        ExplicitHeight = 409
      end
    end
    object pnlHeader: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 1066
      Height = 118
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 1
      Align = alTop
      Constraints.MinHeight = 30
      TabOrder = 0
      object pgcHeader: TPageControl
        Left = 1
        Top = 1
        Width = 1064
        Height = 116
        ActivePage = tsHeader
        Align = alClient
        MultiLine = True
        TabOrder = 0
        TabPosition = tpLeft
        object tsHeader: TTabSheet
          Caption = 'Header'
        end
        object tsHeaderDiger: TTabSheet
          Caption = 'Di'#287'er'
          ImageIndex = 1
        end
      end
    end
    object pnlContent: TPanel
      Left = 107
      Top = 125
      Width = 964
      Height = 437
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      TabOrder = 1
      DesignSize = (
        964
        437)
      object pgcContent: TPageControl
        AlignWithMargins = True
        Left = 1
        Top = 3
        Width = 962
        Height = 433
        Margins.Left = 0
        Margins.Top = 2
        Margins.Right = 0
        Margins.Bottom = 0
        ActivePage = ts3
        Align = alClient
        TabOrder = 1
        object ts1: TTabSheet
          Caption = 'ts1'
          object pnl1: TPanel
            AlignWithMargins = True
            Left = 0
            Top = 321
            Width = 954
            Height = 84
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Margins.Bottom = 0
            Align = alBottom
            BevelOuter = bvNone
            Color = 14993769
            TabOrder = 1
            object grpGenelToplamKalan: TGroupBox
              AlignWithMargins = True
              Left = 484
              Top = 2
              Width = 233
              Height = 80
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 0
              Margins.Bottom = 2
              Align = alRight
              TabOrder = 1
              object lblToplamTutarKalan: TLabel
                Left = 4
                Top = 4
                Width = 114
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'Toplam Tutar'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object lblValToplamTutarKalan: TLabel
                Left = 121
                Top = 4
                Width = 110
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'value'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
              end
              object lblToplamIskontoTutarKalan: TLabel
                Left = 4
                Top = 18
                Width = 114
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = #304'skonto Tutar'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object lblValToplamIskontoTutarKalan: TLabel
                Left = 121
                Top = 18
                Width = 110
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'value'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
              end
              object lblAraToplamKalan: TLabel
                Left = 4
                Top = 32
                Width = 114
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'Ara Toplam'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object lblValAraToplamKalan: TLabel
                Left = 121
                Top = 32
                Width = 110
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'value'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
              end
              object lblToplamKDVTutarKalan: TLabel
                Left = 4
                Top = 46
                Width = 114
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'KDV Tutar'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object lblValToplamKDVTutarKalan: TLabel
                Left = 121
                Top = 46
                Width = 110
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'value'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
              end
              object lblGenelToplamKalan: TLabel
                Left = 4
                Top = 62
                Width = 114
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'Genel Toplam'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object lblValGenelToplamKalan: TLabel
                Left = 121
                Top = 62
                Width = 110
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'value'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
              end
            end
            object grpGenelToplam: TGroupBox
              AlignWithMargins = True
              Left = 719
              Top = 2
              Width = 233
              Height = 80
              Margins.Left = 2
              Margins.Top = 2
              Margins.Right = 2
              Margins.Bottom = 2
              Align = alRight
              TabOrder = 2
              object lblToplamTutar: TLabel
                Left = 4
                Top = 4
                Width = 114
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'Toplam Tutar'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object lblValToplamTutar: TLabel
                Left = 115
                Top = 4
                Width = 110
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'value'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
              end
              object lblToplamIskontoTutar: TLabel
                Left = 4
                Top = 18
                Width = 114
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = #304'skonto Tutar'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object lblValToplamIskontoTutar: TLabel
                Left = 115
                Top = 18
                Width = 110
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'value'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
              end
              object lblAraToplam: TLabel
                Left = 4
                Top = 32
                Width = 114
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'Ara Toplam'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object lblValAraToplam: TLabel
                Left = 115
                Top = 32
                Width = 110
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'value'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
              end
              object lblToplamKDVTutar: TLabel
                Left = 4
                Top = 46
                Width = 114
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'KDV Tutar'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object lblValToplamKDVTutar: TLabel
                Left = 115
                Top = 46
                Width = 110
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'value'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
              end
              object lblGenelToplam: TLabel
                Left = 4
                Top = 62
                Width = 114
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'Genel Toplam'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object lblValGenelToplam: TLabel
                Left = 115
                Top = 62
                Width = 110
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Caption = 'value'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
              end
            end
            object flwpnl1: TFlowPanel
              Left = 0
              Top = 0
              Width = 482
              Height = 84
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 0
            end
          end
          object strngrd1: TStringGrid
            Left = 0
            Top = 0
            Width = 954
            Height = 321
            TabStop = False
            Align = alClient
            DefaultRowHeight = 20
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowMoving, goColMoving, goTabs, goFixedColClick, goFixedRowClick, goFixedHotTrack]
            PopupMenu = pm1
            TabOrder = 0
            StyleElements = []
            OnDblClick = GridDblClick
            OnDrawCell = GridDrawCell
            ColWidths = (
              64
              64
              64
              64
              64)
            RowHeights = (
              20
              20
              20
              20
              20)
          end
        end
        object ts2: TTabSheet
          Caption = 'ts2'
          ImageIndex = 1
          object pnl2: TPanel
            AlignWithMargins = True
            Left = 0
            Top = 271
            Width = 954
            Height = 134
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Margins.Bottom = 0
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 1
            object flwpnl2: TFlowPanel
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 948
              Height = 128
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 0
            end
          end
          object strngrd2: TStringGrid
            Left = 0
            Top = 0
            Width = 954
            Height = 271
            Align = alClient
            DefaultRowHeight = 20
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowMoving, goColMoving, goTabs, goFixedColClick, goFixedRowClick, goFixedHotTrack]
            PopupMenu = pm2
            TabOrder = 0
            StyleElements = []
            OnDblClick = GridDblClick
            OnDrawCell = GridDrawCell
            ColWidths = (
              64
              64
              64
              64
              64)
          end
        end
        object ts3: TTabSheet
          Caption = 'ts3'
          ImageIndex = 2
          object strngrd3: TStringGrid
            Left = 0
            Top = 0
            Width = 954
            Height = 271
            Align = alClient
            DefaultRowHeight = 20
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goRowMoving, goColMoving, goTabs, goFixedColClick, goFixedRowClick, goFixedHotTrack]
            PopupMenu = pm3
            TabOrder = 0
            StyleElements = []
            OnDblClick = GridDblClick
            OnDrawCell = GridDrawCell
            ColWidths = (
              64
              64
              64
              64
              64)
          end
          object pnl3: TPanel
            AlignWithMargins = True
            Left = 0
            Top = 271
            Width = 954
            Height = 134
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Margins.Bottom = 0
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 1
            object flwpnl3: TFlowPanel
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 948
              Height = 128
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 0
            end
          end
        end
      end
      object btnHeaderShowHide: TButton
        Left = 873
        Top = 0
        Width = 86
        Height = 21
        Anchors = [akTop, akRight]
        Caption = 'Min/Max'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = btnHeaderShowHideClick
      end
    end
    object pnlLeft: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 126
      Width = 100
      Height = 434
      Margins.Left = 2
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 2
      Align = alLeft
      Constraints.MinHeight = 100
      Constraints.MinWidth = 100
      TabOrder = 3
    end
  end
  inherited pnlBottom: TPanel
    Top = 567
    Width = 1072
    ExplicitTop = 567
    ExplicitWidth = 1072
    inherited btnAccept: TButton
      Left = 863
      ExplicitLeft = 863
    end
    inherited btnClose: TButton
      Left = 967
      ExplicitLeft = 967
    end
  end
  inherited stbBase: TStatusBar
    Top = 597
    Width = 1076
    ExplicitTop = 597
    ExplicitWidth = 1076
  end
  object pm1: TPopupMenu
    Left = 407
    Top = 181
    object mniadd1: TMenuItem
      Action = actadd1
    end
    object mniN1: TMenuItem
      Caption = '-'
    end
    object mniPrint1: TMenuItem
      Action = actprint1
    end
    object mniExportExcel1: TMenuItem
      Action = actexport_excel1
    end
  end
  object pm2: TPopupMenu
    Left = 471
    Top = 181
    object mniadd2: TMenuItem
      Action = actadd2
    end
    object mniN2: TMenuItem
      Caption = '-'
    end
    object mniPrint2: TMenuItem
      Action = actprint2
    end
    object mniExportExcel2: TMenuItem
      Action = actexport_excel2
    end
  end
  object pm3: TPopupMenu
    Left = 535
    Top = 181
    object mniadd3: TMenuItem
      Action = actadd3
    end
    object mniN3: TMenuItem
      Caption = '-'
    end
    object mniPrint3: TMenuItem
      Action = actprint3
    end
    object mniExportExcel3: TMenuItem
      Action = actexport_excel3
    end
  end
  object frxdbdtstBase: TfrxDBDataset
    UserName = 'frxDBDataset1'
    CloseDataSource = False
    BCDToCurrency = False
    Left = 400
    Top = 256
  end
  object frxpdfxprtBase: TfrxPDFExport
    UseFileCache = True
    ShowProgress = True
    OverwritePrompt = False
    DataOnly = False
    OpenAfterExport = False
    PrintOptimized = False
    Outline = False
    Background = False
    HTMLTags = True
    Quality = 95
    Transparency = False
    Author = 'THS Erp'
    Subject = 'THS Erp PDF Export'
    ProtectionFlags = [ePrint, eModify, eCopy, eAnnot]
    HideToolbar = False
    HideMenubar = False
    HideWindowUI = False
    FitWindow = False
    CenterWindow = False
    PrintScaling = False
    PdfA = False
    PDFStandard = psNone
    PDFVersion = pv17
    Left = 312
    Top = 256
  end
  object frxrprtBase: TfrxReport
    Version = '6.5'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbNavigator]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 43704.572072824100000000
    ReportOptions.LastChange = 43710.700858703710000000
    ScriptLanguage = 'PascalScript'
    StoreInDFM = False
    Left = 232
    Top = 256
  end
  object actlstdetaylar_form: TActionList
    Images = dm.il16
    Left = 608
    Top = 184
    object actadd3: TAction
      Caption = 'Ekle'
      ImageIndex = 1
      ShortCut = 118
      OnExecute = actadd3Execute
    end
    object actadd2: TAction
      Caption = 'Ekle'
      ImageIndex = 1
      ShortCut = 118
      OnExecute = actadd2Execute
    end
    object actadd1: TAction
      Caption = 'Ekle'
      ImageIndex = 1
      ShortCut = 118
      OnExecute = actadd1Execute
    end
    object actexport_excel3: TAction
      Caption = 'Excel Kaydet'
      ImageIndex = 20
      ShortCut = 16453
      OnExecute = actexport_excel3Execute
    end
    object actexport_excel2: TAction
      Caption = 'Excel Kaydet'
      ImageIndex = 20
      ShortCut = 16453
      OnExecute = actexport_excel2Execute
    end
    object actexport_excel1: TAction
      Caption = 'Excel Kaydet'
      ImageIndex = 20
      ShortCut = 16453
      OnExecute = actexport_excel1Execute
    end
    object actprint1: TAction
      Caption = 'Yazd'#305'r'
      ImageIndex = 48
      ShortCut = 16464
      OnExecute = actprint1Execute
    end
    object actprint2: TAction
      Caption = 'Yazd'#305'r'
      ImageIndex = 48
      ShortCut = 16464
      OnExecute = actprint2Execute
    end
    object actprint3: TAction
      Caption = 'Yazd'#305'r'
      ImageIndex = 48
      ShortCut = 16464
      OnExecute = actprint3Execute
    end
    object actcopy1: TAction
      Caption = 'Kopyala'
      ImageIndex = 1
      ShortCut = 16502
      OnExecute = actcopy1Execute
    end
    object actcopy2: TAction
      Caption = 'Kopyala'
      ImageIndex = 1
      ShortCut = 16502
      OnExecute = actcopy2Execute
    end
    object actcopy3: TAction
      Caption = 'Kopyala'
      ImageIndex = 1
      ShortCut = 16502
      OnExecute = actcopy3Execute
    end
  end
end

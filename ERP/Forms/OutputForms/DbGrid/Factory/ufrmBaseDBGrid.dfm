inherited frmBaseDBGrid: TfrmBaseDBGrid
  Caption = 'frmBaseDBGrid'
  ClientHeight = 577
  ClientWidth = 821
  Constraints.MinHeight = 350
  Constraints.MinWidth = 450
  ExplicitWidth = 837
  ExplicitHeight = 616
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 817
    Height = 525
    ExplicitWidth = 817
    ExplicitHeight = 525
    inherited splLeft: TSplitter
      Height = 395
      ExplicitHeight = 280
    end
    inherited splHeader: TSplitter
      Width = 815
      ExplicitWidth = 568
    end
    inherited pnlLeft: TPanel
      Height = 392
      Caption = ''
      TabOrder = 1
      ExplicitHeight = 392
    end
    inherited pnlHeader: TPanel
      Width = 811
      Caption = ''
      TabOrder = 0
      ExplicitWidth = 811
      object lblFilterHelper: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 87
        Height = 22
        Align = alLeft
        Alignment = taRightJustify
        Caption = 'Anahtar Kelime'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 13
      end
      object edtFilterHelper: TEdit
        AlignWithMargins = True
        Left = 97
        Top = 4
        Width = 710
        Height = 22
        Align = alClient
        TabOrder = 0
        Text = 'edtFilter'
        OnChange = edtFilterHelperChange
        OnKeyDown = edtFilterHelperKeyDown
        OnKeyUp = edtFilterHelperKeyUp
        ExplicitHeight = 21
      end
    end
    inherited pnlContent: TPanel
      Width = 706
      Height = 392
      ExplicitWidth = 706
      ExplicitHeight = 392
      object grd: TDBGrid
        Left = 1
        Top = 1
        Width = 704
        Height = 390
        Align = alClient
        DataSource = dsbase
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        PopupMenu = pmDB
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        OnCellClick = grdCellClick
        OnColEnter = grdColEnter
        OnColExit = grdColExit
        OnColumnMoved = grdColumnMoved
        OnDrawDataCell = grdDrawDataCell
        OnDrawColumnCell = grdDrawColumnCell
        OnDblClick = grdDblClick
        OnDragDrop = grdDragDrop
        OnDragOver = grdDragOver
        OnEnter = grdEnter
        OnExit = grdExit
        OnKeyDown = grdKeyDown
        OnKeyPress = grdKeyPress
        OnKeyUp = grdKeyUp
        OnMouseLeave = grdMouseLeave
        OnMouseMove = grdMouseMove
        OnMouseUp = grdMouseUp
        OnMouseWheel = grdMouseWheel
        OnMouseWheelDown = grdMouseWheelDown
        OnMouseWheelUp = grdMouseWheelUp
        OnTitleClick = grdTitleClick
      end
    end
    object pnlButtons: TPanel
      Left = 1
      Top = 432
      Width = 815
      Height = 92
      Align = alBottom
      BevelOuter = bvNone
      Constraints.MinHeight = 40
      TabOrder = 3
      object pnlButtonRight: TPanel
        Left = 630
        Top = 0
        Width = 185
        Height = 92
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
      end
      object pnlButtonLeft: TPanel
        Left = 0
        Top = 0
        Width = 630
        Height = 92
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object btnAddNew: TButton
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 90
          Height = 22
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 0
          Margins.Bottom = 0
          Caption = 'Kay'#305't Ekle'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          HotImageIndex = 1
          ImageIndex = 1
          Images = dm.il16
          ParentFont = False
          TabOrder = 0
          OnClick = btnAddNewClick
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 529
    Width = 817
    ExplicitTop = 529
    ExplicitWidth = 817
    inherited btnAccept: TButton
      Left = 608
      TabOrder = 2
      ExplicitLeft = 608
    end
    inherited btnClose: TButton
      Left = 712
      TabOrder = 3
      ExplicitLeft = 712
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 559
    Width = 821
    ExplicitTop = 559
    ExplicitWidth = 821
  end
  object ProgressBar1: TProgressBar [3]
    Left = 360
    Top = 224
    Width = 150
    Height = 17
    DoubleBuffered = False
    ParentDoubleBuffered = False
    Position = 50
    Smooth = True
    Style = pbstMarquee
    MarqueeInterval = 1
    Step = 1
    TabOrder = 3
    Visible = False
  end
  inherited pmDB: TPopupMenu
    Images = dm.il16
    OnChange = pmDBChange
    OnPopup = pmDBPopup
    Top = 112
    object mnipreview: TMenuItem
      Caption = #304'ncele'
      ImageIndex = 54
      ShortCut = 16397
      OnClick = mnipreviewClick
    end
    object mnicopy_to_clipboard: TMenuItem
      Caption = 'Yaz'#305'y'#305' Kopyala'
      ImageIndex = 16
      ShortCut = 16451
      OnClick = mnicopy_to_clipboardClick
    end
    object mniSeperator1: TMenuItem
      Caption = '-'
    end
    object mniFormTitleByLang: TMenuItem
      Caption = 'Lisana G'#246're Form Ba'#351'l'#305#287#305'n'#305' G'#252'ncelle'
      OnClick = mniFormTitleByLangClick
    end
    object mniColumnSummary: TMenuItem
      Caption = 'Kolon Alt '#214'zeti'
      Visible = False
      OnClick = mniColumnSummaryClick
    end
    object mniColumnTitleByLang: TMenuItem
      Caption = 'Lisana G'#246're Kolon Ba'#351'l'#305#287#305' G'#252'ncelle'
      OnClick = mniColumnTitleByLangClick
    end
    object mniLangDataContent: TMenuItem
      Caption = 'Lisana G'#246're '#304#231'erik'
      OnClick = mniLangDataContentClick
    end
    object mniUpdateColWidth: TMenuItem
      Caption = 'Kolon Geni'#351'liklerini G'#252'ncelle'
      OnClick = mniUpdateColWidthClick
    end
    object mniSeperator2: TMenuItem
      Caption = '-'
    end
    object mnifilter: TMenuItem
      Action = actfilter
    end
    object mnifilter_exclude: TMenuItem
      Action = actfilter_exclude
    end
    object mnifilter_back: TMenuItem
      Action = actfilter_back
    end
    object mnifilter_remove: TMenuItem
      Action = actfilter_remove
    end
    object mnisort_remove: TMenuItem
      Action = actsort_remove
    end
    object mniSeperator3: TMenuItem
      Caption = '-'
    end
    object mnicopy_record: TMenuItem
      Caption = 'Kay'#305't Kopyala'
      ImageIndex = 16
      ShortCut = 16452
      OnClick = mnicopy_recordClick
    end
    object mniSeperator4: TMenuItem
      Caption = '-'
    end
    object mniexport_excel: TMenuItem
      Caption = 'Excel Kaydet'
      ImageIndex = 25
      ShortCut = 16453
      OnClick = mniexport_excelClick
    end
    object mniexport_excel_all: TMenuItem
      Caption = 'Excel Kaydet T'#252'm'#252
      ImageIndex = 25
      ShortCut = 24645
      OnClick = mniexport_excel_allClick
    end
    object mniprint: TMenuItem
      Caption = 'Yazd'#305'r'
      ImageIndex = 48
      ShortCut = 16464
      OnClick = mniprintClick
    end
    object mniSeperator5: TMenuItem
      Caption = '-'
    end
  end
  object frxrprtBase: TfrxReport
    Version = '6.3.1'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbNavigator]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 43704.572072824100000000
    ReportOptions.LastChange = 43710.700858703700000000
    ScriptLanguage = 'PascalScript'
    StoreInDFM = False
    OnPreview = frxrprtBasePreview
    Left = 232
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
  object frxdbdtstBase: TfrxDBDataset
    UserName = 'frxDBDataset1'
    CloseDataSource = False
    BCDToCurrency = False
    Left = 400
    Top = 256
  end
  object dlgSave: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 600
    Top = 56
  end
  object dsbase: TDataSource
    DataSet = qrybase
    Left = 326
    Top = 80
  end
  object qrybase: TFDQuery
    Left = 262
    Top = 80
  end
  object actlstgrd: TActionList
    Images = dm.il16
    Left = 480
    Top = 184
    object actfilter_init: TAction
      Caption = 'actfilter_init'
      OnExecute = actfilter_initExecute
    end
    object actfilter: TAction
      Caption = 'Filtrele'
      ImageIndex = 26
      ShortCut = 114
      OnExecute = actfilterExecute
    end
    object actfilter_exclude: TAction
      Caption = 'Se'#231'ili Hari'#231' Filtrele'
      ImageIndex = 27
      ShortCut = 8306
      OnExecute = actfilter_excludeExecute
    end
    object actfilter_back: TAction
      Caption = 'Geri Filtrele'
      ImageIndex = 79
      ShortCut = 8311
      OnExecute = actfilter_backExecute
    end
    object actfilter_remove: TAction
      Caption = 'Filtre Kald'#305'r'
      ImageIndex = 28
      ShortCut = 119
      OnExecute = actfilter_removeExecute
    end
    object actsort_init: TAction
      Caption = 'actsort_init'
      OnExecute = actsort_initExecute
    end
    object actsort: TAction
      Caption = 'S'#305'rlama'
      OnExecute = actsortExecute
    end
    object actsort_remove: TAction
      Caption = 'S'#305'ralamay'#305' Kald'#305'r'
      ImageIndex = 80
      OnExecute = actsort_removeExecute
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 248
    Top = 368
  end
end

object frmBaseDBGrid2: TfrmBaseDBGrid2
  Left = 0
  Top = 0
  Caption = 'frmBaseDBGrid2'
  ClientHeight = 444
  ClientWidth = 790
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 15
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 790
    Height = 394
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    object splHeader: TSplitter
      Left = 0
      Top = 33
      Width = 790
      Height = 3
      Cursor = crVSplit
      Align = alTop
      Beveled = True
      Color = clBtnFace
      ParentColor = False
      ExplicitWidth = 568
    end
    object pnlHeader: TPanel
      AlignWithMargins = True
      Left = 2
      Top = 2
      Width = 786
      Height = 30
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 1
      Align = alTop
      Constraints.MinHeight = 30
      TabOrder = 0
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
        Width = 685
        Height = 22
        Align = alClient
        TabOrder = 0
        Text = 'edtFilter'
        ExplicitHeight = 23
      end
    end
    object pnlContent: TPanel
      Left = 0
      Top = 36
      Width = 790
      Height = 266
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object grd: TDBGrid
        Left = 0
        Top = 0
        Width = 790
        Height = 266
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsbase
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        PopupMenu = pmDB
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
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
      Left = 0
      Top = 302
      Width = 790
      Height = 92
      Align = alBottom
      BevelOuter = bvNone
      Constraints.MinHeight = 40
      TabOrder = 2
      object pnlButtonRight: TPanel
        Left = 605
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
        Width = 605
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
  object pnlBottom: TPanel
    AlignWithMargins = True
    Left = 2
    Top = 396
    Width = 786
    Height = 28
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    BevelOuter = bvNone
    Color = 14993769
    TabOrder = 2
    object btnSpin: TSpinButton
      Left = 0
      Top = 0
      Width = 15
      Height = 28
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      DownGlyph.Data = {
        0E010000424D0E01000000000000360000002800000009000000060000000100
        200000000000D800000000000000000000000000000000000000008080000080
        8000008080000080800000808000008080000080800000808000008080000080
        8000008080000080800000808000000000000080800000808000008080000080
        8000008080000080800000808000000000000000000000000000008080000080
        8000008080000080800000808000000000000000000000000000000000000000
        0000008080000080800000808000000000000000000000000000000000000000
        0000000000000000000000808000008080000080800000808000008080000080
        800000808000008080000080800000808000}
      TabOrder = 0
      UpGlyph.Data = {
        0E010000424D0E01000000000000360000002800000009000000060000000100
        200000000000D800000000000000000000000000000000000000008080000080
        8000008080000080800000808000008080000080800000808000008080000080
        8000000000000000000000000000000000000000000000000000000000000080
        8000008080000080800000000000000000000000000000000000000000000080
        8000008080000080800000808000008080000000000000000000000000000080
        8000008080000080800000808000008080000080800000808000000000000080
        8000008080000080800000808000008080000080800000808000008080000080
        800000808000008080000080800000808000}
      Visible = False
      OnDownClick = btnSpinDownClick
      OnUpClick = btnSpinUpClick
    end
    object btnAccept: TButton
      AlignWithMargins = True
      Left = 580
      Top = 0
      Width = 100
      Height = 28
      Margins.Left = 2
      Margins.Top = 0
      Margins.Right = 2
      Margins.Bottom = 0
      Align = alRight
      Caption = 'TAMAM'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      HotImageIndex = 0
      ImageIndex = 0
      ImageMargins.Left = 2
      ImageMargins.Right = 2
      Images = dm.il16
      ParentFont = False
      TabOrder = 1
      OnClick = btnAcceptClick
    end
    object btnClose: TButton
      AlignWithMargins = True
      Left = 684
      Top = 0
      Width = 100
      Height = 28
      Margins.Left = 2
      Margins.Top = 0
      Margins.Right = 2
      Margins.Bottom = 0
      Align = alRight
      Caption = 'KAPAT'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      HotImageIndex = 11
      ImageIndex = 11
      ImageMargins.Left = 2
      ImageMargins.Right = 2
      Images = dm.il16
      ParentFont = False
      TabOrder = 2
      OnClick = btnCloseClick
    end
  end
  object pb1: TProgressBar
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
    TabOrder = 1
    Visible = False
  end
  object stbBase: TStatusBar
    Left = 0
    Top = 426
    Width = 790
    Height = 18
    Color = clBlack
    Panels = <>
  end
  object AppEvntsBase: TApplicationEvents
    Left = 24
    Top = 8
  end
  object pmDB: TPopupMenu
    Images = dm.il16
    OnChange = pmDBChange
    OnPopup = pmDBPopup
    Left = 208
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
  object dlgPntBase: TPrintDialog
    Left = 96
    Top = 8
  end
  object dlgSave: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 596
    Top = 56
  end
  object dsbase: TDataSource
    Left = 326
    Top = 80
  end
  object actlstgrd: TActionList
    Images = dm.il16
    Left = 480
    Top = 184
    object actfilter_init: TAction
      Caption = 'actfilter_init'
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
    end
    object actsort: TAction
      Caption = 'S'#305'rlama'
    end
    object actsort_remove: TAction
      Caption = 'S'#305'ralamay'#305' Kald'#305'r'
      ImageIndex = 80
      OnExecute = actsort_removeExecute
    end
  end
  object Timer1: TTimer
    Left = 248
    Top = 368
  end
end

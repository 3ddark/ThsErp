inherited frmBaseOutput1: TfrmBaseOutput1
  Caption = 'frmBaseOutput1'
  ClientHeight = 515
  ClientWidth = 789
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 805
  ExplicitHeight = 554
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 789
    Height = 465
    ExplicitHeight = 349
    inherited splLeft: TSplitter
      Height = 389
    end
    inherited splHeader: TSplitter
      Width = 789
    end
    inherited pnlLeft: TPanel
      Height = 386
      Caption = ''
      ExplicitHeight = 310
    end
    inherited pnlHeader: TPanel
      Width = 785
      Caption = ''
      object lblFilterHelper: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 4
        Width = 29
        Height = 22
        Align = alLeft
        Alignment = taRightJustify
        Caption = 'Filtre'
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
        Left = 39
        Top = 4
        Width = 742
        Height = 22
        Align = alClient
        TabOrder = 0
        ExplicitHeight = 21
      end
    end
    inherited pnlContent: TPanel
      Width = 680
      Height = 386
      ExplicitHeight = 310
      object grd: TDBGrid
        Left = 1
        Top = 1
        Width = 678
        Height = 384
        Align = alClient
        BorderStyle = bsNone
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        PopupMenu = pmDB
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
    object pnlButtons: TPanel
      Left = 0
      Top = 425
      Width = 789
      Height = 40
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 3
      ExplicitTop = 441
      ExplicitWidth = 755
      object pnlButtonRight: TPanel
        Left = 604
        Top = 0
        Width = 185
        Height = 40
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        ExplicitLeft = 678
      end
      object pnlButtonLeft: TPanel
        Left = 0
        Top = 0
        Width = 604
        Height = 40
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 678
        object btnAddNew: TButton
          AlignWithMargins = True
          Left = 4
          Top = 4
          Width = 100
          Height = 28
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 0
          Margins.Bottom = 0
          Caption = 'Ekle'
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
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 467
    Width = 785
    ExplicitTop = 351
    inherited btnAccept: TButton
      Left = 579
    end
    inherited btnClose: TButton
      Left = 683
    end
  end
  inherited stbBase: TStatusBar
    Top = 497
    Width = 789
    ExplicitTop = 381
  end
  object pb1: TProgressBar [3]
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
end

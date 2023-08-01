object frmBase: TfrmBase
  Left = 0
  Top = 0
  Caption = 'Base Form'
  ClientHeight = 398
  ClientWidth = 604
  Color = clBtnFace
  Constraints.MinHeight = 128
  Constraints.MinWidth = 255
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 604
    Height = 348
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    ExplicitWidth = 602
    ExplicitHeight = 344
  end
  object pnlBottom: TPanel
    AlignWithMargins = True
    Left = 2
    Top = 350
    Width = 600
    Height = 28
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    BevelOuter = bvNone
    Color = 14993769
    TabOrder = 1
    ExplicitTop = 346
    ExplicitWidth = 598
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
      Left = 394
      Top = 0
      Width = 100
      Height = 28
      Margins.Left = 2
      Margins.Top = 0
      Margins.Right = 2
      Margins.Bottom = 0
      Align = alRight
      Caption = 'Tamam'
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
      TabOrder = 2
      OnClick = btnAcceptClick
      ExplicitLeft = 392
    end
    object btnClose: TButton
      AlignWithMargins = True
      Left = 498
      Top = 0
      Width = 100
      Height = 28
      Margins.Left = 2
      Margins.Top = 0
      Margins.Right = 2
      Margins.Bottom = 0
      Align = alRight
      Caption = 'Kapat'
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
      TabOrder = 3
      OnClick = btnCloseClick
      ExplicitLeft = 496
    end
    object btnDelete: TButton
      AlignWithMargins = True
      Left = 17
      Top = 0
      Width = 100
      Height = 28
      Margins.Left = 2
      Margins.Top = 0
      Margins.Right = 2
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'Sil'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      HotImageIndex = 51
      ImageIndex = 51
      ImageMargins.Left = 2
      ImageMargins.Right = 2
      Images = dm.il16
      ParentFont = False
      TabOrder = 1
      OnClick = btnDeleteClick
    end
  end
  object stbBase: TStatusBar
    Left = 0
    Top = 380
    Width = 604
    Height = 18
    Color = clBlack
    Panels = <>
    OnDrawPanel = stbBaseDrawPanel
    ExplicitTop = 376
    ExplicitWidth = 602
  end
  object AppEvntsBase: TApplicationEvents
    Left = 24
    Top = 8
  end
  object dlgPntBase: TPrintDialog
    Left = 96
    Top = 8
  end
end

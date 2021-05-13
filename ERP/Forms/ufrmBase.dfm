object frmBase: TfrmBase
  Left = 0
  Top = 0
  Caption = 'Base Form'
  ClientHeight = 402
  ClientWidth = 606
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
  OldCreateOrder = True
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
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    AlignWithMargins = True
    Left = 2
    Top = 2
    Width = 602
    Height = 350
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 0
    Align = alClient
    ParentColor = True
    TabOrder = 0
  end
  object pnlBottom: TPanel
    AlignWithMargins = True
    Left = 2
    Top = 354
    Width = 602
    Height = 28
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    Color = 14993769
    Padding.Left = 2
    Padding.Top = 2
    Padding.Right = 2
    Padding.Bottom = 2
    TabOrder = 1
    object btnSpin: TSpinButton
      Left = 3
      Top = 3
      Width = 15
      Height = 22
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
      Left = 393
      Top = 3
      Width = 100
      Height = 22
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
      Left = 497
      Top = 3
      Width = 100
      Height = 22
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
    object btnDelete: TButton
      AlignWithMargins = True
      Left = 20
      Top = 3
      Width = 100
      Height = 22
      Margins.Left = 2
      Margins.Top = 0
      Margins.Right = 2
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'S'#304'L'
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
      TabOrder = 3
      OnClick = btnDeleteClick
    end
  end
  object stbBase: TStatusBar
    Left = 0
    Top = 384
    Width = 606
    Height = 18
    Color = clBlack
    Panels = <>
    OnDrawPanel = stbBaseDrawPanel
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

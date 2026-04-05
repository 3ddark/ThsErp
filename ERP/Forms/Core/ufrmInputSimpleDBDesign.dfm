object frmInputSimpleDBDesign: TfrmInputSimpleDBDesign
  Left = 0
  Top = 0
  Caption = 'frmInputSimpleDBDesign'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 15
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 391
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    ExplicitWidth = 622
    ExplicitHeight = 383
  end
  object pnlBottom: TPanel
    AlignWithMargins = True
    Left = 2
    Top = 393
    Width = 620
    Height = 28
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    BevelOuter = bvNone
    Color = 14993769
    TabOrder = 1
    ExplicitTop = 385
    ExplicitWidth = 618
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
      Left = 414
      Top = 0
      Width = 100
      Height = 28
      Margins.Left = 2
      Margins.Top = 0
      Margins.Right = 2
      Margins.Bottom = 0
      Align = alRight
      Caption = 'Accept'
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
      ExplicitLeft = 412
    end
    object btnClose: TButton
      AlignWithMargins = True
      Left = 518
      Top = 0
      Width = 100
      Height = 28
      Margins.Left = 2
      Margins.Top = 0
      Margins.Right = 2
      Margins.Bottom = 0
      Align = alRight
      Caption = 'Close'
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
      ExplicitLeft = 516
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
      Caption = 'Delete'
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
    end
  end
  object statBase: TStatusBar
    Left = 0
    Top = 423
    Width = 624
    Height = 18
    Color = clBlack
    Panels = <>
    OnDrawPanel = statBaseDrawPanel
    ExplicitTop = 415
    ExplicitWidth = 622
  end
end

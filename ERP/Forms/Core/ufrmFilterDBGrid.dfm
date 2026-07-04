inherited frmFilterDBGrid: TfrmFilterDBGrid
  Caption = 'Filter'
  ClientHeight = 384
  ClientWidth = 727
  Constraints.MinHeight = 350
  ExplicitWidth = 743
  ExplicitHeight = 423
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 723
    Height = 318
    ExplicitWidth = 398
    ExplicitHeight = 305
    object lblFields: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 715
      Height = 13
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Select data fields to filter'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitLeft = 8
      ExplicitTop = 127
      ExplicitWidth = 318
    end
    object chklstFields: TCheckListBox
      AlignWithMargins = True
      Left = 130
      Top = 23
      Width = 589
      Height = 257
      Align = alClient
      Columns = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnDblClick = chklstFieldsDblClick
      ExplicitLeft = 4
      ExplicitTop = 122
      ExplicitWidth = 390
      ExplicitHeight = 145
    end
    object rgFilterCriter: TRadioGroup
      AlignWithMargins = True
      Left = 3
      Top = 22
      Width = 122
      Height = 259
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alLeft
      Caption = 'Filter Criteria'
      ItemIndex = 0
      Items.Strings = (
        '='
        'with start...'
        'like'
        'not like'
        '...with end'
        '<>'
        '>'
        '<'
        '>='
        '<=')
      TabOrder = 0
      ExplicitTop = 23
      ExplicitHeight = 244
    end
    object Panel1: TPanel
      AlignWithMargins = True
      Left = 4
      Top = 286
      Width = 715
      Height = 28
      Align = alBottom
      TabOrder = 2
      ExplicitTop = 273
      ExplicitWidth = 390
      DesignSize = (
        715
        28)
      object lblFilterKeyValue: TLabel
        Left = 54
        Top = 5
        Width = 87
        Height = 13
        Alignment = taRightJustify
        Caption = 'Filter Key Value'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object edtFilter: TEdit
        Left = 144
        Top = 2
        Width = 569
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        CharCase = ecUpperCase
        TabOrder = 0
        Text = 'EDTFILTER'
        ExplicitWidth = 244
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 322
    Width = 723
    ExplicitTop = 309
    ExplicitWidth = 398
    inherited btnAccept: TButton
      Left = 514
      ExplicitLeft = 189
    end
    inherited btnClose: TButton
      Left = 618
      ExplicitLeft = 293
    end
  end
  inherited stbBase: TStatusBar
    Top = 366
    Width = 727
    ExplicitTop = 353
    ExplicitWidth = 402
  end
end

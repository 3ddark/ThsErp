inherited frmFilterDBGrid: TfrmFilterDBGrid
  Caption = 'Filter'
  ClientHeight = 371
  ClientWidth = 402
  Constraints.MinHeight = 350
  ExplicitWidth = 418
  ExplicitHeight = 410
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 398
    Height = 319
    ExplicitWidth = 398
    ExplicitHeight = 319
    object lblFields: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 103
      Width = 390
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
      Left = 4
      Top = 122
      Width = 390
      Height = 159
      Align = alClient
      Columns = 2
      ItemHeight = 13
      TabOrder = 1
    end
    object rgFilterCriter: TRadioGroup
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 390
      Height = 93
      Align = alTop
      Caption = 'Filter Criteria'
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        '='
        'like'
        'not like'
        'with start...'
        '...with end'
        '<>'
        '>'
        '<'
        '>='
        '<=')
      TabOrder = 0
    end
    object Panel1: TPanel
      AlignWithMargins = True
      Left = 4
      Top = 287
      Width = 390
      Height = 28
      Align = alBottom
      TabOrder = 2
      DesignSize = (
        390
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
        Width = 244
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        CharCase = ecUpperCase
        TabOrder = 0
        Text = 'EDTFILTER'
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 323
    Width = 398
    ExplicitTop = 323
    ExplicitWidth = 398
    inherited btnAccept: TButton
      Left = 189
      ExplicitLeft = 189
    end
    inherited btnClose: TButton
      Left = 293
      ExplicitLeft = 293
    end
  end
  inherited stbBase: TStatusBar
    Top = 353
    Width = 402
    ExplicitTop = 353
    ExplicitWidth = 402
  end
end

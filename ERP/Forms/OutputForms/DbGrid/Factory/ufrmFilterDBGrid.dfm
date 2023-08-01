inherited frmFilterDBGrid: TfrmFilterDBGrid
  BorderStyle = bsDialog
  Caption = 'Special Filter'
  ClientHeight = 357
  ClientWidth = 870
  Constraints.MinHeight = 350
  ExplicitWidth = 886
  ExplicitHeight = 396
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 870
    Height = 307
    ExplicitWidth = 872
    ExplicitHeight = 311
    object lblFields: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 57
      Width = 866
      Height = 13
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Available Columns'
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
      Left = 0
      Top = 73
      Width = 872
      Height = 217
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Columns = 2
      ItemHeight = 13
      TabOrder = 1
    end
    object rgFilterCriter: TRadioGroup
      Left = 0
      Top = 0
      Width = 870
      Height = 54
      Align = alTop
      Caption = 'Filter Criteria'
      Columns = 6
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
      ExplicitWidth = 872
    end
    object Panel1: TPanel
      Left = 0
      Top = 286
      Width = 870
      Height = 21
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      ExplicitTop = 290
      ExplicitWidth = 872
      object lblFilterKeyValue: TLabel
        Left = 0
        Top = 0
        Width = 55
        Height = 13
        Align = alLeft
        Alignment = taCenter
        Caption = 'Key Value'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
      end
      object edtFilter: TEdit
        Left = 55
        Top = 0
        Width = 817
        Height = 21
        Align = alClient
        CharCase = ecUpperCase
        TabOrder = 0
        ExplicitLeft = 83
        ExplicitWidth = 789
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 309
    Width = 866
    ExplicitTop = 313
    ExplicitWidth = 868
    inherited btnAccept: TButton
      Left = 662
      Caption = 'FILTER'
      ExplicitLeft = 662
    end
    inherited btnClose: TButton
      Left = 766
      ExplicitLeft = 766
    end
  end
  inherited stbBase: TStatusBar
    Top = 339
    Width = 870
    ExplicitTop = 343
    ExplicitWidth = 872
  end
end

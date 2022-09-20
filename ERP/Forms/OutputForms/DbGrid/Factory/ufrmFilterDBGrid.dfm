inherited frmFilterDBGrid: TfrmFilterDBGrid
  BorderStyle = bsDialog
  Caption = 'Filter'
  ClientHeight = 361
  ClientWidth = 872
  Constraints.MinHeight = 350
  ExplicitWidth = 888
  ExplicitHeight = 400
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 872
    Height = 311
    ExplicitLeft = 0
    ExplicitTop = 0
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
      Caption = 'Filtre Edilebilir S'#252'tunlar'
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
      Width = 872
      Height = 54
      Align = alTop
      Caption = 'Filtreleme Kriteri'
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
    end
    object Panel1: TPanel
      Left = 0
      Top = 290
      Width = 872
      Height = 21
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object lblFilterKeyValue: TLabel
        Left = 0
        Top = 0
        Width = 83
        Height = 21
        Align = alLeft
        Alignment = taCenter
        Caption = 'Anahtar De'#287'er'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitHeight = 13
      end
      object edtFilter: TEdit
        Left = 83
        Top = 0
        Width = 789
        Height = 21
        Align = alClient
        CharCase = ecUpperCase
        TabOrder = 0
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 313
    Width = 868
    ExplicitTop = 313
    ExplicitWidth = 868
    inherited btnAccept: TButton
      Left = 662
      ExplicitLeft = 662
    end
    inherited btnClose: TButton
      Left = 766
      ExplicitLeft = 766
    end
  end
  inherited stbBase: TStatusBar
    Top = 343
    Width = 872
    ExplicitTop = 343
    ExplicitWidth = 872
  end
end

inherited frmFilterDBGrid: TfrmFilterDBGrid
  BorderStyle = bsDialog
  Caption = 'Ayr'#305'nt'#305'l'#305' Filtre'
  ClientHeight = 357
  ClientWidth = 570
  Constraints.MinHeight = 350
  ExplicitWidth = 586
  ExplicitHeight = 396
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 570
    Height = 307
    ExplicitWidth = 570
    ExplicitHeight = 307
    object lblFields: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 84
      Width = 564
      Height = 13
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Filtrelenecek Alanlar'
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
      Top = 100
      Width = 570
      Height = 186
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Columns = 2
      TabOrder = 1
    end
    object rgFilterCriter: TRadioGroup
      Left = 0
      Top = 0
      Width = 570
      Height = 81
      Align = alTop
      Caption = 'Filtre Kriteri'
      Columns = 4
      DefaultHeaderFont = False
      HeaderFont.Charset = DEFAULT_CHARSET
      HeaderFont.Color = clWindowText
      HeaderFont.Height = -11
      HeaderFont.Name = 'Tahoma'
      HeaderFont.Style = []
      ItemIndex = 0
      Items.Strings = (
        'E'#351'it olanlar'
        #304#231'erenler'
        #304#231'ermeyenler'
        '... ile Ba'#351'layanlar'
        '... ile Bitenler'
        'E'#351'i Olmayan'
        'B'#252'y'#252'k olanlar'
        'K'#252#231#252'k olanlar'
        'B'#252'y'#252'k E'#351'it olanlar'
        'K'#252#231#252'k E'#351'it olanlar')
      TabOrder = 0
    end
    object Panel1: TPanel
      Left = 0
      Top = 286
      Width = 570
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
        Width = 487
        Height = 21
        Align = alClient
        CharCase = ecUpperCase
        TabOrder = 0
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 309
    Width = 566
    ExplicitTop = 309
    ExplicitWidth = 566
    inherited btnAccept: TButton
      Left = 344
      Width = 116
      Caption = 'Filtreyi Uygula'
      ImageIndex = 26
      ExplicitLeft = 344
      ExplicitWidth = 116
    end
    inherited btnClose: TButton
      Left = 464
      ExplicitLeft = 464
    end
  end
  inherited stbBase: TStatusBar
    Top = 339
    Width = 570
    ExplicitTop = 339
    ExplicitWidth = 570
  end
end

inherited frmAlsTeklifler: TfrmAlsTeklifler
  Caption = 'Sat'#305'n Alma Teklifler'
  ClientHeight = 561
  ClientWidth = 807
  ExplicitWidth = 823
  ExplicitHeight = 600
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 807
    Height = 511
    ExplicitWidth = 805
    ExplicitHeight = 503
    inherited splLeft: TSplitter
      Height = 395
      ExplicitHeight = 404
    end
    inherited splHeader: TSplitter
      Width = 807
      ExplicitWidth = 807
    end
    inherited pnlLeft: TPanel
      Height = 395
      ExplicitHeight = 396
    end
    inherited pnlHeader: TPanel
      Width = 803
      ExplicitWidth = 801
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 760
        ExplicitWidth = 758
      end
    end
    inherited pnlContent: TPanel
      Width = 704
      Height = 395
      ExplicitWidth = 702
      ExplicitHeight = 396
      inherited grd: TDBGrid
        Width = 704
        Height = 395
      end
    end
    inherited pnlButtons: TPanel
      Top = 431
      Width = 807
      Height = 80
      ExplicitTop = 431
      ExplicitWidth = 807
      ExplicitHeight = 80
      inherited pnlButtonRight: TPanel
        Left = 672
        Width = 135
        Height = 80
        ExplicitLeft = 670
        ExplicitWidth = 135
        ExplicitHeight = 71
        object rgFiltre: TRadioGroup
          Left = 0
          Top = 0
          Width = 135
          Height = 80
          Align = alClient
          Caption = 'H'#305'zl'#305' Filtre'
          Items.Strings = (
            'Bekleyenler'
            'Sipari'#351' Olanlar'
            'T'#252'm'#252)
          TabOrder = 0
          OnClick = HizliFiltre
          ExplicitHeight = 71
        end
      end
      inherited pnlButtonLeft: TPanel
        Width = 672
        Height = 80
        ExplicitWidth = 670
        ExplicitHeight = 71
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 513
    Width = 803
    ExplicitTop = 505
    ExplicitWidth = 801
    inherited btnAccept: TButton
      Left = 597
      ExplicitLeft = 595
    end
    inherited btnClose: TButton
      Left = 701
      ExplicitLeft = 699
    end
  end
  inherited stbBase: TStatusBar
    Top = 543
    Width = 807
    ExplicitTop = 535
    ExplicitWidth = 805
  end
  inherited pmDB: TPopupMenu
    object mniSipariseAktar: TMenuItem [2]
      Caption = 'Sipari'#351'e Aktar'
      ImageIndex = 88
      OnClick = mniSipariseAktarClick
    end
  end
end

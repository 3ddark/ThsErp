inherited frmSatTeklifler: TfrmSatTeklifler
  Caption = 'Sat'#305#351' Teklifler'
  ClientHeight = 627
  ClientWidth = 807
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 823
  ExplicitHeight = 666
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 807
    Height = 577
    ExplicitWidth = 805
    ExplicitHeight = 503
    inherited splLeft: TSplitter
      Height = 461
      ExplicitHeight = 435
    end
    inherited splHeader: TSplitter
      Width = 807
      ExplicitWidth = 807
    end
    inherited pnlLeft: TPanel
      Height = 461
      ExplicitHeight = 427
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
      Height = 461
      ExplicitWidth = 702
      ExplicitHeight = 427
      inherited grd: TDBGrid
        Width = 704
        Height = 461
      end
    end
    inherited pnlButtons: TPanel
      Top = 497
      Width = 807
      Height = 80
      ExplicitTop = 497
      ExplicitWidth = 807
      ExplicitHeight = 80
      inherited pnlButtonRight: TPanel
        Left = 622
        Height = 80
        ExplicitLeft = 620
        object rgFiltre: TRadioGroup
          Left = 0
          Top = 0
          Width = 185
          Height = 80
          Align = alClient
          Caption = 'H'#305'zl'#305' Filtre'
          Items.Strings = (
            'Bekleyenler'
            'Sipari'#351' Olanlar'
            'T'#252'm'#252)
          TabOrder = 0
          OnClick = HizliFiltre
          ExplicitHeight = 40
        end
      end
      inherited pnlButtonLeft: TPanel
        Width = 622
        Height = 80
        ExplicitWidth = 620
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 579
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
    Top = 609
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

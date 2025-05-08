inherited frmSatSiparislerRapor: TfrmSatSiparislerRapor
  Caption = 'Sat'#305#351' Siparisler Rapor'
  TextHeight = 13
  inherited pnlMain: TPanel
    ExplicitWidth = 787
    ExplicitHeight = 457
    inherited splLeft: TSplitter
      Height = 349
    end
    inherited pnlLeft: TPanel
      Height = 349
      ExplicitHeight = 381
    end
    inherited pnlHeader: TPanel
      ExplicitWidth = 783
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        ExplicitWidth = 740
      end
    end
    inherited pnlContent: TPanel
      Height = 349
      ExplicitWidth = 684
      ExplicitHeight = 381
      inherited grd: TDBGrid
        Height = 349
      end
    end
    inherited pnlButtons: TPanel
      Top = 385
      Height = 80
      ExplicitTop = 385
      ExplicitHeight = 80
      inherited pnlButtonRight: TPanel
        Left = 566
        Width = 223
        Height = 80
        ExplicitLeft = 564
        ExplicitWidth = 223
        object rgFiltre: TRadioGroup
          Left = 0
          Top = 0
          Width = 223
          Height = 80
          Align = alClient
          Caption = 'Filtre'
          Columns = 2
          Items.Strings = (
            'Ge'#231'mi'#351' Sipari'#351'ler'
            'Gelecek Ay'
            'Ge'#231'en Ay'
            'Bu Hafta'
            'Sonraki Hafta'
            'T'#252'm'#252)
          TabOrder = 0
          OnClick = HizliFiltre
          ExplicitHeight = 40
        end
      end
      inherited pnlButtonLeft: TPanel
        Width = 566
        Height = 80
        ExplicitWidth = 564
      end
    end
  end
  inherited pnlBottom: TPanel
    ExplicitTop = 459
    ExplicitWidth = 783
    inherited btnAccept: TButton
      ExplicitLeft = 577
    end
    inherited btnClose: TButton
      ExplicitLeft = 681
    end
  end
  inherited stbBase: TStatusBar
    ExplicitTop = 489
    ExplicitWidth = 787
  end
end

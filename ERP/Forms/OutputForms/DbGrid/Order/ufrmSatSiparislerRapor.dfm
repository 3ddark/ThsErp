inherited frmSatSiparislerRapor: TfrmSatSiparislerRapor
  Caption = 'Sat'#305#351' Siparisler Rapor'
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited pnlHeader: TPanel
      inherited lblFilterHelper: TLabel
        Height = 22
      end
    end
    inherited pnlButtons: TPanel
      inherited pnlButtonRight: TPanel
        Left = 566
        Width = 223
        ExplicitLeft = 566
        ExplicitWidth = 223
        object rgFiltre: TRadioGroup
          Left = 0
          Top = 0
          Width = 223
          Height = 40
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
        end
      end
      inherited pnlButtonLeft: TPanel
        Width = 566
        ExplicitWidth = 566
      end
    end
  end
end

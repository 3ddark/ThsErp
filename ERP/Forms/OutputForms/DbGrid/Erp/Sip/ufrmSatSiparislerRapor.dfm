inherited frmSatSiparislerRapor: TfrmSatSiparislerRapor
  Caption = 'Sat'#305#351' Siparisler Rapor'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited pnlButtons: TPanel
      inherited pnlButtonRight: TPanel
        Left = 592
        Width = 223
        ExplicitLeft = 592
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
        end
      end
      inherited pnlButtonLeft: TPanel
        Width = 592
        ExplicitWidth = 592
      end
    end
  end
  inherited frxrprtBase: TfrxReport
    ReportOptions.LastChange = 44041.814117291670000000
    ScriptText.Strings = ()
  end
end

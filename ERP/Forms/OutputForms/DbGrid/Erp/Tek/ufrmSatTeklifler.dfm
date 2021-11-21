inherited frmSatTeklifler: TfrmSatTeklifler
  Caption = 'Sat'#305#351' Teklifler'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited pnlHeader: TPanel
      inherited lblFilterHelper: TLabel
        Height = 22
      end
    end
    inherited pnlButtons: TPanel
      inherited pnlButtonRight: TPanel
        object rgFiltre: TRadioGroup
          Left = 0
          Top = 0
          Width = 185
          Height = 92
          Align = alClient
          Caption = 'H'#305'zl'#305' Filtre'
          Items.Strings = (
            'Bekleyenler'
            'Sipari'#351' Olanlar'
            'T'#252'm'#252)
          TabOrder = 0
          OnClick = HizliFiltre
        end
      end
    end
  end
  inherited pmDB: TPopupMenu
    object mniSipariseAktar: TMenuItem [2]
      Caption = 'Sipari'#351'e Aktar'
      ImageIndex = 88
      OnClick = mniSipariseAktarClick
    end
  end
  inherited frxrprtBase: TfrxReport
    ReportOptions.LastChange = 44108.463658495400000000
    ScriptText.Strings = ()
  end
end

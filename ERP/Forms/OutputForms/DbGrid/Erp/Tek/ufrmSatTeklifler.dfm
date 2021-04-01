inherited frmSatTeklifler: TfrmSatTeklifler
  Caption = 'Sat'#305#351' Teklifler'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited pnlButtons: TPanel
      inherited pnlButtonRight: TPanel
        object rgFiltre: TRadioGroup
          Left = 0
          Top = 0
          Width = 185
          Height = 52
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
    ReportOptions.LastChange = 44108.460726712960000000
    ScriptText.Strings = ()
  end
end

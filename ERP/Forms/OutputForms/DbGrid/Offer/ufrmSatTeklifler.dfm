inherited frmSatTeklifler: TfrmSatTeklifler
  Caption = 'Sat'#305#351' Teklifler'
  ClientHeight = 561
  ClientWidth = 807
  ExplicitWidth = 823
  ExplicitHeight = 600
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 807
    Height = 511
    ExplicitWidth = 809
    ExplicitHeight = 519
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
  inherited pnlBottom: TPanel
    Top = 513
    Width = 803
    ExplicitTop = 521
    ExplicitWidth = 805
  end
  inherited stbBase: TStatusBar
    Top = 543
    Width = 807
    ExplicitTop = 551
    ExplicitWidth = 809
  end
  inherited pmDB: TPopupMenu
    object mniSipariseAktar: TMenuItem [2]
      Caption = 'Sipari'#351'e Aktar'
      ImageIndex = 88
      OnClick = mniSipariseAktarClick
    end
  end
end

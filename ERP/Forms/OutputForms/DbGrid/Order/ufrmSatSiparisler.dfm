inherited frmSatSiparisler: TfrmSatSiparisler
  Caption = 'Sat'#305#351' Siparisler'
  ClientWidth = 805
  ExplicitWidth = 821
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 805
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
            'Haz'#305'rlar'
            'Gidenler'
            'T'#252'm'#252)
          TabOrder = 0
          OnClick = HizliFiltre
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Width = 801
    ExplicitTop = 521
    ExplicitWidth = 805
  end
  inherited stbBase: TStatusBar
    Width = 805
    ExplicitTop = 551
    ExplicitWidth = 809
  end
  inherited pmDB: TPopupMenu
    object mniSiparisDurumGuncelle: TMenuItem [1]
      Caption = 'Sipari'#351'in Durumunu '#304'lerlet'
      ImageIndex = 88
      OnClick = mniSiparisDurumGuncelleClick
    end
    object mniPrintPackingList: TMenuItem
      Caption = 'Paketleme Listesi Yazd'#305'r'
      ImageIndex = 48
      OnClick = mniPrintPackingListClick
    end
  end
end

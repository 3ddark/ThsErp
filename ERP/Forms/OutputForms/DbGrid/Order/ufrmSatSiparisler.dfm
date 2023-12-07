inherited frmSatSiparisler: TfrmSatSiparisler
  Caption = 'Sat'#305#351' Siparisler'
  ClientWidth = 805
  ExplicitWidth = 821
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 805
    ExplicitWidth = 805
    inherited splHeader: TSplitter
      Width = 805
    end
    inherited pnlHeader: TPanel
      Width = 801
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 758
      end
    end
    inherited pnlContent: TPanel
      Width = 702
    end
    inherited pnlButtons: TPanel
      Width = 805
      inherited pnlButtonRight: TPanel
        object rgFiltre: TRadioGroup
          Left = 0
          Top = 0
          Width = 185
          Height = 40
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
    ExplicitWidth = 801
    inherited btnAccept: TButton
      Left = 595
    end
    inherited btnClose: TButton
      Left = 699
    end
  end
  inherited stbBase: TStatusBar
    Width = 805
    ExplicitWidth = 805
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

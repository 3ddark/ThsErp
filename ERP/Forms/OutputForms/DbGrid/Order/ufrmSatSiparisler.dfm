inherited frmSatSiparisler: TfrmSatSiparisler
  Caption = 'Sat'#305#351' Siparisler'
  ClientWidth = 805
  ExplicitWidth = 821
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 805
    ExplicitWidth = 803
    ExplicitHeight = 457
    inherited splLeft: TSplitter
      Height = 349
    end
    inherited splHeader: TSplitter
      Width = 805
      ExplicitWidth = 805
    end
    inherited pnlLeft: TPanel
      Height = 349
      ExplicitHeight = 381
    end
    inherited pnlHeader: TPanel
      Width = 801
      ExplicitWidth = 799
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 758
        ExplicitWidth = 756
      end
    end
    inherited pnlContent: TPanel
      Width = 702
      Height = 349
      ExplicitWidth = 700
      ExplicitHeight = 381
      inherited grd: TDBGrid
        Width = 702
        Height = 349
      end
    end
    inherited pnlButtons: TPanel
      Top = 385
      Width = 805
      Height = 80
      ExplicitTop = 385
      ExplicitWidth = 805
      ExplicitHeight = 80
      inherited pnlButtonRight: TPanel
        Left = 620
        Height = 80
        ExplicitLeft = 618
        object rgFiltre: TRadioGroup
          Left = 0
          Top = 0
          Width = 185
          Height = 80
          Align = alClient
          Caption = 'H'#305'zl'#305' Filtre'
          Items.Strings = (
            'Bekleyenler'
            'Haz'#305'rlar'
            'Gidenler'
            'T'#252'm'#252)
          TabOrder = 0
          OnClick = HizliFiltre
          ExplicitHeight = 40
        end
      end
      inherited pnlButtonLeft: TPanel
        Width = 620
        Height = 80
        ExplicitWidth = 618
      end
    end
  end
  inherited pnlBottom: TPanel
    Width = 801
    ExplicitTop = 459
    ExplicitWidth = 799
    inherited btnAccept: TButton
      Left = 595
      ExplicitLeft = 593
    end
    inherited btnClose: TButton
      Left = 699
      ExplicitLeft = 697
    end
  end
  inherited stbBase: TStatusBar
    Width = 805
    ExplicitTop = 489
    ExplicitWidth = 803
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

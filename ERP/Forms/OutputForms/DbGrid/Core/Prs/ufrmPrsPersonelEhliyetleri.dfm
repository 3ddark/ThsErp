inherited frmPrsPersonelEhliyetleri: TfrmPrsPersonelEhliyetleri
  Caption = 'Personel Ehliyetleri'
  ClientWidth = 793
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 793
    inherited splLeft: TSplitter
      Height = 340
    end
    inherited pnlLeft: TPanel
      Height = 340
    end
    inherited pnlHeader: TPanel
      inherited lblFilterHelper: TLabel
        Height = 22
      end
    end
    inherited pnlContent: TPanel
      Height = 340
      inherited grd: TDBGrid
        Height = 340
      end
    end
    inherited pnlButtons: TPanel
      Top = 376
    end
  end
  inherited pnlBottom: TPanel
    Width = 789
  end
  inherited stbBase: TStatusBar
    Width = 793
  end
end

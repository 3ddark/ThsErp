inherited frmSysGridKolonlar: TfrmSysGridKolonlar
  Caption = 'Sistem Grid Kolonlar'
  ClientHeight = 549
  ExplicitHeight = 588
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 499
    ExplicitHeight = 499
    inherited splLeft: TSplitter
      Height = 423
      ExplicitHeight = 375
    end
    inherited splHeader: TSplitter
      ExplicitWidth = 799
    end
    inherited pnlLeft: TPanel
      Height = 423
      ExplicitHeight = 423
    end
    inherited pnlHeader: TPanel
      inherited lblFilterHelper: TLabel
        Height = 22
      end
    end
    inherited pnlContent: TPanel
      Height = 423
      ExplicitHeight = 423
      inherited grd: TDBGrid
        Height = 423
      end
    end
    inherited pnlButtons: TPanel
      Top = 459
      ExplicitTop = 459
    end
  end
  inherited pnlBottom: TPanel
    Top = 501
    ExplicitTop = 501
  end
  inherited stbBase: TStatusBar
    Top = 531
    ExplicitTop = 531
  end
end

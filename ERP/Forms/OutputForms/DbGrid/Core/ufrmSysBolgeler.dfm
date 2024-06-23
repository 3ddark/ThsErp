inherited frmSysBolgeler: TfrmSysBolgeler
  Caption = 'Sistem B'#246'lgeler'
  ClientHeight = 565
  ExplicitHeight = 604
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 515
    ExplicitHeight = 515
    inherited splLeft: TSplitter
      Height = 439
      ExplicitHeight = 391
    end
    inherited splHeader: TSplitter
      ExplicitWidth = 799
    end
    inherited pnlLeft: TPanel
      Height = 439
      ExplicitHeight = 439
    end
    inherited pnlContent: TPanel
      Height = 439
      ExplicitHeight = 439
      inherited grd: TDBGrid
        Height = 439
      end
    end
    inherited pnlButtons: TPanel
      Top = 475
      ExplicitTop = 475
    end
  end
  inherited pnlBottom: TPanel
    Top = 517
    ExplicitTop = 517
  end
  inherited stbBase: TStatusBar
    Top = 547
    ExplicitTop = 547
  end
end

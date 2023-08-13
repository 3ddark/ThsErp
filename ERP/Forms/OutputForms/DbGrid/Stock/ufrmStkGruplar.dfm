inherited frmStkGruplar: TfrmStkGruplar
  Caption = 'Stok Gruplar'#305
  ClientHeight = 529
  ClientWidth = 793
  ExplicitWidth = 809
  ExplicitHeight = 568
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 793
    Height = 479
    ExplicitHeight = 479
    inherited splLeft: TSplitter
      Height = 351
    end
    inherited pnlLeft: TPanel
      Height = 351
      ExplicitHeight = 351
    end
    inherited pnlHeader: TPanel
      inherited lblFilterHelper: TLabel
        Height = 22
      end
    end
    inherited pnlContent: TPanel
      Height = 351
      ExplicitHeight = 351
      inherited grd: TDBGrid
        Height = 351
      end
    end
    inherited pnlButtons: TPanel
      Top = 387
      ExplicitTop = 387
    end
  end
  inherited pnlBottom: TPanel
    Top = 481
    Width = 789
    ExplicitTop = 481
  end
  inherited stbBase: TStatusBar
    Top = 511
    Width = 793
    ExplicitTop = 511
  end
end

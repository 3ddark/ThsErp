inherited frmSetPrsBolumler: TfrmSetPrsBolumler
  Caption = 'Set Employee Sections'
  ClientWidth = 793
  ExplicitWidth = 809
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 793
    ExplicitHeight = 471
    inherited splLeft: TSplitter
      Height = 340
    end
    inherited pnlLeft: TPanel
      Height = 340
      ExplicitHeight = 343
    end
    inherited pnlHeader: TPanel
      inherited lblFilterHelper: TLabel
        Height = 22
      end
    end
    inherited pnlContent: TPanel
      Height = 340
      ExplicitHeight = 343
      inherited grd: TDBGrid
        Height = 340
      end
    end
    inherited pnlButtons: TPanel
      Top = 376
      ExplicitTop = 379
    end
  end
  inherited pnlBottom: TPanel
    Width = 789
    ExplicitTop = 473
  end
  inherited stbBase: TStatusBar
    Width = 793
    ExplicitTop = 503
  end
end

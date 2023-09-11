inherited frmSetChVergiOranlari: TfrmSetChVergiOranlari
  Caption = 'Vergi Oranlar'#305
  ClientWidth = 791
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 791
    inherited splLeft: TSplitter
      Height = 389
      ExplicitHeight = 343
    end
    inherited pnlLeft: TPanel
      Height = 389
      ExplicitHeight = 389
    end
    inherited pnlHeader: TPanel
      inherited lblFilterHelper: TLabel
        Height = 22
      end
    end
    inherited pnlContent: TPanel
      Height = 389
      ExplicitHeight = 389
      inherited grd: TDBGrid
        Height = 389
      end
    end
    inherited pnlButtons: TPanel
      Top = 425
      ExplicitTop = 425
    end
  end
  inherited pnlBottom: TPanel
    Width = 787
  end
  inherited stbBase: TStatusBar
    Width = 791
  end
end

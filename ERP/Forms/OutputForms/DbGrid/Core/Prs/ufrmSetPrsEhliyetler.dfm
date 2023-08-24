inherited frmSetPrsEhliyetler: TfrmSetPrsEhliyetler
  Caption = 'Personel Ehliyet Tipleri'
  ClientHeight = 454
  ClientWidth = 791
  ExplicitTop = -1
  ExplicitHeight = 490
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 791
    Height = 404
    ExplicitHeight = 480
    inherited splLeft: TSplitter
      Height = 328
      ExplicitHeight = 355
    end
    inherited pnlLeft: TPanel
      Height = 328
      ExplicitHeight = 404
    end
    inherited pnlHeader: TPanel
      inherited lblFilterHelper: TLabel
        Height = 22
      end
    end
    inherited pnlContent: TPanel
      Height = 328
      ExplicitHeight = 404
      inherited grd: TDBGrid
        Height = 328
      end
    end
    inherited pnlButtons: TPanel
      Top = 364
      ExplicitTop = 440
      ExplicitWidth = 789
      inherited pnlButtonRight: TPanel
        ExplicitHeight = 40
      end
      inherited pnlButtonLeft: TPanel
        ExplicitHeight = 40
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 406
    Width = 787
    ExplicitTop = 482
  end
  inherited stbBase: TStatusBar
    Top = 436
    Width = 791
    ExplicitTop = 512
  end
end

inherited frmSysParaBirimleri: TfrmSysParaBirimleri
  Caption = 'Sistem Para Birimleri'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    ExplicitWidth = 793
    ExplicitHeight = 471
    inherited splLeft: TSplitter
      ExplicitHeight = 351
    end
    inherited splHeader: TSplitter
      ExplicitWidth = 797
    end
    inherited pnlLeft: TPanel
      ExplicitHeight = 343
    end
    inherited pnlHeader: TPanel
      ExplicitWidth = 789
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        ExplicitWidth = 746
      end
    end
    inherited pnlContent: TPanel
      ExplicitWidth = 690
      ExplicitHeight = 343
    end
    inherited pnlButtons: TPanel
      ExplicitTop = 379
      ExplicitWidth = 793
      inherited pnlButtonRight: TPanel
        ExplicitLeft = 608
      end
      inherited pnlButtonLeft: TPanel
        ExplicitWidth = 608
      end
    end
  end
  inherited pnlBottom: TPanel
    ExplicitTop = 473
    ExplicitWidth = 789
    inherited btnAccept: TButton
      ExplicitLeft = 583
    end
    inherited btnClose: TButton
      ExplicitLeft = 687
    end
  end
  inherited stbBase: TStatusBar
    ExplicitTop = 503
    ExplicitWidth = 793
  end
end

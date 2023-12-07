inherited frmSysKaynaklar: TfrmSysKaynaklar
  Caption = 'Sistem Kaynaklar'
  ClientHeight = 533
  ExplicitHeight = 572
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 483
    ExplicitHeight = 483
    inherited splLeft: TSplitter
      Height = 407
      ExplicitHeight = 351
    end
    inherited splHeader: TSplitter
      ExplicitWidth = 797
    end
    inherited pnlLeft: TPanel
      Height = 407
      ExplicitHeight = 407
    end
    inherited pnlHeader: TPanel
      inherited lblFilterHelper: TLabel
        Height = 22
      end
    end
    inherited pnlContent: TPanel
      Height = 407
      ExplicitHeight = 407
      inherited grd: TDBGrid
        Height = 407
      end
    end
    inherited pnlButtons: TPanel
      Top = 443
      ExplicitTop = 443
    end
  end
  inherited pnlBottom: TPanel
    Top = 485
    ExplicitTop = 485
  end
  inherited stbBase: TStatusBar
    Top = 515
    ExplicitTop = 515
  end
end

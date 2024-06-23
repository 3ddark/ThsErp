inherited frmSetPrsBirimler: TfrmSetPrsBirimler
  Caption = 'Personel Birimler'
  ClientHeight = 456
  ExplicitHeight = 495
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 406
    ExplicitHeight = 406
    inherited splLeft: TSplitter
      Height = 330
      ExplicitHeight = 340
    end
    inherited splHeader: TSplitter
      ExplicitWidth = 789
    end
    inherited pnlLeft: TPanel
      Height = 330
      ExplicitHeight = 330
    end
    inherited pnlContent: TPanel
      Height = 330
      ExplicitHeight = 330
      inherited grd: TDBGrid
        Height = 330
      end
    end
    inherited pnlButtons: TPanel
      Top = 366
      ExplicitTop = 366
    end
  end
  inherited pnlBottom: TPanel
    Top = 408
    ExplicitTop = 408
  end
  inherited stbBase: TStatusBar
    Top = 438
    ExplicitTop = 438
  end
end

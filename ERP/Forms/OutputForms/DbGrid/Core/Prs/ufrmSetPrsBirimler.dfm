inherited frmSetPrsBirimler: TfrmSetPrsBirimler
  Caption = 'Personel Birimler'
  ClientHeight = 456
  ExplicitHeight = 495
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 406
    ExplicitWidth = 787
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
    end
    inherited pnlHeader: TPanel
      ExplicitWidth = 783
      inherited edtFilterHelper: TEdit
        ExplicitWidth = 740
      end
    end
    inherited pnlContent: TPanel
      Height = 330
      ExplicitWidth = 684
      inherited grd: TDBGrid
        Height = 330
      end
    end
    inherited pnlButtons: TPanel
      Top = 366
      ExplicitWidth = 787
      inherited pnlButtonRight: TPanel
        ExplicitLeft = 602
      end
      inherited pnlButtonLeft: TPanel
        ExplicitWidth = 602
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 408
    ExplicitTop = 408
    ExplicitWidth = 783
    inherited btnAccept: TButton
      ExplicitLeft = 577
    end
    inherited btnClose: TButton
      ExplicitLeft = 681
    end
  end
  inherited stbBase: TStatusBar
    Top = 438
    ExplicitTop = 438
    ExplicitWidth = 787
  end
end

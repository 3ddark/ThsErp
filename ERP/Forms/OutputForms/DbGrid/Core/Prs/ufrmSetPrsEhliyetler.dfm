inherited frmSetPrsEhliyetler: TfrmSetPrsEhliyetler
  Caption = 'Personel Ehliyet Tipleri'
  ClientHeight = 533
  ClientWidth = 791
  ExplicitHeight = 569
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 791
    Height = 483
    ExplicitWidth = 789
    ExplicitHeight = 480
    inherited splLeft: TSplitter
      Height = 355
    end
    inherited pnlLeft: TPanel
      Height = 355
      ExplicitHeight = 352
    end
    inherited pnlHeader: TPanel
      ExplicitWidth = 785
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        ExplicitWidth = 742
      end
    end
    inherited pnlContent: TPanel
      Height = 355
      ExplicitWidth = 686
      ExplicitHeight = 352
      inherited grd: TDBGrid
        Height = 355
      end
    end
    inherited pnlButtons: TPanel
      Top = 391
      ExplicitTop = 388
      ExplicitWidth = 789
      inherited pnlButtonRight: TPanel
        ExplicitLeft = 604
      end
      inherited pnlButtonLeft: TPanel
        ExplicitWidth = 604
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 485
    Width = 787
    ExplicitTop = 482
    ExplicitWidth = 785
    inherited btnAccept: TButton
      TabOrder = 2
      ExplicitLeft = 579
    end
    inherited btnClose: TButton
      ExplicitLeft = 683
    end
    inherited btnDelete: TButton
      TabOrder = 1
    end
  end
  inherited stbBase: TStatusBar
    Top = 515
    Width = 791
    ExplicitTop = 512
    ExplicitWidth = 789
  end
end

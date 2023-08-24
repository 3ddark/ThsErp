inherited frmSetPrsLisanlar: TfrmSetPrsLisanlar
  Caption = 'Personel Lisanlar'
  ExplicitWidth = 803
  ExplicitHeight = 551
  TextHeight = 13
  inherited pnlMain: TPanel
    ExplicitWidth = 787
    ExplicitHeight = 462
    inherited splLeft: TSplitter
      Height = 389
      ExplicitHeight = 340
    end
    inherited splHeader: TSplitter
      Width = 789
      ExplicitWidth = 791
    end
    inherited pnlLeft: TPanel
      Height = 389
      ExplicitHeight = 386
    end
    inherited pnlHeader: TPanel
      Width = 785
      ExplicitWidth = 783
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 742
        ExplicitWidth = 740
      end
    end
    inherited pnlContent: TPanel
      Width = 686
      Height = 389
      ExplicitWidth = 684
      ExplicitHeight = 386
      inherited grd: TDBGrid
        Width = 686
        Height = 389
      end
    end
    inherited pnlButtons: TPanel
      Top = 425
      Width = 789
      ExplicitTop = 422
      ExplicitWidth = 787
      inherited pnlButtonRight: TPanel
        Left = 604
        ExplicitLeft = 602
        ExplicitHeight = 40
      end
      inherited pnlButtonLeft: TPanel
        Width = 604
        ExplicitWidth = 602
        ExplicitHeight = 40
      end
    end
  end
  inherited pnlBottom: TPanel
    ExplicitTop = 464
    ExplicitWidth = 783
    inherited btnAccept: TButton
      Left = 579
      ExplicitLeft = 577
    end
    inherited btnClose: TButton
      Left = 683
      ExplicitLeft = 681
    end
  end
  inherited stbBase: TStatusBar
    ExplicitTop = 494
    ExplicitWidth = 787
  end
end

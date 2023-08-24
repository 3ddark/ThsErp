inherited frmSetPrsBirimler: TfrmSetPrsBirimler
  Caption = 'Personel Birimler'
  ClientHeight = 456
  ExplicitTop = -3
  ExplicitWidth = 803
  ExplicitHeight = 492
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 406
    ExplicitWidth = 787
    inherited splLeft: TSplitter
      Height = 330
      ExplicitHeight = 340
    end
    inherited splHeader: TSplitter
      Width = 789
      ExplicitWidth = 789
    end
    inherited pnlLeft: TPanel
      Height = 330
      ExplicitHeight = 389
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
      Height = 330
      ExplicitWidth = 684
      ExplicitHeight = 389
      inherited grd: TDBGrid
        Width = 686
        Height = 330
      end
    end
    inherited pnlButtons: TPanel
      Top = 366
      Width = 789
      ExplicitTop = 425
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
    Top = 408
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
    Top = 438
    ExplicitWidth = 787
  end
end

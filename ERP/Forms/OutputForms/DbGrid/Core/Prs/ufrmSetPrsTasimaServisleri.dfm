inherited frmSetPrsTasimaServisleri: TfrmSetPrsTasimaServisleri
  Caption = 'Personel Ta'#351#305'ma Servisleri'
  ExplicitWidth = 805
  ExplicitHeight = 554
  TextHeight = 13
  inherited pnlMain: TPanel
    ExplicitWidth = 789
    ExplicitHeight = 465
    inherited splLeft: TSplitter
      Height = 340
    end
    inherited splHeader: TSplitter
      Width = 791
    end
    inherited pnlLeft: TPanel
      Height = 340
      ExplicitHeight = 337
    end
    inherited pnlHeader: TPanel
      Width = 787
      ExplicitWidth = 785
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 744
        ExplicitWidth = 742
      end
    end
    inherited pnlContent: TPanel
      Width = 688
      Height = 340
      ExplicitWidth = 686
      ExplicitHeight = 337
      inherited grd: TDBGrid
        Width = 688
        Height = 340
      end
    end
    inherited pnlButtons: TPanel
      Top = 376
      Width = 791
      ExplicitTop = 373
      ExplicitWidth = 789
      inherited pnlButtonRight: TPanel
        Left = 606
        ExplicitLeft = 604
      end
      inherited pnlButtonLeft: TPanel
        Width = 606
        ExplicitWidth = 604
      end
    end
  end
  inherited pnlBottom: TPanel
    ExplicitTop = 467
    ExplicitWidth = 785
    inherited btnAccept: TButton
      Left = 581
      ExplicitLeft = 579
    end
    inherited btnClose: TButton
      Left = 685
      ExplicitLeft = 683
    end
  end
  inherited stbBase: TStatusBar
    ExplicitTop = 497
    ExplicitWidth = 789
  end
end

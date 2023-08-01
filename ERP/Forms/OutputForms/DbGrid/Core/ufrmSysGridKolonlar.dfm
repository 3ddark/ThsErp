inherited frmSysGridKolonlar: TfrmSysGridKolonlar
  Caption = 'Grid Kolonlar'
  ClientHeight = 549
  ExplicitHeight = 588
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 499
    ExplicitWidth = 797
    ExplicitHeight = 499
    inherited splLeft: TSplitter
      Height = 375
      ExplicitHeight = 375
    end
    inherited splHeader: TSplitter
      Width = 799
      ExplicitWidth = 799
    end
    inherited pnlLeft: TPanel
      Height = 375
      ExplicitHeight = 371
    end
    inherited pnlHeader: TPanel
      Width = 795
      ExplicitWidth = 793
      inherited edtFilterHelper: TEdit
        Width = 732
        ExplicitWidth = 730
      end
    end
    inherited pnlContent: TPanel
      Width = 696
      Height = 375
      ExplicitWidth = 694
      ExplicitHeight = 371
      inherited grd: TDBGrid
        Width = 696
        Height = 375
      end
    end
    inherited pnlButtons: TPanel
      Top = 411
      Width = 799
      ExplicitTop = 407
      ExplicitWidth = 797
      inherited pnlButtonRight: TPanel
        Left = 614
        ExplicitLeft = 612
      end
      inherited pnlButtonLeft: TPanel
        Width = 614
        ExplicitWidth = 612
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 501
    ExplicitTop = 501
    ExplicitWidth = 793
    inherited btnAccept: TButton
      Left = 589
      ExplicitLeft = 587
    end
    inherited btnClose: TButton
      Left = 693
      ExplicitLeft = 691
    end
  end
  inherited stbBase: TStatusBar
    Top = 531
    ExplicitTop = 531
    ExplicitWidth = 797
  end
end

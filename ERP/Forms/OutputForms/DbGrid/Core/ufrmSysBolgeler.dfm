inherited frmSysBolgeler: TfrmSysBolgeler
  Caption = 'Bolgeler'
  ClientHeight = 565
  ExplicitHeight = 604
  TextHeight = 13
  inherited pnlMain: TPanel
    Height = 515
    ExplicitWidth = 797
    ExplicitHeight = 515
    inherited splLeft: TSplitter
      Height = 391
      ExplicitHeight = 391
    end
    inherited splHeader: TSplitter
      Width = 799
      ExplicitWidth = 799
    end
    inherited pnlLeft: TPanel
      Height = 391
      ExplicitHeight = 387
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
      Height = 391
      ExplicitWidth = 694
      ExplicitHeight = 387
      inherited grd: TDBGrid
        Width = 696
        Height = 391
      end
    end
    inherited pnlButtons: TPanel
      Top = 427
      Width = 799
      ExplicitTop = 423
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
    Top = 517
    ExplicitTop = 517
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
    Top = 547
    ExplicitTop = 547
    ExplicitWidth = 797
  end
end

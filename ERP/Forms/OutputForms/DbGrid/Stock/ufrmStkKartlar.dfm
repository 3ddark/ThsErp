inherited frmStkKartlar: TfrmStkKartlar
  Caption = 'Stok Kartlar'#305
  ExplicitWidth = 801
  ExplicitHeight = 548
  TextHeight = 13
  inherited pnlMain: TPanel
    ExplicitWidth = 785
    ExplicitHeight = 459
    inherited splLeft: TSplitter
      Height = 386
      ExplicitHeight = 339
    end
    inherited splHeader: TSplitter
      Width = 787
      ExplicitWidth = 791
    end
    inherited pnlLeft: TPanel
      Height = 386
      ExplicitHeight = 383
    end
    inherited pnlHeader: TPanel
      Width = 783
      ExplicitWidth = 781
      inherited lblFilterHelper: TLabel
        Height = 22
      end
      inherited edtFilterHelper: TEdit
        Width = 740
        ExplicitWidth = 738
      end
    end
    inherited pnlContent: TPanel
      Width = 684
      Height = 386
      ExplicitWidth = 682
      ExplicitHeight = 383
      inherited grd: TDBGrid
        Width = 684
        Height = 386
      end
    end
    inherited pnlButtons: TPanel
      Top = 422
      Width = 787
      ExplicitTop = 419
      ExplicitWidth = 785
      inherited pnlButtonRight: TPanel
        Left = 602
        ExplicitLeft = 600
      end
      inherited pnlButtonLeft: TPanel
        Width = 602
        ExplicitWidth = 600
      end
    end
  end
  inherited pnlBottom: TPanel
    ExplicitTop = 461
    ExplicitWidth = 781
    inherited btnAccept: TButton
      Left = 577
      ExplicitLeft = 575
    end
    inherited btnClose: TButton
      Left = 681
      ExplicitLeft = 679
    end
  end
  inherited stbBase: TStatusBar
    ExplicitTop = 491
    ExplicitWidth = 785
  end
end

inherited frmStkKartlar: TfrmStkKartlar
  Caption = 'Stok Kartlar'#305
  TextHeight = 13
  inherited pnlMain: TPanel
    ExplicitWidth = 789
    ExplicitHeight = 463
    inherited splLeft: TSplitter
      Height = 339
      ExplicitHeight = 339
    end
    inherited splHeader: TSplitter
      Width = 791
      ExplicitWidth = 791
    end
    inherited pnlLeft: TPanel
      Height = 339
      ExplicitHeight = 335
    end
    inherited pnlHeader: TPanel
      Width = 787
      ExplicitWidth = 785
      inherited edtFilterHelper: TEdit
        Width = 744
        ExplicitWidth = 742
      end
    end
    inherited pnlContent: TPanel
      Width = 688
      Height = 339
      ExplicitWidth = 686
      ExplicitHeight = 335
      inherited grd: TDBGrid
        Width = 688
        Height = 339
      end
    end
    inherited pnlButtons: TPanel
      Top = 375
      Width = 791
      ExplicitTop = 371
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
    ExplicitTop = 465
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
    ExplicitTop = 495
    ExplicitWidth = 789
  end
end

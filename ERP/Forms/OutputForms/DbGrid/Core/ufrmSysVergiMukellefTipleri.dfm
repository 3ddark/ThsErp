inherited frmSysVergiMukellefTipleri: TfrmSysVergiMukellefTipleri
  Caption = 'M'#252'kellef Tipleri'
  TextHeight = 13
  inherited pnlMain: TPanel
    ExplicitWidth = 795
    ExplicitHeight = 475
    inherited splLeft: TSplitter
      Height = 351
      ExplicitHeight = 351
    end
    inherited splHeader: TSplitter
      Width = 797
      ExplicitWidth = 797
    end
    inherited pnlLeft: TPanel
      Height = 351
      ExplicitHeight = 347
    end
    inherited pnlHeader: TPanel
      Width = 793
      ExplicitWidth = 791
      inherited edtFilterHelper: TEdit
        Width = 730
        ExplicitWidth = 728
      end
    end
    inherited pnlContent: TPanel
      Width = 694
      Height = 351
      ExplicitWidth = 692
      ExplicitHeight = 347
      inherited grd: TDBGrid
        Width = 694
        Height = 351
      end
    end
    inherited pnlButtons: TPanel
      Top = 387
      Width = 797
      ExplicitTop = 383
      ExplicitWidth = 795
      inherited pnlButtonRight: TPanel
        Left = 612
        ExplicitLeft = 610
      end
      inherited pnlButtonLeft: TPanel
        Width = 612
        ExplicitWidth = 610
      end
    end
  end
  inherited pnlBottom: TPanel
    ExplicitTop = 477
    ExplicitWidth = 791
    inherited btnAccept: TButton
      Left = 587
      ExplicitLeft = 585
    end
    inherited btnClose: TButton
      Left = 691
      ExplicitLeft = 689
    end
  end
  inherited stbBase: TStatusBar
    ExplicitTop = 507
    ExplicitWidth = 795
  end
end

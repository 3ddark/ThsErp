inherited frmSysErisimHaklari: TfrmSysErisimHaklari
  Caption = 'Access Rights'
  ClientWidth = 813
  ExplicitWidth = 827
  ExplicitHeight = 564
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 813
    ExplicitWidth = 813
    ExplicitHeight = 479
    inherited splLeft: TSplitter
      Height = 351
      ExplicitHeight = 355
    end
    inherited splHeader: TSplitter
      Width = 813
      ExplicitWidth = 813
    end
    inherited pnlLeft: TPanel
      Height = 351
      ExplicitHeight = 347
    end
    inherited pnlHeader: TPanel
      Width = 809
      ExplicitWidth = 807
      inherited edtFilterHelper: TEdit
        Width = 746
        ExplicitWidth = 744
      end
    end
    inherited pnlContent: TPanel
      Width = 710
      Height = 351
      ExplicitWidth = 708
      ExplicitHeight = 347
      inherited grd: TDBGrid
        Width = 710
        Height = 351
      end
    end
    inherited pnlButtons: TPanel
      Top = 387
      Width = 813
      ExplicitTop = 383
      ExplicitWidth = 811
      inherited pnlButtonRight: TPanel
        Left = 628
        ExplicitLeft = 628
      end
      inherited pnlButtonLeft: TPanel
        Width = 628
        ExplicitWidth = 628
      end
    end
  end
  inherited pnlBottom: TPanel
    Width = 809
    ExplicitTop = 481
    ExplicitWidth = 809
    inherited btnAccept: TButton
      Left = 603
      ExplicitLeft = 601
    end
    inherited btnClose: TButton
      Left = 707
      ExplicitLeft = 705
    end
  end
  inherited stbBase: TStatusBar
    Width = 813
    ExplicitTop = 511
    ExplicitWidth = 813
  end
end

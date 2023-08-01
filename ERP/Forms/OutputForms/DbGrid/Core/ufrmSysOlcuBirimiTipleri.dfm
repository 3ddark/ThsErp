inherited frmSysOlcuBirimiTipleri: TfrmSysOlcuBirimiTipleri
  Caption = 'Sys '#214'l'#231#252' Birimi Tipleri'
  ClientHeight = 557
  ClientWidth = 795
  ExplicitWidth = 811
  ExplicitHeight = 596
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 795
    Height = 507
    ExplicitWidth = 795
    ExplicitHeight = 507
    inherited splLeft: TSplitter
      Height = 383
      ExplicitHeight = 383
    end
    inherited splHeader: TSplitter
      Width = 797
      ExplicitWidth = 797
    end
    inherited pnlLeft: TPanel
      Height = 383
      ExplicitHeight = 379
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
      Height = 383
      ExplicitWidth = 692
      ExplicitHeight = 379
      inherited grd: TDBGrid
        Width = 694
        Height = 383
      end
    end
    inherited pnlButtons: TPanel
      Top = 419
      Width = 797
      ExplicitTop = 415
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
    Top = 509
    Width = 791
    ExplicitTop = 509
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
    Top = 539
    Width = 795
    ExplicitTop = 539
    ExplicitWidth = 795
  end
end
